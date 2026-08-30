import 'dart:convert';

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
  static Map<String, dynamic> _versionInfo = {};
  static bool _useCustom = false;
  static bool _updateDialogShown = false;

  /// Default values untuk semua parameter Remote Config.
  /// Digunakan saat offline atau sebelum fetch pertama berhasil.
  static const Map<String, dynamic> _defaults = {
    'ai_provider': 'carik',
    'latest_version': '',
    'latest_version_number': 0,
    'minimum_version_number': 0,
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
        // Sebagian server mengirim JSON sebagai text/plain — decode manual bila perlu.
        final raw = response.data;
        final data = raw is String ? jsonDecode(raw) : raw;

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

          // Blok `version` di root JSON — sumber build number terbaru & minimum.
          final version = data['version'];
          _versionInfo = version is Map<String, dynamic> ? version : {};

          debugPrint('[RemoteConfig] ✅ Custom config fetched successfully (${_customConfig.length} params).');
          debugPrint('[RemoteConfig] 📦 build: current=$currentVersionNumber, latest=$latestVersionNumber, minimum=$minimumVersionNumber');
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
  // VERSION / BUILD NUMBER
  // ============================================

  /// Build number aplikasi yang sedang berjalan.
  /// Contoh: pubspec `version: 1.1.5+84` → 84.
  static int get currentVersionNumber => int.tryParse(AppInfo.buildNumber.trim()) ?? 0;

  /// Build number versi terbaru yang tersedia.
  ///
  /// Urutan prioritas sumber nilai:
  /// 1. parameter `latest_version_number`
  /// 2. suffix build pada parameter `latest_version` (mis. `1.1.6+92` → 92)
  /// 3. `version.versionNumber` pada root JSON custom remote config
  static int get latestVersionNumber {
    final param = getInt('latest_version_number');
    if (param > 0) return param;

    final fromLatestVersion = _buildNumberOf(latestVersion);
    if (fromLatestVersion > 0) return fromLatestVersion;

    return _toInt(_versionInfo['versionNumber']);
  }

  /// Build number minimum yang masih boleh dipakai.
  /// Di bawah nilai ini user **wajib** update (dialog tidak bisa ditutup).
  ///
  /// Urutan prioritas sumber nilai:
  /// 1. parameter `minimum_version_number` (alias: `min_version_number`)
  /// 2. suffix build pada parameter `min_version` (mis. `1.1.6+92` → 92)
  /// 3. `version.minimumVersionNumber` pada root JSON custom remote config
  static int get minimumVersionNumber {
    final param = getInt('minimum_version_number');
    if (param > 0) return param;

    final alias = getInt('min_version_number');
    if (alias > 0) return alias;

    final fromMinVersion = _buildNumberOf(getString('min_version'));
    if (fromMinVersion > 0) return fromMinVersion;

    return _toInt(_versionInfo['minimumVersionNumber']);
  }

  /// Tersedia versi yang lebih baru dari versi yang sedang berjalan.
  static bool get isUpdateAvailable {
    final current = currentVersionNumber;
    final latest = latestVersionNumber;
    if (current <= 0 || latest <= 0) return false;
    return current < latest;
  }

  /// Update bersifat wajib — user tidak boleh melanjutkan tanpa update.
  ///
  /// Wajib bila salah satu terpenuhi:
  /// 1. `force_update = true` **dan** ada versi lebih baru — berlaku walaupun
  ///    build number saat ini masih memenuhi [minimumVersionNumber].
  /// 2. build number saat ini di bawah [minimumVersionNumber].
  static bool get isUpdateRequired {
    final current = currentVersionNumber;
    if (current <= 0) return false;

    // force_update memaksa update selama masih ada versi yang lebih baru.
    if (forceUpdate && isUpdateAvailable) return true;

    final minimum = minimumVersionNumber;
    return minimum > 0 && current < minimum;
  }

  /// Ambil build number dari string versi, mis. `1.1.6+92` → 92.
  /// Mengembalikan 0 bila tidak ada suffix build.
  static int _buildNumberOf(String version) {
    if (!version.contains('+')) return 0;
    return int.tryParse(version.split('+').last.trim()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  // ============================================
  // UPDATE CHECK
  // ============================================

  /// Cek update aplikasi berdasarkan **build number**.
  ///
  /// - `buildNumber < minimumVersionNumber` → update **wajib**: dialog tidak
  ///   bisa ditutup (barrier & tombol back dimatikan), hanya ada tombol update.
  /// - `buildNumber < latestVersionNumber` → update **opsional**: user memilih
  ///   update sekarang, atau tetap lanjut memakai aplikasi tanpa update.
  ///
  /// Dialog hanya tampil sekali per sesi aplikasi; gunakan `force: true`
  /// untuk menampilkannya lagi (mis. dari menu "Cek pembaruan").
  ///
  /// Panggil dari screen utama (misal: dashboard) setelah init.
  /// ```dart
  /// RemoteConfigService.checkForUpdate(context);
  /// ```
  static void checkForUpdate(BuildContext context, {bool force = false}) {
    if (!AppInfo.remoteConfigEnable) return;
    if (_updateDialogShown && !force) return;

    final mandatory = isUpdateRequired;
    if (!mandatory && !isUpdateAvailable) return;

    final currentText = '${AppInfo.version} ($currentVersionNumber)';
    final latestText = _latestVersionLabel();

    debugPrint(
      '[RemoteConfig] 🔔 Update ${mandatory ? "required" : "available"}: $currentText → $latestText',
    );

    _updateDialogShown = true;
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: !mandatory,
      builder: (dialogContext) => PopScope(
        // Update wajib: tombol back tidak boleh menutup dialog.
        canPop: !mandatory,
        child: AlertDialog(
          icon: const Icon(Icons.system_update_outlined, size: 48),
          title: Text(mandatory ? l10n.updateRequiredTitle : l10n.updateAvailableTitle),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          content: Text(
            (mandatory ? l10n.updateRequiredDescription : l10n.updateAvailableDescription)
                .replaceAll('{version}', latestText)
                .replaceAll('{currentVersion}', currentText),
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
                  // Pada update wajib dialog tetap terbuka sampai user update.
                  if (!mandatory) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                icon: const Icon(Icons.download_outlined),
                label: Text(l10n.updateNow),
              ),
            ),
            // button "lanjut tanpa update" — hanya untuk update opsional
            if (!mandatory) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.updateContinue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Label versi terbaru untuk ditampilkan, mis. `1.1.6 (92)`.
  static String _latestVersionLabel() {
    final latest = latestVersion;
    final number = latestVersionNumber;
    final name = latest.contains('+') ? latest.split('+').first : latest;

    if (name.isEmpty) return number > 0 ? 'build $number' : '';
    return number > 0 ? '$name ($number)' : name;
  }
}
