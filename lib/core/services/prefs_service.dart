import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service for SharedPreferences to avoid multiple instance creation.
/// This significantly improves startup performance by caching the instance.
class PrefsService {
  PrefsService._();
  
  static PrefsService? _instance;
  static SharedPreferences? _prefs;
  
  /// Get the singleton instance
  static PrefsService get instance {
    _instance ??= PrefsService._();
    return _instance!;
  }
  
  /// Initialize SharedPreferences (call once at app startup)
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// Get the cached SharedPreferences instance
  /// Must call initialize() first in main()
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError(
        'PrefsService not initialized. Call PrefsService.initialize() in main() first.',
      );
    }
    return _prefs!;
  }
  
  // ============================================
  // AUTH KEYS
  // ============================================
  
  static const String isLoggedInKey = 'app_is_logged_in';
  static const String userDataKey = 'app_user_data';
  
  // ============================================
  // AUTH METHODS
  // ============================================
  
  /// Check if user is logged in
  bool get isLoggedIn => prefs.getBool(isLoggedInKey) ?? false;
  
  /// Set logged in status
  Future<void> setLoggedIn(bool value) async {
    await prefs.setBool(isLoggedInKey, value);
  }
  
  /// Get user data JSON string
  String? get userData => prefs.getString(userDataKey);
  
  /// Set user data JSON string
  Future<void> setUserData(String? value) async {
    if (value == null) {
      await prefs.remove(userDataKey);
    } else {
      await prefs.setString(userDataKey, value);
    }
  }
  
  /// Clear all auth data (for logout)
  Future<void> clearAuthData() async {
    await prefs.remove(isLoggedInKey);
    await prefs.remove(userDataKey);
  }

  // ============================================
  // SPLASH SCREEN KEYS
  // ============================================

  static const String splashOpenCountKey = 'app_splash_open_count';
  static const String lastOpenedTimeKey = 'app_last_opened_time';

  // ============================================
  // SPLASH SCREEN METHODS
  // ============================================

  /// Get the number of times app has been opened
  int get splashOpenCount => prefs.getInt(splashOpenCountKey) ?? 0;

  /// Increment and save the splash open count
  Future<void> incrementSplashOpenCount() async {
    final currentCount = splashOpenCount;
    await prefs.setInt(splashOpenCountKey, currentCount + 1);
  }

  /// Get the last opened time as DateTime
  DateTime? get lastOpenedTime {
    final timestamp = prefs.getInt(lastOpenedTimeKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Save the current time as last opened time
  Future<void> updateLastOpenedTime() async {
    await prefs.setInt(lastOpenedTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Determine if splash screen should be shown
  /// Logic:
  /// 1. Show splash on first [showCount] app launches
  /// 2. After that, show splash only if app hasn't been opened for [delayHours] hours
  bool shouldShowSplash(int showCount, int delayHours) {
    final openCount = splashOpenCount;

    // Always show splash for the first [showCount] launches
    if (openCount < showCount) {
      return true;
    }

    // After initial launches, show splash only if inactive for [delayHours] hours
    final lastOpened = lastOpenedTime;
    if (lastOpened == null) {
      return true;
    }

    final hoursSinceLastOpen = DateTime.now().difference(lastOpened).inHours;
    return hoursSinceLastOpen >= delayHours;
  }

  /// Call this when splash screen is shown or skipped (updates counters)
  Future<void> recordAppOpen() async {
    await incrementSplashOpenCount();
    await updateLastOpenedTime();
  }
}

/// Provider for PrefsService
final prefsServiceProvider = Provider<PrefsService>((ref) {
  return PrefsService.instance;
});

/// Provider for checking if user is logged in (sync, no Future)
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(prefsServiceProvider).isLoggedIn;
});
