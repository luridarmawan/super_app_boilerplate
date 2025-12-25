import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
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

  CustomApiAuthProvider({
    this.baseUrl,
    this.headers,
  }) {
    _currentUser = null;
    _authStateController.add(null);
    _initGoogleSignIn();
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
      
      _authStateController.add(_currentUser);
      return AuthResult.success(_currentUser!);
    } catch (e) {
      return AuthResult.failure('Registrasi gagal: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Ensure Google Sign-In is initialized
      await _initGoogleSignIn();
      
      // Check if authenticate is supported
      if (!_googleSignIn.supportsAuthenticate()) {
        return AuthResult.failure('Google Sign-In tidak didukung di platform ini');
      }
      
      // Trigger Google Sign-In flow (v7.x API)
      // Note: In v7.x, authenticate() throws on cancel instead of returning null
      final googleUser = await _googleSignIn.authenticate();

      // Get authentication tokens if needed for backend verification
      // final googleAuth = googleUser.authentication;
      // final idToken = googleAuth.idToken;

      // TODO: Send idToken to your backend API for verification
      // Example:
      // final response = await http.post(
      //   Uri.parse('$baseUrl/auth/google'),
      //   headers: {'Content-Type': 'application/json', ...?headers},
      //   body: jsonEncode({'idToken': idToken}),
      // );

      // Create user from Google account info
      _currentUser = AuthUser(
        uid: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        isEmailVerified: true,
      );
      
      _authStateController.add(_currentUser);
      return AuthResult.success(_currentUser!);
    } catch (e) {
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
    // TODO: Implementasi logout ke backend
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
