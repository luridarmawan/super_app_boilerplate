import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_info.dart';
import '../routes/app_router.dart';
import 'auth_interface.dart';
import 'token_refresh_service.dart';

/// Auth provider untuk backend Carik (dashboard boilerplate, API `/v1`).
///
/// Alur:
/// - Masuk (`POST /v1/auth/token`, `/v1/auth/token/google`) menghasilkan token Bearer di body,
///   bukan cookie. Rute masuk dilindungi CSRF, jadi provider mengambil pasangan dari
///   `GET /v1/auth/csrf-token` lalu mengirimnya kembali bersama header `Origin` server.
/// - Token berlaku singkat (baku 60 menit) dan diperpanjang lewat `POST /v1/auth/token/refresh`
///   selama masih di dalam jendela refresh (baku 36 jam setelah kedaluwarsa). Refresh memperpanjang
///   token yang SAMA. Di luar jendela server menjawab `token_expired` → auto-logout.
/// - Profil dan sandi memakai API core: `/v1/users/profile/me`, `/v1/users/profile/password`,
///   `/v1/auth/reset-password/request`, `/v1/auth/register`.
///
/// Konfigurasi: `AUTH_PROVIDER=carik`, `CARIK_API_BASE_URL=https://app.example.com`, dan untuk
/// Google `GOOGLE_CLIENT_ID` = client id web yang juga diisi di Pengaturan → Keamanan server.
class CarikAuthProvider implements BaseAuthService {
  CarikAuthProvider({String? baseUrl, Dio? dio})
    : _baseUrl = _trimSlash(baseUrl ?? AppInfo.carikApiBaseUrl),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              // Envelope Carik selalu dibaca sendiri, termasuk 4xx.
              validateStatus: (_) => true,
            ),
          ) {
    _authStateController.add(null);
    _initGoogleSignIn();
    _loadSavedUser();
    TokenRefreshService.instance.setRefreshHandler(_refreshFor);
    TokenRefreshService.instance.setOnAuthExpired(_handleAuthExpired);
  }

  final String _baseUrl;
  final Dio _dio;
  AuthUser? _currentUser;
  final StreamController<AuthUser?> _authStateController = StreamController<AuthUser?>.broadcast();

  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  // Kunci SharedPreferences yang sama dengan provider lain: TokenRefreshService dan modul
  // membaca token dari sini.
  static const String _savedUserKey = 'app_saved_user';
  static const String _isLoggedInKey = 'app_is_logged_in';

  static String _trimSlash(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  String _url(String path) => '$_baseUrl$path';

  String get _origin {
    final uri = Uri.tryParse(_baseUrl);
    return uri == null || uri.host.isEmpty ? _baseUrl : uri.origin;
  }

  // ---------------------------------------------------------------------------
  // BaseAuthService
  // ---------------------------------------------------------------------------

  @override
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  String? get accessToken => _currentUser?.jwt;

  @override
  Future<String?> refreshAccessToken() async {
    final token = accessToken;
    if (token == null || token.isEmpty) return null;
    return TokenRefreshService.instance.refreshToken(currentJwt: token);
  }

  @override
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_baseUrl.isEmpty) return AuthResult.failure('CARIK_API_BASE_URL belum diatur di .env');
    try {
      final res = await _post('/v1/auth/token', {
        'email': email.trim(),
        'password': password,
        'device': await _deviceName(),
      }, csrf: true);
      if (!res.ok) return AuthResult.failure(res.message);
      return await _signedIn(res.data, isGoogleLogin: false);
    } on DioException catch (e) {
      return AuthResult.failure(_networkMessage(e));
    } catch (e) {
      debugPrint('[CARIK-AUTH] signIn error: $e');
      return AuthResult.failure('Login gagal: $e');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    if (_baseUrl.isEmpty) return AuthResult.failure('CARIK_API_BASE_URL belum diatur di .env');
    try {
      await _initGoogleSignIn();
      if (!_googleSignIn.supportsAuthenticate()) {
        return AuthResult.failure('Google Sign-In tidak didukung di platform ini');
      }
      final googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) return AuthResult.failure('Gagal mendapatkan ID Token dari Google');

      final res = await _post('/v1/auth/token/google', {
        'idToken': idToken,
        'device': await _deviceName(),
      }, csrf: true);
      if (!res.ok) {
        // Sesi Google dilepas agar user bisa memilih akun lain pada percobaan berikutnya.
        await _disconnectGoogle();
        return AuthResult.failure(res.message);
      }
      return await _signedIn(res.data, isGoogleLogin: true, googlePhotoUrl: googleUser.photoUrl);
    } on DioException catch (e) {
      return AuthResult.failure(_networkMessage(e));
    } catch (e) {
      final text = e.toString();
      if (text.contains('canceled') || text.contains('cancelled')) {
        return AuthResult.failure('Login dibatalkan');
      }
      debugPrint('[CARIK-AUTH] Google sign-in error: $e');
      return AuthResult.failure('Login Google gagal: $text');
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (_baseUrl.isEmpty) return AuthResult.failure('CARIK_API_BASE_URL belum diatur di .env');
    try {
      final name = (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : email.split('@').first;
      final res = await _post('/v1/auth/register', {
        'email': email.trim(),
        'password': password,
        'name': name,
      }, csrf: true);
      if (!res.ok) return AuthResult.failure(res.message);
      // Registrasi membuka sesi cookie untuk browser; aplikasi butuh token, jadi langsung masuk.
      return await signInWithEmailAndPassword(email: email, password: password);
    } on DioException catch (e) {
      return AuthResult.failure(_networkMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    final token = accessToken;
    if (token != null && token.isNotEmpty && _baseUrl.isNotEmpty) {
      try {
        // Cabut token di server; kegagalan jaringan tidak menghalangi logout lokal.
        await _dio.delete(
          _url('/v1/auth/token'),
          options: Options(headers: _bearer(token), receiveTimeout: const Duration(seconds: 10)),
        );
      } catch (e) {
        debugPrint('[CARIK-AUTH] revoke on sign-out failed: $e');
      }
    }
    await _disconnectGoogle();
    await _clearSavedUser();
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<AuthResult> sendEmailVerification() async {
    // Server mengirim email verifikasi otomatis saat registrasi; belum ada endpoint kirim ulang.
    return AuthResult.failure('Kirim ulang email verifikasi belum tersedia');
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    if (_baseUrl.isEmpty) return AuthResult.failure('CARIK_API_BASE_URL belum diatur di .env');
    try {
      final res = await _post('/v1/auth/reset-password/request', {
        'email': email.trim(),
      }, csrf: true);
      // Server selalu menjawab sama, terdaftar atau tidak.
      return res.ok ? AuthResult(success: true) : AuthResult.failure(res.message);
    } on DioException catch (e) {
      return AuthResult.failure(_networkMessage(e));
    }
  }

  @override
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final res = await _authorized(
        (token) => _dio.put(
          _url('/v1/users/profile/password'),
          data: {'currentPassword': currentPassword, 'newPassword': newPassword},
          options: Options(headers: _bearer(token), contentType: Headers.jsonContentType),
        ),
      );
      if (res == null) return AuthResult.failure('Sesi berakhir, silakan login kembali');
      return res.ok ? AuthResult(success: true) : AuthResult.failure(res.message);
    } on DioException catch (e) {
      return AuthResult.failure(_networkMessage(e));
    }
  }

  @override
  Future<AuthResult> updateProfile({String? displayName, String? photoUrl}) async {
    final user = _currentUser;
    if (user == null) return AuthResult.failure('User tidak ditemukan');
    final body = <String, dynamic>{
      if (displayName != null && displayName.trim().isNotEmpty) 'name': displayName.trim(),
      'avatarUrl': ?photoUrl,
    };
    if (body.isEmpty) return AuthResult.success(user);
    try {
      final res = await _authorized(
        (token) => _dio.put(
          _url('/v1/users/profile/me'),
          data: body,
          options: Options(headers: _bearer(token), contentType: Headers.jsonContentType),
        ),
      );
      if (res == null) return AuthResult.failure('Sesi berakhir, silakan login kembali');
      if (!res.ok) return AuthResult.failure(res.message);
      final profile = res.data['user'];
      if (profile is Map<String, dynamic>) {
        _currentUser = _userFrom(
          profile,
          token: user.jwt,
          isGoogleLogin: user.isGoogleLogin,
        ).copyWith(photoUrl: user.isGoogleLogin ? user.photoUrl : null);
        await _saveUser(_currentUser!);
        _authStateController.add(_currentUser);
      }
      return AuthResult.success(_currentUser!);
    } on DioException catch (e) {
      return AuthResult.failure(_networkMessage(e));
    }
  }

  @override
  void dispose() {
    _authStateController.close();
  }

  // ---------------------------------------------------------------------------
  // Token
  // ---------------------------------------------------------------------------

  /// Dipanggil TokenRefreshService (juga oleh modul). Server memperpanjang token yang sama.
  Future<String?> _refreshFor(String token) async {
    if (_baseUrl.isEmpty) return null;
    try {
      final res = await _send(
        () => _dio.post(_url('/v1/auth/token/refresh'), options: Options(headers: _bearer(token))),
      );
      if (res.ok) {
        final fresh = res.data['accessToken']?.toString();
        if (fresh == null || fresh.isEmpty) return null;
        if (_currentUser != null) {
          final profile = res.data['user'];
          _currentUser = profile is Map<String, dynamic>
              ? _userFrom(
                  profile,
                  token: fresh,
                  isGoogleLogin: _currentUser!.isGoogleLogin,
                ).copyWith(photoUrl: _currentUser!.isGoogleLogin ? _currentUser!.photoUrl : null)
              : _currentUser!.copyWith(jwt: fresh);
          await _saveUser(_currentUser!);
          _authStateController.add(_currentUser);
        }
        return fresh;
      }
      // 401 token_expired / token_invalid: sesi tidak bisa diselamatkan, user harus login ulang.
      if (res.status == 401 && (res.code == 'token_expired' || res.code == 'token_invalid')) {
        debugPrint('[CARIK-AUTH] refresh refused (${res.code}), signing out');
        unawaited(_handleAuthExpired());
      }
      return null;
    } on DioException catch (e) {
      // Jaringan putus bukan alasan logout; coba lagi nanti.
      debugPrint('[CARIK-AUTH] refresh network error: ${e.message}');
      return null;
    }
  }

  /// Jalankan request ber-Bearer; bila token kedaluwarsa (401), refresh sekali lalu ulangi.
  Future<_CarikResponse?> _authorized(Future<Response> Function(String token) request) async {
    final token = accessToken;
    if (token == null || token.isEmpty) return null;
    var res = await _send(() => request(token));
    if (res.status != 401) return res;
    final fresh = await TokenRefreshService.instance.refreshToken(currentJwt: token);
    if (fresh == null) return null;
    res = await _send(() => request(fresh));
    return res;
  }

  Future<void> _handleAuthExpired() async {
    await signOut();
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please login again.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      context.go(AppRoutes.login);
    }
  }

  // ---------------------------------------------------------------------------
  // HTTP
  // ---------------------------------------------------------------------------

  Map<String, String> _bearer(String token) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  /// Pasangan CSRF untuk rute yang tidak membawa Bearer: token dari body dipakai sekaligus
  /// sebagai cookie `crk_csrf` dan header `x-csrf-token`, dengan `Origin` milik server.
  Future<Map<String, String>> _csrfHeaders() async {
    final res = await _send(() => _dio.get(_url('/v1/auth/csrf-token')));
    final token = res.ok ? res.data['token']?.toString() : null;
    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/v1/auth/csrf-token'),
        message: 'CSRF token tidak didapat (${res.status})',
      );
    }
    return {
      'Origin': _origin,
      'Cookie': 'crk_csrf=$token',
      'x-csrf-token': token,
      'Accept': 'application/json',
    };
  }

  Future<_CarikResponse> _post(String path, Map<String, dynamic> body, {bool csrf = false}) async {
    final headers = csrf ? await _csrfHeaders() : <String, String>{'Accept': 'application/json'};
    return _send(
      () => _dio.post(
        _url(path),
        data: body,
        options: Options(headers: headers, contentType: Headers.jsonContentType),
      ),
    );
  }

  Future<_CarikResponse> _send(Future<Response> Function() request) async {
    final response = await request();
    return _CarikResponse.from(response);
  }

  String _networkMessage(DioException e) {
    debugPrint('[CARIK-AUTH] ${e.type}: ${e.message}');
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Koneksi timeout. Silakan coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      default:
        return e.message ?? 'Permintaan ke server gagal';
    }
  }

  // ---------------------------------------------------------------------------
  // User
  // ---------------------------------------------------------------------------

  Future<AuthResult> _signedIn(
    Map<String, dynamic> data, {
    required bool isGoogleLogin,
    String? googlePhotoUrl,
  }) async {
    if (data['mfaRequired'] == true) {
      // Langkah kedua (POST /v1/auth/token/mfa) belum punya layar di aplikasi.
      return AuthResult.failure(
        'Akun ini memakai verifikasi dua langkah (2FA) yang belum didukung aplikasi. '
        'Masuk lewat web, atau matikan 2FA di profil.',
      );
    }
    final token = data['accessToken']?.toString();
    final profile = data['user'];
    if (token == null || token.isEmpty || profile is! Map<String, dynamic>) {
      return AuthResult.failure('Respons server tidak dikenali');
    }
    var user = _userFrom(profile, token: token, isGoogleLogin: isGoogleLogin);
    if (isGoogleLogin && googlePhotoUrl != null && googlePhotoUrl.isNotEmpty) {
      user = user.copyWith(photoUrl: googlePhotoUrl);
    }
    _currentUser = user;
    await _saveUser(user);
    _authStateController.add(user);
    debugPrint('[CARIK-AUTH] signed in: ${user.email} (expires ${data['expiresAt']})');
    return AuthResult.success(user);
  }

  AuthUser _userFrom(Map<String, dynamic> u, {String? token, required bool isGoogleLogin}) {
    return AuthUser(
      uid: u['id']?.toString() ?? '',
      email: u['email']?.toString(),
      displayName: u['name']?.toString(),
      photoUrl: _absolute(u['avatarUrl']?.toString()),
      isEmailVerified: u['emailVerifiedAt'] != null,
      isGoogleLogin: isGoogleLogin,
      jwt: token,
    );
  }

  /// Avatar bisa berupa path relatif (`/v1/files/...`); lengkapi dengan origin server.
  String? _absolute(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '$_origin${url.startsWith('/') ? '' : '/'}$url';
  }

  Future<String> _deviceName() async {
    var name = AppInfo.name;
    try {
      final info = await PackageInfo.fromPlatform();
      name = '${info.appName} ${info.version}';
    } catch (_) {}
    final platform = kIsWeb ? 'web' : Platform.operatingSystem;
    final label = '$name ($platform)';
    return label.length > 80 ? label.substring(0, 80) : label;
  }

  Future<void> _initGoogleSignIn() async {
    if (_googleSignInInitialized) return;
    try {
      await _googleSignIn.initialize(serverClientId: AppInfo.googleServerClientId);
      _googleSignInInitialized = true;
    } catch (e) {
      debugPrint('[CARIK-AUTH] Google Sign-In init failed: $e');
    }
  }

  Future<void> _disconnectGoogle() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
  }

  Future<void> _loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(_isLoggedInKey) ?? false)) return;
      final json = prefs.getString(_savedUserKey);
      if (json == null || json.isEmpty) return;
      _currentUser = AuthUser.fromJson(jsonDecode(json) as Map<String, dynamic>);
      _authStateController.add(_currentUser);
    } catch (e) {
      debugPrint('[CARIK-AUTH] load saved user failed: $e');
    }
  }

  Future<void> _saveUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedUserKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<void> _clearSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}

