import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_interface.dart';
import '../constants/app_info.dart';

/// Implementasi Custom API Auth
/// Gunakan ini untuk backend custom (REST API, GraphQL, dll)
class CustomApiAuthProvider implements BaseAuthService {
  AuthUser? _currentUser;
  final StreamController<AuthUser?> _authStateController = 
      StreamController<AuthUser?>.broadcast();
  
  // Configuration
  final String? baseUrl;
  final Map<String, String>? headers;
  
  // Google Sign-In instance (singleton in v7.x)
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  // SharedPreferences keys
  static const String _savedUserKey = 'app_saved_user';
  static const String _isLoggedInKey = 'app_is_logged_in';

  CustomApiAuthProvider({
    this.baseUrl,
    this.headers,
  }) {
    _currentUser = null;
    _authStateController.add(null);
    _initGoogleSignIn();
    // Memuat saved user saat inisialisasi
    _loadSavedUser();
  }
  
  Future<void> _initGoogleSignIn() async {
    if (_googleSignInInitialized) return;
    try {
      // serverClientId is required on Android for google_sign_in v7.x
      await _googleSignIn.initialize(
        serverClientId: AppInfo.googleServerClientId,
      );
      _googleSignInInitialized = true;
    } catch (e) {
      // Initialization might fail on some platforms
    }
  }

