/// Model untuk data user
class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;

  AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
  });

  factory AuthUser.empty() {
    return AuthUser(uid: '');
  }

  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => !isEmpty;

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isEmailVerified,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

/// Hasil dari operasi autentikasi
class AuthResult {
  final bool success;
  final AuthUser? user;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(AuthUser user) {
    return AuthResult(success: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, errorMessage: message);
  }
}

/// Abstract class untuk Auth Service
/// Implementasikan interface ini untuk berbagai provider (Firebase, Custom API, dll)
abstract class BaseAuthService {
  /// Stream untuk mendengarkan perubahan status autentikasi
  Stream<AuthUser?> get authStateChanges;

  /// User yang sedang login saat ini
  AuthUser? get currentUser;

  /// Login dengan email dan password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registrasi dengan email dan password
  Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Login dengan Google OAuth
  Future<AuthResult> signInWithGoogle();

  /// Logout
  Future<void> signOut();

  /// Kirim email verifikasi
  Future<AuthResult> sendEmailVerification();

  /// Kirim email reset password
  Future<AuthResult> sendPasswordResetEmail(String email);

  /// Update profil user
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Dispose resources
  void dispose();
}
