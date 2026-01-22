import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart' as dio_cookie;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// App Cookie Manager for API Client
/// Provides cookie management functionality that can be shared across the app
///
/// Usage:
/// 1. Initialize in main.dart: await AppCookieManager.instance.initialize();
/// 2. Access cookie jar: AppCookieManager.instance.cookieJar
/// 3. Create interceptor: AppCookieManager.instance.createInterceptor()
class AppCookieManager {
  AppCookieManager._();

  static final AppCookieManager instance = AppCookieManager._();

  CookieJar? _cookieJar;
  bool _initialized = false;

  /// Get the cookie jar instance
  /// Returns null if not initialized or cookies are disabled
  CookieJar? get cookieJar => _cookieJar;

  /// Check if cookie manager is initialized
  bool get isInitialized => _initialized;

  /// Initialize the cookie manager with persistent storage
  /// Call this in main.dart after WidgetsFlutterBinding.ensureInitialized()
  ///
  /// [usePersistentCookies] - If true, cookies are stored on disk and persist across app restarts
  Future<void> initialize({bool usePersistentCookies = true}) async {
    if (_initialized) {
      _debugLog('AppCookieManager already initialized');
      return;
    }

    try {
      if (usePersistentCookies) {
        // Use persistent cookie storage
        final directory = await getApplicationDocumentsDirectory();
        final cookiePath = '${directory.path}/.cookies/';

        // Ensure directory exists
        final cookieDir = Directory(cookiePath);
        if (!await cookieDir.exists()) {
          await cookieDir.create(recursive: true);
        }

        _cookieJar = PersistCookieJar(
          ignoreExpires: false,
          storage: FileStorage(cookiePath),
        );
        _debugLog('Initialized with persistent cookies at: $cookiePath');
      } else {
        // Use in-memory cookie storage (cookies cleared on app restart)
        _cookieJar = CookieJar();
        _debugLog('Initialized with in-memory cookies');
      }

      _initialized = true;
    } catch (e) {
      _debugLog('Failed to initialize: $e');
      // Fallback to in-memory cookies
      _cookieJar = CookieJar();
      _initialized = true;
    }
  }

  /// Create a Dio interceptor for cookie management
  /// Add this interceptor to Dio instance to enable automatic cookie handling
  Interceptor? createInterceptor() {
    if (_cookieJar == null) {
      _debugLog('Cannot create interceptor: CookieJar not initialized');
      return null;
    }
    return dio_cookie.CookieManager(_cookieJar!);
  }

  /// Get cookies for a specific URI
  Future<List<Cookie>> getCookies(Uri uri) async {
    if (_cookieJar == null) return [];
    return await _cookieJar!.loadForRequest(uri);
  }

  /// Get cookies as a formatted string for a specific URL
  Future<String> getCookieString(String url) async {
    final uri = Uri.parse(url);
    final cookies = await getCookies(uri);
    return cookies.map((c) => '${c.name}=${c.value}').join('; ');
  }

  /// Get a specific cookie value by name for a URL
  Future<String?> getCookieValue(String url, String cookieName) async {
    final uri = Uri.parse(url);
    final cookies = await getCookies(uri);
    try {
      final cookie = cookies.firstWhere((c) => c.name == cookieName);
      return cookie.value;
    } catch (_) {
      return null;
    }
  }

  /// Set a cookie for a specific URI
  Future<void> setCookie(Uri uri, Cookie cookie) async {
    if (_cookieJar == null) return;
    await _cookieJar!.saveFromResponse(uri, [cookie]);
    _debugLog('Cookie set: ${cookie.name}=${cookie.value} for ${uri.host}');
  }

  /// Clear all cookies
  Future<void> clearCookies() async {
    if (_cookieJar == null) return;
    await _cookieJar!.deleteAll();
    _debugLog('All cookies cleared');
  }

  /// Clear cookies for a specific domain
  Future<void> clearCookiesForDomain(String domain) async {
    if (_cookieJar == null) return;
    final uri = Uri.parse('https://$domain');
    await _cookieJar!.delete(uri);
    _debugLog('Cookies cleared for domain: $domain');
  }

  /// Debug log helper
  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[AppCookieManager] $message');
    }
  }
}

/// Alias for backward compatibility
typedef CookieManager = AppCookieManager;

/// Extension to easily add cookie manager to Dio
extension DioWithCookies on Dio {
  /// Add cookie management to this Dio instance
  /// Returns true if successful, false if CookieManager not initialized
  bool addCookieManager() {
    final interceptor = AppCookieManager.instance.createInterceptor();
    if (interceptor != null) {
      interceptors.add(interceptor);
      return true;
    }
    return false;
  }
}