  /// Memuat user yang tersimpan dari SharedPreferences
  Future<void> _loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (isLoggedIn) {
        final savedUserJson = prefs.getString(_savedUserKey);
        if (savedUserJson != null && savedUserJson.isNotEmpty) {
          final userMap = jsonDecode(savedUserJson) as Map<String, dynamic>;
          _currentUser = AuthUser.fromJson(userMap);
          _authStateController.add(_currentUser);
          debugPrint('[AUTH] Loaded saved user: ${_currentUser?.email}');
        }
      }
    } catch (e) {
      debugPrint('[AUTH] Error loading saved user: $e');
    }
  }

  /// Menyimpan user ke SharedPreferences setelah login berhasil
  Future<void> _saveUser(AuthUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedUserKey, jsonEncode(user.toJson()));
      await prefs.setBool(_isLoggedInKey, true);
      debugPrint('[AUTH] User saved: ${user.email}');
    } catch (e) {
      debugPrint('[AUTH] Error saving user: $e');
    }
  }

  /// Menghapus user yang tersimpan dari SharedPreferences saat logout
  Future<void> _clearSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedUserKey);
      await prefs.setBool(_isLoggedInKey, false);
      debugPrint('[AUTH] Saved user cleared');
    } catch (e) {
      debugPrint('[AUTH] Error clearing saved user: $e');
    }
  }

  @override
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[AUTH] >>> Starting Email/Password Login');
      debugPrint('[AUTH] Email: $email');

      // Get login URL directly from AppInfo
      final loginUrl = AppInfo.authLoginUrl;
      final contentType = AppInfo.authLoginContentType;
      debugPrint('[AUTH] POST $loginUrl');
      debugPrint('[AUTH] Content-Type: $contentType');

      // Prepare request data based on content type
      final dio = Dio();
      Object requestData;

      if (contentType == 'application/x-www-form-urlencoded') {
        // For form-urlencoded, use FormData or string format
        requestData = {
          'username': email,
          'password': password,
        };
      } else {
        // Default: application/json
        requestData = {
          'username': email,
          'password': password,
        };
      }

      final response = await dio.post(
        loginUrl,
        options: Options(
          headers: {
            'Content-Type': contentType,
            ...?headers,
          },
          // For form-urlencoded, Dio needs this to encode properly
          contentType: contentType,
        ),
        data: requestData,
      );

      debugPrint('[AUTH] Response: ${response.statusCode} - ${response.data}');

      // Handle error responses
      if (response.statusCode != 200) {
        final errorData = response.data;
        String errorMessage = 'Login failed';

        if (errorData is Map<String, dynamic>) {
          // Try to extract error message from response
          // Support various field names: message, msg, error, detail
          errorMessage = errorData['message']?.toString() ??
              errorData['msg']?.toString() ??
              errorData['error']?.toString() ??
              errorData['detail']?.toString() ??
              'Login failed: ${response.statusCode}';
        }

        debugPrint('[AUTH] ERROR: $errorMessage');
        return AuthResult.failure(errorMessage);
      }

      // Parse response data
      final responseData = response.data as Map<String, dynamic>;

      // Extract user data (adapt based on your API response structure)
      // Common response structures:
      // 1. { user: {...}, token: "..." }
      // 2. { data: { user: {...}, token: "..." } }
      // 3. { id: ..., email: ..., name: ..., token: "..." }
      
      Map<String, dynamic>? userData;
      String? accessToken; // ignore: unused_local_variable
      String? refreshToken; // ignore: unused_local_variable

      // check response data, jika json dan memiliki field "code", check value-nya
      // code 0 atau 200 artinya success
      if (responseData.containsKey('code')) {
        if (responseData['code'] != 0 && responseData['code'] != 200) {
          // Support both 'message' and 'msg' field names
          final errorMsg = responseData['message']?.toString() ??
              responseData['msg']?.toString() ??
              'Login failed';
          return AuthResult.failure(errorMsg);
        }
      }

      // Handle different API response structures
      if (responseData.containsKey('user')) {
        userData = responseData['user'] as Map<String, dynamic>?;
        accessToken = responseData['token']?.toString() ?? 
                      responseData['access_token']?.toString();
        refreshToken = responseData['refresh_token']?.toString();
      } else if (responseData.containsKey('data')) {
        final data = responseData['data'] as Map<String, dynamic>;
        userData = data['user'] as Map<String, dynamic>? ?? data;
        accessToken = data['token']?.toString() ?? 
                      data['access_token']?.toString();
        refreshToken = data['refresh_token']?.toString();
      } else {
        // Assume the response is the user data itself
        userData = responseData;
        accessToken = responseData['token']?.toString() ?? 
                      responseData['access_token']?.toString();
        refreshToken = responseData['refresh_token']?.toString();
      }

      // Build display name from available fields
      String? displayName = userData?['name']?.toString() ?? 
                            userData?['display_name']?.toString() ??
                            userData?['full_name']?.toString();

      // If no direct name field, try combining first_name and last_name
      if (displayName == null || displayName.isEmpty) {
        final firstName = userData?['first_name']?.toString() ?? '';
        final lastName = userData?['last_name']?.toString() ?? '';
        final combinedName = '$firstName $lastName'.trim();
        if (combinedName.isNotEmpty) {
          displayName = combinedName;
        }
      }

      // Fallback to email prefix if no name found
      displayName ??= email.split('@').first;

      // Create AuthUser from response
      _currentUser = AuthUser(
        uid: userData?['id']?.toString() ?? 
             userData?['uid']?.toString() ?? 
             'user_${DateTime.now().millisecondsSinceEpoch}',
        email: userData?['email']?.toString() ?? email,
        displayName: displayName,
        photoUrl: userData?['photo_url']?.toString() ?? 
                  userData?['avatar']?.toString() ??
                  userData?['picture']?.toString(),
        isEmailVerified: userData?['email_verified'] == true || 
                         userData?['is_verified'] == true,
        isGoogleLogin: false,
      );

      debugPrint('[AUTH] <<< Login Success: ${_currentUser!.email}, Name: ${_currentUser!.displayName}');

      // Save user after successful login
      await _saveUser(_currentUser!);

      // TODO: If your API returns tokens, you can save them here
      // Example:
      // if (accessToken != null) {
      //   final prefs = await SharedPreferences.getInstance();
      //   await prefs.setString('access_token', accessToken);
      //   if (refreshToken != null) {
      //     await prefs.setString('refresh_token', refreshToken);
      //   }
      // }

      _authStateController.add(_currentUser);
      return AuthResult.success(_currentUser!);
    } on DioException catch (e) {
      debugPrint('[AUTH] DioException: ${e.type} - ${e.message}');

      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Koneksi timeout. Silakan coba lagi.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else if (e.response != null) {
        // Try to extract error message from response
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          // Support various field names: message, msg, error, detail
          errorMessage = data['message']?.toString() ??
              data['msg']?.toString() ??
              data['error']?.toString() ??
              data['detail']?.toString() ??
              'Login gagal';
        } else {
          errorMessage = 'Login gagal: ${e.response?.statusCode}';
        }
      } else {
        errorMessage = 'Login gagal: ${e.message}';
      }

      return AuthResult.failure(errorMessage);
    } catch (e) {
      debugPrint('[AUTH] Exception: $e');
      return AuthResult.failure('Login gagal: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // TODO: Implementasi dengan HTTP client
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = AuthUser(
        uid: 'api_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName ?? email.split('@').first,
        isEmailVerified: false,
      );
      
      // Simpan user setelah registrasi berhasil
      await _saveUser(_currentUser!);

      _authStateController.add(_currentUser);
      return AuthResult.success(_currentUser!);
    } catch (e) {
      return AuthResult.failure('Registrasi gagal: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      debugPrint('[GAUTH] >>> Starting Google Sign-In');

      // Ensure Google Sign-In is initialized
      await _initGoogleSignIn();
      
      // Check if authenticate is supported
      if (!_googleSignIn.supportsAuthenticate()) {
        debugPrint('[GAUTH] ERROR: Not supported on this platform');
        return AuthResult.failure('Google Sign-In tidak didukung di platform ini');
      }
      
      // Trigger Google Sign-In flow (v7.x API)
      final googleUser = await _googleSignIn.authenticate();
      debugPrint('[GAUTH] User: ${googleUser.email}');

      // Get authentication tokens for backend verification
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint('[GAUTH] ERROR: ID Token is null');
        return AuthResult.failure('Gagal mendapatkan ID Token dari Google');
      }
      debugPrint('[GAUTH] Token obtained (${idToken.length} chars)');

      // Send idToken to backend API for verification
      final apiUrl = AppInfo.apiGoogleAuthVerification;
      debugPrint('[GAUTH] POST $apiUrl');

      final dio = Dio();
      final response = await dio.post(
        apiUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            ...?headers,
          },
        ),
        data: {'token': idToken},
      );

      debugPrint('[GAUTH] Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode != 200) {
        debugPrint('[GAUTH] ERROR: Backend returned ${response.statusCode}');
        return AuthResult.failure('Verifikasi token gagal: ${response.statusCode}');
      }

      // Parse user data from API response
      final responseData = response.data;
      final userData = responseData['user'] as Map<String, dynamic>?;

      if (userData == null) {
        debugPrint('[GAUTH] ERROR: No user data in response');
        return AuthResult.failure('Data user tidak ditemukan dalam response');
      }

      // Create user from API response (more complete than googleUser)
      _currentUser = AuthUser(
        uid: userData['id']?.toString() ?? googleUser.id,
        email: userData['email']?.toString() ?? googleUser.email,
        displayName: userData['name']?.toString() ?? googleUser.displayName,
        photoUrl: userData['picture']?.toString() ?? googleUser.photoUrl,
        isEmailVerified: userData['email_verified'] == true,
        isGoogleLogin: true,
      );

      debugPrint('[GAUTH] <<< Success: ${_currentUser!.email}, Name: ${_currentUser!.displayName}');

      // Simpan user setelah login Google berhasil
      await _saveUser(_currentUser!);

      _authStateController.add(_currentUser);
      return AuthResult.success(_currentUser!);
    } catch (e, stackTrace) {
      debugPrint('[GAUTH] EXCEPTION: $e');
      debugPrint('[GAUTH] Stack: $stackTrace');

      // Handle cancel or other errors
      if (e.toString().contains('canceled') || e.toString().contains('cancelled')) {
        return AuthResult.failure('Login dibatalkan');
      }
      return AuthResult.failure('Login Google gagal: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google (v7.x API)
      await _googleSignIn.disconnect();
    } catch (e) {
      // Ignore Google sign out errors
    }
    // Hapus saved user dari SharedPreferences
    await _clearSavedUser();

    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<AuthResult> sendEmailVerification() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return AuthResult.success(_currentUser ?? AuthUser.empty());
    } catch (e) {
      return AuthResult.failure('Gagal mengirim email verifikasi');
    }
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return AuthResult(success: true);
    } catch (e) {
      return AuthResult.failure('Gagal mengirim email reset password');
    }
  }

  @override
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          displayName: displayName,
          photoUrl: photoUrl,
        );
        _authStateController.add(_currentUser);
        return AuthResult.success(_currentUser!);
      }
      return AuthResult.failure('User tidak ditemukan');
    } catch (e) {
      return AuthResult.failure('Gagal update profil');
    }
  }

  @override
  void dispose() {
    _authStateController.close();
  }
}
