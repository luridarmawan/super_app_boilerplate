import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:module_interface/module_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_interface.dart';

/// Singleton refresh JWT token, dipakai bersama aplikasi utama dan modul.
///
/// Implementasinya ada di `package:module_interface` supaya modul dan aplikasi memakai SATU
/// instance yang sama: refresh yang dipicu modul ikut memakai handler auth provider aktif
/// (mis. `CarikAuthProvider`) dan auto-logout yang sama. Berkas ini tetap ada agar import lama
/// (`core/auth/token_refresh_service.dart`) tidak berubah.
export 'package:module_interface/module_interface.dart' show TokenRefreshService;

/// Tambahan khusus aplikasi utama (butuh [AuthUser]).
extension TokenRefreshStoredUser on TokenRefreshService {
  /// User tersimpan beserta JWT terbarunya.
  Future<AuthUser?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString('app_saved_user');

      if (savedUserJson != null && savedUserJson.isNotEmpty) {
        final userMap = jsonDecode(savedUserJson) as Map<String, dynamic>;
        return AuthUser.fromJson(userMap);
      }
      return null;
    } catch (e) {
      debugPrint('[TOKEN-REFRESH] Error getting stored user: $e');
      return null;
    }
  }
}
