import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_info.dart';

/// Service untuk mengelola Remote Config (Firebase atau Custom API).
///
/// Fitur ini dapat dinonaktifkan melalui .env:
///   REMOTE_CONFIG_ENABLE=false
///
/// Jika REMOTE_CONFIG_CUSTOM_URL berisi URL, maka akan menggunakan custom API.
/// Jika tidak, akan menggunakan Firebase Remote Config sebagai default.
class RemoteConfigService {
  RemoteConfigService._();

  static FirebaseRemoteConfig? _instance;
  static Map<String, dynamic> _customConfig = {};
  static bool _useCustom = false;

  /// Default values untuk semua parameter Remote Config.
  /// Digunakan saat offline atau sebelum fetch pertama berhasil.
  static const Map<String, dynamic> _defaults = {
    'ai_provider': 'carik',
    'latest_version': '',
    'widget_location_enable': true,
    'maintenance_mode': false,
    'force_update': false,
    'update_url': '',
    'min_version': '',
  };

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Inisialisasi Remote Config. Panggil dari main().
  static Future<void> initialize() async {
    if (!AppInfo.remoteConfigEnable) {
      debugPrint('[RemoteConfig] ⛔ Disabled via REMOTE_CONFIG_ENABLE=false, skipping.');
      return;
    }

    final customUrl = AppInfo.remoteConfigCustomURL;
    if (customUrl.isNotEmpty) {
      _useCustom = true;
      debugPrint('[RemoteConfig] 🌐 Using Custom Remote Config: $customUrl');
      await _fetchCustomConfig(customUrl);
    } else {
      _useCustom = false;
      debugPrint('[RemoteConfig] 🔥 Using Firebase Remote Config...');
      await _initializeFirebase();
    }
  }

  static Future<void> _initializeFirebase() async {
    try {
      _instance = FirebaseRemoteConfig.instance;

      // Set default values agar app bisa berjalan sebelum fetch selesai
      await _instance!.setDefaults(_defaults);
      debugPrint('[RemoteConfig] 📋 Firebase defaults loaded.');

      // Konfigurasi fetch interval
      final fetchInterval = AppInfo.isProduction
          ? const Duration(hours: 1)
          : const Duration(seconds: 0);

      await _instance!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: fetchInterval,
      ));

      // Fetch dan aktifkan nilai terbaru
      final updated = await _instance!.fetchAndActivate();
      debugPrint('[RemoteConfig] Firebase: ${updated ? "🆕 New values fetched." : "🔁 Using cached config."}');
    } catch (e) {
      debugPrint('[RemoteConfig] ❌ Firebase initialization error (non-fatal): $e');
    }
  }

  static Future<void> _fetchCustomConfig(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get(url);
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('parameters')) {
          final params = data['parameters'] as Map<String, dynamic>;
          final flattened = <String, dynamic>{};
          
          params.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              // Mencoba mengambil dari 'value' atau 'defaultValue.value'
              final val = value['value'] ?? value['defaultValue']?['value'];
              if (val != null) {
                flattened[key] = val;
                // debugPrint('[RemoteConfig]    $key = $val');
              }
            }
          });
          
          _customConfig = flattened;
          debugPrint('[RemoteConfig] ✅ Custom config fetched successfully (${_customConfig.length} params).');
        } else {
          debugPrint('[RemoteConfig] ⚠️ Invalid custom config format.');
        }
      } else {
        debugPrint('[RemoteConfig] ❌ Failed to fetch custom config: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[RemoteConfig] ❌ Error fetching custom config: $e');
    }
  }

  // ============================================
  // GETTERS – PARAMETER TERTENTU
  // ============================================

  static String get aiProvider => getString('ai_provider');
  static String get latestVersion => getString('latest_version');
  static bool get widgetLocationEnable => getBool('widget_location_enable');
  static bool get maintenanceMode => getBool('maintenance_mode');

  // ============================================
  // REALTIME FETCH (TANPA CACHE)
  // ============================================

  /// Fetch nilai terbaru tanpa mengandalkan cache.
  static Future<bool> fetchRealtime() async {
    if (!AppInfo.remoteConfigEnable) return false;

    if (_useCustom) {
      final oldSize = _customConfig.length;
      await _fetchCustomConfig(AppInfo.remoteConfigCustomURL);
      return _customConfig.length != oldSize; // Simple check if updated
    }

    if (_instance == null) return false;

    try {
      await _instance!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: Duration.zero,
      ));
      await _instance!.fetch();
      return await _instance!.activate();
    } catch (e) {
      debugPrint('[RemoteConfig] ❌ fetchRealtime() error: $e');
      return false;
    }
  }

  static Future<bool> fetchMaintenanceMode() async {
    await fetchRealtime();
    return maintenanceMode;
  }

  static Future<String> fetchString(String key) async {
    await fetchRealtime();
    return getString(key);
  }

  static Future<bool> fetchBool(String key) async {
    await fetchRealtime();
    return getBool(key);
  }

  // ============================================
  // GETTERS – GENERIK
  // ============================================

  static String getString(String key) {
    if (_useCustom) {
      final val = _customConfig[key];
      if (val != null) return val.toString();
      return _defaults[key]?.toString() ?? '';
    }

    if (_instance == null) return _defaults[key]?.toString() ?? '';
    return _instance!.getString(key);
  }

  static bool getBool(String key) {
    if (_useCustom) {
      final val = _customConfig[key];
      if (val != null) {
        if (val is bool) return val;
        if (val is String) return val.toLowerCase() == 'true';
      }
      final def = _defaults[key];
      return def is bool ? def : false;
    }

    if (_instance == null) {
      final def = _defaults[key];
      return def is bool ? def : false;
    }
    return _instance!.getBool(key);
  }

  static int getInt(String key) {
    if (_useCustom) {
      final val = _customConfig[key];
      if (val != null) {
        if (val is int) return val;
        if (val is String) return int.tryParse(val) ?? 0;
      }
      final def = _defaults[key];
      return def is int ? def : 0;
    }

    if (_instance == null) {
      final def = _defaults[key];
      return def is int ? def : 0;
    }
    return _instance!.getInt(key);
  }

  static double getDouble(String key) {
    if (_useCustom) {
      final val = _customConfig[key];
      if (val != null) {
        if (val is double) return val;
        if (val is String) return double.tryParse(val) ?? 0.0;
      }
      final def = _defaults[key];
      return def is double ? def : 0.0;
    }

    if (_instance == null) {
      final def = _defaults[key];
      return def is double ? def : 0.0;
    }
    return _instance!.getDouble(key);
  }
}
