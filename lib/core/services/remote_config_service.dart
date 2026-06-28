import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_info.dart';
import '../l10n/app_localizations.dart';

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
  static bool get forceUpdate => getBool('force_update');
  static String get updateUrl => getString('update_url');

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

  // ============================================
  // UPDATE CHECK
  // ============================================

  /// Cek apakah ada update aplikasi.
  /// Jika `latest_version` berbeda dengan versi saat ini,
  /// tampilkan dialog informasi update.
  ///
  /// Panggil dari screen utama (misal: dashboard) setelah init.
  /// ```dart
  /// RemoteConfigService.checkForUpdate(context);
  /// ```
  static void checkForUpdate(BuildContext context) {
    if (!AppInfo.remoteConfigEnable) return;

    final latest = latestVersion;
    if (latest.isEmpty) return;

    // Bandingkan hanya bagian version (sebelum '+') agar build number tidak ikut dibandingkan
    final currentVersion = AppInfo.version; // e.g. "1.0.3"
    final latestClean = latest.contains('+') ? latest.split('+').first : latest;

    if (latestClean == currentVersion) return;

    debugPrint('[RemoteConfig] 🔔 Update available: $currentVersion → $latestClean');

    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.system_update_outlined, size: 48),
        title: Text(l10n.updateAvailableTitle),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        content: Text(
          l10n.updateAvailableDescription
              .replaceAll('{version}', latestClean),
        ),
        actions: [
          // button "Update App" — dominan
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final url = updateUrl;
                if (url.isNotEmpty) {
                  launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                }
                if (!forceUpdate) {
                  Navigator.of(dialogContext).pop();
                }
              },
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.updateNow),
            ),
          ),
          // button "Dismiss" — hanya tampil jika bukan force update
          if (!forceUpdate) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.updateDismiss),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
