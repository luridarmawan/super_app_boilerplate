import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application information from pubspec.yaml
/// This file stores constants that correspond to data in pubspec.yaml
class AppInfo {
  AppInfo._();
  static const bool enableDemo = true;

  // ============================================
  // ENVIRONMENT & APP INFO
  // ============================================

  /// Environment flag: Reads from ENVIRONMENT in .env file
  /// - ENVIRONMENT=production: Uses production API
  /// - ENVIRONMENT=development (or other): Uses development/staging API
  static bool get isProduction => dotenv.env['ENVIRONMENT'] == 'production';

  /// Application name
  static String get name => dotenv.env['APP_NAME'] ?? 'Super X App';

  /// Application description
  static String get description => dotenv.env['APP_DESCRIPTION'] ?? 'A Super App Project.';

  /// Application tagline
  static String get tagline => dotenv.env['APP_TAGLINE'] ?? 'Your All-in-One Solution.';

  /// Application version
  static const String version = '3.3.1';

  /// Build number
  static const int buildNumber = 17;

  /// Full version with build number
  static const String fullVersion = '$version+$buildNumber';

  static const double bottomMargin = 58;

  // ============================================
  // API CONFIGURATION
  // ============================================

  /// Production API Base URL
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.example.com/';

  /// Development/Staging API Base URL
  static String get apiBaseUrlDevelopment => dotenv.env['API_BASE_URL_DEVELOPMENT'] ?? 'https://demo-api.example.com/';

  /// Get the active API Base URL based on environment
  static String get activeApiBaseUrl => isProduction ? apiBaseUrl : apiBaseUrlDevelopment;

  // ============================================
  // API ENDPOINT
  // ============================================

  static String get apiEndpointLogin => dotenv.env['API_ENDPOINT_LOGIN'] ?? '/o/auth/login/';
  static String get apiEndpointRegister => dotenv.env['API_ENDPOINT_REGISTER'] ?? '/o/auth/register/';
  static String get apiEndpointForgotPassword => dotenv.env['API_ENDPOINT_FORGOT_PASSWORD'] ?? '/o/auth/forgot-password/';
  static String get apiEndpointResetPassword => dotenv.env['API_ENDPOINT_RESET_PASSWORD'] ?? '/o/auth/reset-password/';
  static String get apiEndpointLogout => dotenv.env['API_ENDPOINT_LOGOUT'] ?? '/o/auth/logout/';
  static String get apiEndpointRefreshToken => dotenv.env['API_ENDPOINT_REFRESH_TOKEN'] ?? '/o/auth/refresh-token/';
  static String get apiEndpointVerifyToken => dotenv.env['API_ENDPOINT_VERIFY_TOKEN'] ?? '/o/auth/verify-token/';

  // ============================================
  // SPLASH SCREEN
  // ============================================

  /// Enable/disable splash screen on app startup
  /// If false, app will skip splash screen and go directly to login
  static bool get enableSplashScreen => dotenv.env['ENABLE_SPLASH_SCREEN']?.toLowerCase() == 'true';

  /// Duration of splash screen display (only applies if enableSplashScreen is true)
  static const Duration splashScreenDuration = Duration(seconds: 4);

  // ============================================
  // FEATURE FLAGS
  // ============================================

  /// Enable/disable QR Code scanning feature
  static bool get enableQrScanner => dotenv.env['ENABLE_QRSCANNER']?.toLowerCase() == 'true';

  /// Enable/disable camera photo capture feature
  static bool get enableCameraCapture => dotenv.env['ENABLE_CAMERA_CAPTURE']?.toLowerCase() == 'true';

  /// Enable/disable gallery upload feature
  static bool get enableGalleryUpload => dotenv.env['ENABLE_GALLERY_UPLOAD']?.toLowerCase() == 'true';

  /// Enable/disable Google login/register feature
  static bool get enableGoogleLogin => dotenv.env['ENABLE_GOOGLE_LOGIN']?.toLowerCase() == 'true';

  /// Enable/disable Dummy login/register feature
  static bool get enableDummyLogin => dotenv.env['ENABLE_DUMMY_LOGIN']?.toLowerCase() == 'true';

  /// Enable/disable Danger Zone in profile
  static bool get enableDangerZone => dotenv.env['ENABLE_DANGER_ZONE']?.toLowerCase() == 'true';

  /// Enable/disable Delete Account feature
  static bool get enableDeleteAccount => dotenv.env['ENABLE_DELETE_ACCOUNT']?.toLowerCase() == 'true';

  // ============================================
  // AUTH CONFIGURATION
  // ============================================

  /// Auth provider strategy: 'firebase' or 'customApi'
  /// - 'firebase': Use Firebase Auth + Google Sign-In (requires firebase configuration)
  /// - 'customApi': Use Google Sign-In + Custom Backend API (no Firebase needed)
  static String get authProvider => dotenv.env['AUTH_PROVIDER'] ?? 'customApi';

  /// Google Web Client ID - get from Google Cloud Console
  /// This is the Web Client ID (not Android Client ID)
  /// Required for google_sign_in v7.x on Android
  static String get googleServerClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';

  static String get apiGoogleAuthVerification => dotenv.env['API_GOOGLE_AUTH_VERIFICATION'] ?? '';

  // ============================================
  // NOTIFICATION CONFIGURATION
  // ============================================

  /// Enable/disable notifications
  static bool get enableNotification => dotenv.env['ENABLE_NOTIFICATION']?.toLowerCase() == 'true';

  /// Notification provider: 'firebase', 'onesignal', 'mock'
  static String get notificationProvider => dotenv.env['NOTIFICATION_PROVIDER'] ?? 'firebase';

  /// Enable/disable notification banner
  static bool get enableNotificationBanner => dotenv.env['ENABLE_NOTIFICATION_BANNER']?.toLowerCase() == 'true';

  /// OneSignal App ID - get from https://onesignal.com dashboard
  static String get oneSignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? 'YOUR_ONESIGNAL_APP_ID';

  // ============================================
  // SUPPORT CONTACT
  // ============================================

  /// Support email address
  static String get emailSupport => dotenv.env['SUPPORT_EMAIL'] ?? 'support@yourdomain.com';

  /// Support phone number
  static String get phoneSupport => dotenv.env['SUPPORT_PHONE'] ?? '+62 890 1234 567';

  static String get flutterSplashLogo => dotenv.env['SPLASH_LOGO'] ?? 'assets/images/logo/carik_blue_logo.png';

  static String get flutterLauncherIcon => dotenv.env['LAUNCHER_ICON'] ?? 'assets/images/logo/carik_blue_logo.png';

  // ============================================
  // DEMO/TESTING CONFIGURATION
  // ============================================

  /// Default username for demo/testing purposes
  static String get usernameDefault => dotenv.env['USERNAME_DEFAULT'] ?? '';

  /// Default password for demo/testing purposes
  static String get passwordDefault => dotenv.env['PASSWORD_DEFAULT'] ?? '';
}
