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
      debugPrint('[AUTH] ============================================');
      debugPrint('[AUTH] >>> Starting Email/Password Login');
      debugPrint('[AUTH] Email: $email');
      debugPrint('[AUTH] Password length: ${password.length}');

      // Get login URL directly from AppInfo
      final loginUrl = AppInfo.authLoginUrl;
      final contentType = AppInfo.authLoginContentType;
      debugPrint('[AUTH] POST URL: $loginUrl');
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
      debugPrint('[AUTH] Request data: $requestData');

      debugPrint('[AUTH] Sending POST request...');
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

      debugPrint('[AUTH] ----------------------------------------');
      debugPrint('[AUTH] Response Status Code: ${response.statusCode}');
      debugPrint('[AUTH] Response Headers: ${response.headers}');
      debugPrint('[AUTH] Raw Response Data Type: ${response.data.runtimeType}');
      debugPrint('[AUTH] Raw Response Data: ${response.data}');

      // Handle error responses
      if (response.statusCode != 200) {
        final errorData = response.data;
        debugPrint('[AUTH] ERROR: Non-200 status code received');
        debugPrint('[AUTH] Error data type: ${errorData.runtimeType}');
        debugPrint('[AUTH] Error data: $errorData');

        String errorMessage = 'Login failed';

        if (errorData is Map<String, dynamic>) {
          // Try to extract error message from response
          // Support various field names: message, msg, error, detail
          errorMessage = errorData['message']?.toString() ??
              errorData['msg']?.toString() ??
              errorData['error']?.toString() ??
              errorData['detail']?.toString() ??
              'Login failed: ${response.statusCode}';
          debugPrint('[AUTH] Extracted error message: $errorMessage');
        }

        debugPrint('[AUTH] Returning failure: $errorMessage');
        return AuthResult.failure(errorMessage);
      }

      // Parse response data
      debugPrint('[AUTH] ----------------------------------------');
      debugPrint('[AUTH] Parsing response data...');

      if (response.data == null) {
        debugPrint('[AUTH] ERROR: response.data is null!');
        return AuthResult.failure('Server response is null');
      }

      if (response.data is! Map<String, dynamic>) {
        debugPrint('[AUTH] ERROR: response.data is not a Map!');
        debugPrint('[AUTH] Actual type: ${response.data.runtimeType}');
        debugPrint('[AUTH] Actual value: ${response.data}');
        return AuthResult.failure('Invalid server response format');
      }

      final responseData = response.data as Map<String, dynamic>;
      debugPrint('[AUTH] Response keys: ${responseData.keys.toList()}');

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
        debugPrint('[AUTH] Response contains "code" field: ${responseData['code']}');
        if (responseData['code'] != 0 && responseData['code'] != 200) {
          // Support both 'message' and 'msg' field names
          final errorMsg = responseData['message']?.toString() ??
              responseData['msg']?.toString() ??
              'Login failed';
          debugPrint('[AUTH] Code indicates failure. Error: $errorMsg');
          return AuthResult.failure(errorMsg);
        }
        debugPrint('[AUTH] Code indicates success');
      }

      // Handle different API response structures
      debugPrint('[AUTH] Detecting API response structure...');
      if (responseData.containsKey('user')) {
        debugPrint('[AUTH] Structure detected: { user: {...} }');
        userData = responseData['user'] as Map<String, dynamic>?;
        accessToken = responseData['token']?.toString() ?? 
                      responseData['access_token']?.toString();
        refreshToken = responseData['refresh_token']?.toString();
      } else if (responseData.containsKey('data')) {
        debugPrint('[AUTH] Structure detected: { data: {...} }');
        final data = responseData['data'];
        debugPrint('[AUTH] data type: ${data.runtimeType}');
        debugPrint('[AUTH] data value: $data');
        if (data is Map<String, dynamic>) {
          userData = data['user'] as Map<String, dynamic>? ?? data;
          accessToken = data['token']?.toString() ?? 
                        data['access_token']?.toString();
          refreshToken = data['refresh_token']?.toString();
        } else {
          debugPrint('[AUTH] WARNING: data is not a Map, treating response as user data');
          userData = responseData;
        }
      } else {
        debugPrint('[AUTH] Structure detected: user data at root level');
        // Assume the response is the user data itself
        userData = responseData;
        accessToken = responseData['token']?.toString() ?? 
                      responseData['access_token']?.toString();
        refreshToken = responseData['refresh_token']?.toString();
      }

      debugPrint('[AUTH] Extracted userData: $userData');
      debugPrint('[AUTH] Extracted accessToken: ${accessToken != null ? "(${accessToken!.length} chars)" : "null"}');
      debugPrint('[AUTH] Extracted refreshToken: ${refreshToken != null ? "(${refreshToken!.length} chars)" : "null"}');

      // Build display name from available fields
      debugPrint('[AUTH] ----------------------------------------');
      debugPrint('[AUTH] Building display name...');
      String? displayName = userData?['name']?.toString() ?? 
                            userData?['display_name']?.toString() ??
                            userData?['full_name']?.toString();
      debugPrint('[AUTH] Initial displayName: $displayName');

      // If no direct name field, try combining first_name and last_name
      if (displayName == null || displayName.isEmpty) {
        final firstName = userData?['first_name']?.toString() ?? '';
        final lastName = userData?['last_name']?.toString() ?? '';
        debugPrint('[AUTH] firstName: "$firstName", lastName: "$lastName"');
        final combinedName = '$firstName $lastName'.trim();
        if (combinedName.isNotEmpty) {
          displayName = combinedName;
        }
      }

      // Fallback to email prefix if no name found
      displayName ??= email.split('@').first;
      debugPrint('[AUTH] Final displayName: $displayName');

      // Build user ID
      final uid = userData?['id']?.toString() ?? 
                  userData?['uid']?.toString() ?? 
                  'user_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('[AUTH] User ID: $uid');

      // Create AuthUser from response
      debugPrint('[AUTH] Creating AuthUser object...');
      _currentUser = AuthUser(
        uid: uid,
        email: userData?['email']?.toString() ?? email,
        displayName: displayName,
        photoUrl: userData?['photo_url']?.toString() ?? 
                  userData?['avatar']?.toString() ??
                  userData?['picture']?.toString(),
        isEmailVerified: userData?['email_verified'] == true || 
                         userData?['is_verified'] == true,
        isGoogleLogin: false,
      );

      debugPrint('[AUTH] ============================================');
      debugPrint('[AUTH] <<< LOGIN SUCCESS');
      debugPrint('[AUTH] User email: ${_currentUser!.email}');
      debugPrint('[AUTH] User name: ${_currentUser!.displayName}');
      debugPrint('[AUTH] User uid: ${_currentUser!.uid}');

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
    } on DioException catch (e, stackTrace) {
      debugPrint('[AUTH] ============================================');
      debugPrint('[AUTH] !!! DIO EXCEPTION !!!');
      debugPrint('[AUTH] Exception Type: ${e.type}');
      debugPrint('[AUTH] Exception Message: ${e.message}');
      debugPrint('[AUTH] Request URL: ${e.requestOptions.uri}');
      debugPrint('[AUTH] Request Method: ${e.requestOptions.method}');
      debugPrint('[AUTH] Request Headers: ${e.requestOptions.headers}');
      debugPrint('[AUTH] Request Data: ${e.requestOptions.data}');

      if (e.response != null) {
        debugPrint('[AUTH] ----------------------------------------');
        debugPrint('[AUTH] Response Status Code: ${e.response?.statusCode}');
        debugPrint('[AUTH] Response Status Message: ${e.response?.statusMessage}');
        debugPrint('[AUTH] Response Headers: ${e.response?.headers}');
        debugPrint('[AUTH] Response Data Type: ${e.response?.data.runtimeType}');
        debugPrint('[AUTH] Response Data (RAW): ${e.response?.data}');
      } else {
        debugPrint('[AUTH] Response: NULL (no response received)');
      }

      debugPrint('[AUTH] StackTrace: $stackTrace');
      debugPrint('[AUTH] ============================================');

      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Koneksi timeout. Silakan coba lagi.';
        debugPrint('[AUTH] Error Category: TIMEOUT');
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        debugPrint('[AUTH] Error Category: CONNECTION_ERROR');
      } else if (e.response != null) {
        debugPrint('[AUTH] Error Category: SERVER_RESPONSE_ERROR');
        // Try to extract error message from response
        final data = e.response?.data;
        debugPrint('[AUTH] Extracting error message from response data...');
        debugPrint('[AUTH] Data type: ${data.runtimeType}');

        if (data is Map<String, dynamic>) {
          debugPrint('[AUTH] Data keys: ${data.keys.toList()}');
          // Support various field names: message, msg, error, detail
          final msgFromMessage = data['message']?.toString();
          final msgFromMsg = data['msg']?.toString();
          final msgFromError = data['error']?.toString();
          final msgFromDetail = data['detail']?.toString();

          debugPrint('[AUTH] data["message"]: $msgFromMessage');
          debugPrint('[AUTH] data["msg"]: $msgFromMsg');
          debugPrint('[AUTH] data["error"]: $msgFromError');
          debugPrint('[AUTH] data["detail"]: $msgFromDetail');

          errorMessage = msgFromMessage ??
              msgFromMsg ??
              msgFromError ??
              msgFromDetail ??
              'Login failed';
        } else if (data is String) {
          debugPrint('[AUTH] Response is a String: $data');
          errorMessage = data.isNotEmpty ? data : 'Login failed: ${e.response?.statusCode}';
        } else {
          debugPrint('[AUTH] Response data is neither Map nor String');
          errorMessage = 'Login failed: ${e.response?.statusCode}';
        }
      } else {
        debugPrint('[AUTH] Error Category: UNKNOWN');
        errorMessage = 'Login failed: ${e.message}';
      }

      debugPrint('[AUTH] Final error message: $errorMessage');
      return AuthResult.failure(errorMessage);
    } catch (e, stackTrace) {
      debugPrint('[AUTH] ============================================');
      debugPrint('[AUTH] !!! GENERAL EXCEPTION !!!');
      debugPrint('[AUTH] Exception Type: ${e.runtimeType}');
      debugPrint('[AUTH] Exception: $e');
      debugPrint('[AUTH] StackTrace: $stackTrace');
      debugPrint('[AUTH] ============================================');
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
      final apiUrl = AppInfo.authGoogleVerificationUrl;
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