/// Envelope Carik: `{ success: true, data }` atau `{ success: false, error: { code, message } }`.
class _CarikResponse {
  _CarikResponse(this.status, this.ok, this.data, this.code, this.message);

  final int status;
  final bool ok;
  final Map<String, dynamic> data;
  final String? code;
  final String message;

  factory _CarikResponse.from(Response response) {
    final status = response.statusCode ?? 0;
    final body = response.data;
    if (body is Map<String, dynamic>) {
      if (body['success'] == true) {
        final data = body['data'];
        return _CarikResponse(
          status,
          status >= 200 && status < 300,
          data is Map<String, dynamic> ? data : <String, dynamic>{},
          null,
          '',
        );
      }
      final error = body['error'];
      if (error is Map<String, dynamic>) {
        var message = error['message']?.toString() ?? 'Permintaan gagal ($status)';
        // weak_password dan sejenisnya membawa daftar alasan di details.
        final details = error['details'];
        if (details is List && details.isNotEmpty) message = '$message: ${details.join(', ')}';
        return _CarikResponse(
          status,
          false,
          <String, dynamic>{},
          error['code']?.toString(),
          message,
        );
      }
    }
    return _CarikResponse(
      status,
      false,
      <String, dynamic>{},
      null,
      'Respons server tidak dikenali ($status)',
    );
  }
}
