import 'package:flutter/foundation.dart';

import 'auth_interface.dart';
import 'carik_auth_provider.dart';
import 'custom_api_provider.dart';
import 'firebase_provider.dart';

/// Pembuat instance auth provider.
typedef AuthProviderFactory = BaseAuthService Function();

/// Registry auth provider. Provider dipilih developer lewat `AUTH_PROVIDER` di `.env`;
/// provider baru cukup didaftarkan di sini (atau lewat [register] sebelum app berjalan),
/// tanpa mengubah layar login maupun modul.
class AuthProviders {
  AuthProviders._();

  /// Dipakai bila `AUTH_PROVIDER` kosong atau tidak dikenal.
  static const String defaultId = 'customApi';

  static final Map<String, AuthProviderFactory> _factories = {
    // Backend WordPress dengan plugin Simple JWT Login (perilaku lama, tidak berubah).
    'customApi': () => CustomApiAuthProvider(),
    'simpleJwtLogin': () => CustomApiAuthProvider(),
    // Backend Carik (dashboard boilerplate): token Bearer dari /v1/auth/token.
    'carik': () => CarikAuthProvider(),
    'firebase': () => FirebaseAuthProvider(),
  };

  /// Id provider yang tersedia.
  static Iterable<String> get ids => _factories.keys;

  /// Daftarkan (atau timpa) provider dengan [id].
  static void register(String id, AuthProviderFactory factory) {
    _factories[id] = factory;
  }

  /// Buat provider untuk [id]; id yang tidak dikenal jatuh ke [defaultId].
  static BaseAuthService create(String id) {
    final factory = _factories[id];
    if (factory == null) {
      debugPrint('[AUTH] AUTH_PROVIDER "$id" tidak dikenal, memakai "$defaultId"');
      return _factories[defaultId]!();
    }
    return factory();
  }
}
