import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../auth/auth_interface.dart';
import '../auth/firebase_provider.dart';
import '../auth/custom_api_provider.dart';
import '../constants/app_info.dart';

/// Keys untuk SharedPreferences
class _PrefsKeys {
  static const String locale = 'app_locale';
  static const String localeCountry = 'app_locale_country';
  static const String template = 'app_template';
  static const String isDarkMode = 'app_is_dark_mode';
  static const String sidebarPosition = 'app_sidebar_position';
}

/// Enum untuk menentukan strategi autentikasi
enum AuthStrategy { firebase, customApi }

/// Enum untuk posisi Sidebar
enum SidebarPosition { left, right }

/// Helper untuk mendapatkan default auth strategy dari AppInfo
AuthStrategy _getDefaultAuthStrategy() {
  switch (AppInfo.authProvider) {
    case 'firebase':
      return AuthStrategy.firebase;
    case 'customApi':
      return AuthStrategy.customApi;
    default:
      return AuthStrategy.customApi;
  }
}

/// State class untuk konfigurasi aplikasi
class AppConfigState {
  final AuthStrategy authStrategy;
  final SidebarPosition sidebarPosition;
  final Locale selectedLocale;
  final AppTemplate currentTemplate;
  final bool isDarkMode;

  AppConfigState({
    AuthStrategy? authStrategy,
    this.sidebarPosition = SidebarPosition.left,
    this.selectedLocale = const Locale('en', 'US'),
    this.currentTemplate = AppTemplate.defaultBlue,
    this.isDarkMode = false,
  }) : authStrategy = authStrategy ?? _getDefaultAuthStrategy();

  AppConfigState copyWith({
    AuthStrategy? authStrategy,
    SidebarPosition? sidebarPosition,
    Locale? selectedLocale,
    AppTemplate? currentTemplate,
    bool? isDarkMode,
  }) {
    return AppConfigState(
      authStrategy: authStrategy ?? this.authStrategy,
      sidebarPosition: sidebarPosition ?? this.sidebarPosition,
      selectedLocale: selectedLocale ?? this.selectedLocale,
      currentTemplate: currentTemplate ?? this.currentTemplate,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  /// Mendapatkan ThemeData berdasarkan template dan mode
  ThemeData get themeData => AppTheme.getTheme(
        currentTemplate,
        isDark: isDarkMode || currentTemplate == AppTemplate.darkMode,
      );
}

/// Notifier untuk mengelola konfigurasi aplikasi dengan persistensi
class AppConfigNotifier extends StateNotifier<AppConfigState> {
  SharedPreferences? _prefs;

  AppConfigNotifier() : super(AppConfigState()) {
    _loadFromPrefs();
  }

  /// Memuat pengaturan dari SharedPreferences
  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    // Load locale
    final localeCode = _prefs?.getString(_PrefsKeys.locale);
    final localeCountry = _prefs?.getString(_PrefsKeys.localeCountry);
    Locale? savedLocale;
    if (localeCode != null) {
      savedLocale = Locale(localeCode, localeCountry ?? '');
    }

    // Load template
    final templateIndex = _prefs?.getInt(_PrefsKeys.template);
    AppTemplate? savedTemplate;
    if (templateIndex != null && templateIndex < AppTemplate.values.length) {
      savedTemplate = AppTemplate.values[templateIndex];
    }

    // Load dark mode
    final savedDarkMode = _prefs?.getBool(_PrefsKeys.isDarkMode);

    // Load sidebar position
    final sidebarIndex = _prefs?.getInt(_PrefsKeys.sidebarPosition);
    SidebarPosition? savedSidebarPosition;
    if (sidebarIndex != null && sidebarIndex < SidebarPosition.values.length) {
      savedSidebarPosition = SidebarPosition.values[sidebarIndex];
    }

    // Update state dengan pengaturan tersimpan
    state = state.copyWith(
      selectedLocale: savedLocale,
      currentTemplate: savedTemplate,
      isDarkMode: savedDarkMode,
      sidebarPosition: savedSidebarPosition,
    );
  }

  /// Menyimpan pengaturan ke SharedPreferences
  Future<void> _saveToPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs?.setString(_PrefsKeys.locale, state.selectedLocale.languageCode);
    await _prefs?.setString(_PrefsKeys.localeCountry, state.selectedLocale.countryCode ?? '');
    await _prefs?.setInt(_PrefsKeys.template, state.currentTemplate.index);
    await _prefs?.setBool(_PrefsKeys.isDarkMode, state.isDarkMode);
    await _prefs?.setInt(_PrefsKeys.sidebarPosition, state.sidebarPosition.index);
  }

  void setSidebarPosition(SidebarPosition position) {
    state = state.copyWith(sidebarPosition: position);
    _saveToPrefs();
  }

  void setLocale(Locale locale) {
    state = state.copyWith(selectedLocale: locale);
    _saveToPrefs();
  }

  void setTemplate(AppTemplate template) {
    state = state.copyWith(currentTemplate: template);
    _saveToPrefs();
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _saveToPrefs();
  }

  void setDarkMode(bool isDark) {
    state = state.copyWith(isDarkMode: isDark);
    _saveToPrefs();
  }
}

/// Provider untuk konfigurasi aplikasi
final appConfigProvider = StateNotifierProvider<AppConfigNotifier, AppConfigState>(
  (ref) => AppConfigNotifier(),
);

/// Provider untuk Auth Service
final authServiceProvider = Provider<BaseAuthService>((ref) {
  final config = ref.watch(appConfigProvider);
  switch (config.authStrategy) {
    case AuthStrategy.firebase:
      return FirebaseAuthProvider();
    case AuthStrategy.customApi:
      return CustomApiAuthProvider(
        baseUrl: 'https://api.example.com',
      );
  }
});

/// Provider untuk auth state
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider untuk current user
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// Provider untuk cek apakah user sudah login
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null && user.isNotEmpty;
});

/// Provider untuk ThemeData
final themeProvider = Provider<ThemeData>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.themeData;
});

/// Provider untuk locale
final localeProvider = Provider<Locale>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.selectedLocale;
});

/// Provider untuk sidebar position
final sidebarPositionProvider = Provider<SidebarPosition>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.sidebarPosition;
});