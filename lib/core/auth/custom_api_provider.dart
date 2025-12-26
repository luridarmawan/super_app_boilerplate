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
      // TODO: Implementasi dengan HTTP client
      // final response = await http.post(
      //   Uri.parse('$baseUrl/auth/login'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     ...?headers,
      //   },
      //   body: jsonEncode({
      //     'email': email,
      //     'password': password,
      //   }),
      // );
      
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = AuthUser(
        uid: 'api_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@').first,
        isEmailVerified: true,
      );
      
      // Simpan user setelah login berhasil
      await _saveUser(_currentUser!);

      _authStateController.add(_currentUser);
      return AuthResult.success(_currentUser!);
    } catch (e) {
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
