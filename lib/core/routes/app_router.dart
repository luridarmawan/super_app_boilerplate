import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_info.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/main_dashboard.dart';
import '../../features/settings/setting_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../shared/info/help_screen.dart';
import '../../shared/info/tos_screen.dart';
import '../../shared/info/privacy_screen.dart';


/// Route names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String help = '/help';
  static const String tos = '/tos';
  static const String privacy = '/privacy';
}

/// Key untuk SharedPreferences
const String _isLoggedInKey = 'app_is_logged_in';

/// Provider untuk mengecek apakah user sudah login (dari SharedPreferences)
final isUserLoggedInProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_isLoggedInKey) ?? false;
});

/// Router provider untuk navigasi
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Always start at splash to check auth state
    initialLocation: AppInfo.enableSplashScreen ? AppRoutes.splash : AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => SplashScreen(
          onComplete: () async {
            // Check if user is logged in from SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

            if (context.mounted) {
              if (isLoggedIn) {
                context.go(AppRoutes.dashboard);
              } else {
                context.go(AppRoutes.login);
              }
            }
          },
        ),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(
          onLoginSuccess: () => context.go(AppRoutes.dashboard),
          onRegisterTap: () => context.push(AppRoutes.register),
          onForgotPasswordTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Forgot password'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        redirect: (context, state) async {
          // Check if user is already logged in
          final prefs = await SharedPreferences.getInstance();
          final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

          if (isLoggedIn) {
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

      // Main Dashboard
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => MainDashboard(
          onSettingsTap: () => context.push(AppRoutes.settings),
          onProfileTap: () => context.push(AppRoutes.profile),
          onHelpTap: () => context.push(AppRoutes.help),
          // onLogoutTap handled internally by MainDashboard
        ),
        redirect: (context, state) async {
          // Protect dashboard - redirect to login if not logged in
          final prefs = await SharedPreferences.getInstance();
          final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

          if (!isLoggedIn) {
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
