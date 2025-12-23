import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../auth/auth_interface.dart';
import '../auth/firebase_provider.dart';
import '../auth/custom_api_provider.dart';

/// Enum untuk menentukan strategi autentikasi
enum AuthStrategy { firebase, customApi }

/// Enum untuk posisi Sidebar
enum SidebarPosition { left, right }

/// State class untuk konfigurasi aplikasi
class AppConfigState {
  final AuthStrategy authStrategy;
  final SidebarPosition sidebarPosition;
  final Locale selectedLocale;
  final AppTemplate currentTemplate;
  final bool isDarkMode;

  const AppConfigState({
    this.authStrategy = AuthStrategy.firebase,
    this.sidebarPosition = SidebarPosition.left,
    this.selectedLocale = const Locale('id', 'ID'),
    this.currentTemplate = AppTemplate.defaultBlue,
    this.isDarkMode = false,
  });

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

/// Notifier untuk mengelola konfigurasi aplikasi
class AppConfigNotifier extends StateNotifier<AppConfigState> {
  AppConfigNotifier() : super(const AppConfigState());

  void setAuthStrategy(AuthStrategy strategy) {
    state = state.copyWith(authStrategy: strategy);
  }

  void setSidebarPosition(SidebarPosition position) {
    state = state.copyWith(sidebarPosition: position);
  }

  void setLocale(Locale locale) {
    state = state.copyWith(selectedLocale: locale);
  }

  void setTemplate(AppTemplate template) {
    state = state.copyWith(currentTemplate: template);
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void setDarkMode(bool isDark) {
    state = state.copyWith(isDarkMode: isDark);
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