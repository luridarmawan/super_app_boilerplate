import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_info.dart';

/// Service untuk mengelola Firebase Remote Config.
///
/// Fitur ini dapat dinonaktifkan melalui .env:
///   REMOTE_CONFIG_ENABLE=false
///
/// Parameter yang tersedia di Firebase Console:
///   - ai_provider    : string (nama AI provider yang digunakan)
///   - latest_version : string (versi terbaru aplikasi, e.g. "1.2.0")
class RemoteConfigService {
  RemoteConfigService._();

  static FirebaseRemoteConfig? _instance;

  /// Default values untuk semua parameter Remote Config.
  /// Digunakan saat offline atau sebelum fetch pertama berhasil.
  static const Map<String, dynamic> _defaults = {
    'ai_provider': 'carik',
    'latest_version': '',
    'widget_location_enable': true,
    'maintenance_mode': false,
  };

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Inisialisasi Remote Config. Panggil dari main() setelah Firebase.initializeApp().
  /// Tidak melakukan apa-apa jika REMOTE_CONFIG_ENABLE=false.
  static Future<void> initialize() async {
    if (!AppInfo.remoteConfigEnable) {
      debugPrint('[RemoteConfig] ⛔ Disabled via REMOTE_CONFIG_ENABLE=false, skipping.');
      return;
    }

    debugPrint('[RemoteConfig] ✅ REMOTE_CONFIG_ENABLE=true — starting initialization...');

    try {
      _instance = FirebaseRemoteConfig.instance;

      // Set default values agar app bisa berjalan sebelum fetch selesai
      await _instance!.setDefaults(_defaults);
      debugPrint('[RemoteConfig] 📋 Defaults loaded:');
      _defaults.forEach((key, value) {
        debugPrint('[RemoteConfig]    $key = $value');
      });

      // Konfigurasi fetch interval
      // - Production : 1 jam (sesuai Firebase quota)
      // - Development: 0 detik (langsung fetch setiap kali untuk debugging)
      final fetchInterval = AppInfo.isProduction
          ? const Duration(hours: 1)
          : const Duration(seconds: 0);
      final env = AppInfo.isProduction ? 'production (1h)' : 'development (0s)';
      debugPrint('[RemoteConfig] ⏱  Fetch interval: $env');

      await _instance!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: fetchInterval,
      ));

      // Fetch dan aktifkan nilai terbaru
      debugPrint('[RemoteConfig] 🔄 Fetching from Firebase Console...');
      final updated = await _instance!.fetchAndActivate();
      debugPrint('[RemoteConfig] ${updated ? "🆕 New values fetched and activated." : "🔁 No new values — cached config used."}');

      // Cetak semua parameter yang dikenal
      debugPrint('[RemoteConfig] 📦 Active parameter values:');
      debugPrint('[RemoteConfig]    ai_provider    = "${getString('ai_provider')}"');
      debugPrint('[RemoteConfig]    latest_version = "${getString('latest_version')}"');
      debugPrint('[RemoteConfig]    widget_location_enable = "${getBool('widget_location_enable')}"');
    } catch (e) {
      // Jangan crash app jika Remote Config gagal (offline, quota habis, dll.)
      debugPrint('[RemoteConfig] ❌ Initialization error (non-fatal): $e');
    }
  }

  // ============================================
  // GETTERS – PARAMETER TERTENTU
  // ============================================

  /// AI provider yang dikonfigurasi dari Firebase Console.
  /// Returns empty string jika Remote Config dinonaktifkan atau belum di-fetch.
  static String get aiProvider => getString('ai_provider');

  /// Versi terbaru aplikasi yang dikonfigurasi dari Firebase Console.
  /// Returns empty string jika Remote Config dinonaktifkan atau belum di-fetch.
  /// Gunakan untuk menampilkan notifikasi update ke pengguna.
  static String get latestVersion => getString('latest_version');

  static bool get widgetLocationEnable => getBool('widget_location_enable');

  // ============================================
  // GETTERS – GENERIK
  // ============================================

  /// Mendapatkan nilai string dari Remote Config.
  /// Fallback ke nilai default jika Remote Config tidak aktif.
  static String getString(String key) {
    if (_instance == null) {
      final defaultVal = _defaults[key];
      final result = defaultVal is String ? defaultVal : '';
      // debugPrint('[RemoteConfig] getString("$key") → default: "$result" (service not initialized)');
      return result;
    }
    final result = _instance!.getString(key);
    // if (kDebugMode) debugPrint('[RemoteConfig] getString("$key") → "$result"');
    return result;
  }

  /// Mendapatkan nilai bool dari Remote Config.
  static bool getBool(String key) {
    if (_instance == null) {
      final defaultVal = _defaults[key];
      return defaultVal is bool ? defaultVal : false;
    }
    return _instance!.getBool(key);
  }

  /// Mendapatkan nilai int dari Remote Config.
  static int getInt(String key) {
    if (_instance == null) {
      final defaultVal = _defaults[key];
      return defaultVal is int ? defaultVal : 0;
    }
    return _instance!.getInt(key);
  }

  /// Mendapatkan nilai double dari Remote Config.
  static double getDouble(String key) {
    if (_instance == null) {
      final defaultVal = _defaults[key];
      return defaultVal is double ? defaultVal : 0.0;
    }
    return _instance!.getDouble(key);
  }
}
