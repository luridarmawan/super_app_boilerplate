import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_info.dart';
import '../services/prefs_service.dart';
import '../services/remote_config_service.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/campaign/campaign_home_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/dashboard/main_dashboard.dart';
import '../../features/settings/setting_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../shared/info/help_screen.dart';
import '../../shared/info/tos_screen.dart';
import '../../shared/info/privacy_screen.dart';
import '../../features/maintenance/maintenance_mode_screen.dart';
import '../../features/dashboard/screens/quick_actions_manager_screen.dart';
import '../../modules/news/screens/article_screen.dart';

// Modular Architecture
import '../../modules/module_registry.dart';


/// Route names
class AppRoutes {
  static const String splash = '/';
  static const String campaignHome = '/campaign';
  static const String maintenance = '/maintenance';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String help = '/help';
  static const String tos = '/tos';
  static const String privacy = '/privacy';
  static const String quickActions = '/quick-actions';
}

/// Global navigator key untuk navigasi dari non-widget context
/// Digunakan oleh TokenRefreshService untuk auto-logout redirect
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router provider untuk navigasi
/// Uses cached PrefsService for better performance (no async SharedPreferences calls)
final routerProvider = Provider<GoRouter>((ref) {
  final prefsService = ref.watch(prefsServiceProvider);

  // Determine if splash screen should be shown based on:
  // 1. ENABLE_SPLASH_SCREEN flag must be true
  // 2. If user is NOT logged in, always show splash
  // 3. If user IS logged in:
  //    - Show on first [SPLASH_SHOW_COUNT] app launches (default: 5)
  //    - After that, show only if app hasn't been opened for [SPLASH_DELAY] hours (default: 24)
  final shouldShowSplash = AppInfo.enableSplashScreen &&
      (!prefsService.isLoggedIn ||
          prefsService.shouldShowSplash(AppInfo.splashShowCount, AppInfo.splashDelayHours));

  // Record this app open (update counters and last opened time)
  prefsService.recordAppOpen();

  // Determine initial location
  String initialLocation;
  if (shouldShowSplash) {
    initialLocation = AppRoutes.splash;
  } else {
    // Always go to campaign first, then campaign will handle navigation to login/dashboard
    initialLocation = AppRoutes.campaignHome;
  }

  debugPrint('[Router] initialLocation: $initialLocation, shouldShowSplash: $shouldShowSplash');

  // Get routes from active modules
  final moduleRoutes = ModuleRegistry.allRoutes;
  debugPrint('📍 Loaded ${moduleRoutes.length} routes from modules');

  return GoRouter(
    // Global navigator key for non-widget navigation (auto-logout)
    navigatorKey: rootNavigatorKey,
    // Start based on splash logic and auth state
    initialLocation: initialLocation,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) {
          debugPrint('[Router] Rendering SplashScreen');
          return SplashScreen(
            onComplete: () {
              debugPrint('[Router] SplashScreen onComplete, going to campaignHome');
              context.go(AppRoutes.campaignHome);
            },
          );
        },
      ),

      // Campaign Home Screen
      GoRoute(
        path: AppRoutes.campaignHome,
        builder: (context, state) {
          debugPrint('[Router] Rendering CampaignHomeScreen');
          return CampaignHomeScreen(
            onComplete: () async {
              debugPrint('[Router] CampaignHomeScreen onComplete, checking maintenance mode');
              // Check maintenance mode from RemoteConfig before proceeding
              final isMaintenance = await RemoteConfigService.fetchMaintenanceMode();

              debugPrint('[Router] Maintenance check result: $isMaintenance');

              if (context.mounted) {
                if (isMaintenance) {
                  context.go(AppRoutes.maintenance);
                  return;
                }

                // Use cached PrefsService (synchronous, no blocking)
                final isLoggedIn = prefsService.isLoggedIn;
                debugPrint('[Router] isLoggedIn: $isLoggedIn');
                if (isLoggedIn) {
                  context.go(AppRoutes.dashboard);
                } else {
                  context.go(AppRoutes.login);
                }
              }
            },
          );
        },
      ),

      // Maintenance Mode
      GoRoute(
        path: AppRoutes.maintenance,
        builder: (context, state) => MaintenanceModeScreen(
          onRetry: () => context.go(AppRoutes.splash),
        ),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(
          onLoginSuccess: () => context.go(AppRoutes.dashboard),
          onRegisterTap: () => context.push(AppRoutes.register),
          onForgotPasswordTap: () => context.push(AppRoutes.forgotPassword),
        ),
        redirect: (context, state) {
          // Use cached PrefsService (synchronous)
          if (prefsService.isLoggedIn) {
            return AppRoutes.dashboard;
          }
          return null;
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => RegisterScreen(
          onRegisterSuccess: () => context.go(AppRoutes.dashboard),
          onLoginTap: () => context.pop(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => ForgotPasswordScreen(
          onBackTap: () => context.pop(),
        ),
      ),

      // Main Dashboard
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => MainDashboard(
          onSettingsTap: () => context.push(AppRoutes.settings),
          onProfileTap: () => context.push(AppRoutes.profile),
          onHelpTap: () => context.push(AppRoutes.help),
          // onLogoutTap handled internally by MainDashboard
        ),
        redirect: (context, state) {
          // Protect dashboard - use cached PrefsService (synchronous)
          if (!prefsService.isLoggedIn) {
            return AppRoutes.login;
          }
          return null;
        },
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => SettingScreen(
          onBackTap: () => context.pop(),
        ),
      ),

      // Profile
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => ProfileScreen(
          onBackTap: () => context.pop(),
          onEditTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit profile'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),

      // Info Pages
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => HelpScreen(
          onBackTap: () => context.pop(),
        ),
      ),
      GoRoute(
        path: AppRoutes.tos,
        builder: (context, state) => TosScreen(
          onBackTap: () => context.pop(),
        ),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => PrivacyScreen(
          onBackTap: () => context.pop(),
        ),
      ),

      // Quick Actions Manager
      GoRoute(
        path: AppRoutes.quickActions,
        builder: (context, state) => const QuickActionsManagerScreen(),
      ),
      GoRoute(
        path: '/article/:slug',
        name: 'article_detail',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return ArticleScreen(slug: slug);
        },
      ),

      // ============================================
      // DYNAMIC MODULE ROUTES
      // ============================================
      // Routes from active modules are automatically added here
      ...moduleRoutes,
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
