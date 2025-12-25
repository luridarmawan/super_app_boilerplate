import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_interface.dart';
import '../constants/app_info.dart';

/// Implementasi Firebase Auth
/// CATATAN: Untuk menggunakan ini, Anda perlu menambahkan dependencies:
/// - firebase_core
/// - firebase_auth
/// - google_sign_in
/// 
/// Dan melakukan konfigurasi Firebase di project.
/// Saat ini menggunakan mock implementation untuk demo.
class FirebaseAuthProvider implements BaseAuthService {
  AuthUser? _currentUser;
  final StreamController<AuthUser?> _authStateController = 
      StreamController<AuthUser?>.broadcast();
  
  // Google Sign-In instance (singleton in v7.x)
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  FirebaseAuthProvider() {
    // Initialize dengan user kosong
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
      // TODO: Implementasi dengan firebase_auth
      // final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      
      // Mock implementation untuk demo
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulasi login berhasil
      _currentUser = AuthUser(
        uid: 'firebase_user_${DateTime.now().millisecondsSinceEpoch}',
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
      // TODO: Implementasi dengan firebase_auth
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = AuthUser(
        uid: 'firebase_user_${DateTime.now().millisecondsSinceEpoch}',
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

      // Get authentication tokens for Firebase Auth integration
      // final googleAuth = googleUser.authentication;
      
      // TODO: Use these credentials with Firebase Auth
      // final credential = GoogleAuthProvider.credential(
      //   idToken: googleUser.authentication.idToken,
      // );
      // final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // For now, create user from Google account info
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
    // TODO: Implementasi dengan firebase_auth
    // await FirebaseAuth.instance.signOut();
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<AuthResult> sendEmailVerification() async {
    try {
      // TODO: Implementasi dengan firebase_auth
      await Future.delayed(const Duration(milliseconds: 500));
      return AuthResult.success(_currentUser ?? AuthUser.empty());
    } catch (e) {
      return AuthResult.failure('Gagal mengirim email verifikasi');
    }
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      // TODO: Implementasi dengan firebase_auth
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
