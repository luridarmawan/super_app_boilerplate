/// Application information from pubspec.yaml
/// This file stores constants that correspond to data in pubspec.yaml
class AppInfo {
  AppInfo._();
  static const bool enableDemo = true;

  /// Environment flag: Set to true for production, false for development
  /// - false (default): Uses development API (https://staging-api.carik.id/)
  /// - true: Uses production API (https://api.carik.id/)
  static const bool isProduction = false;

  /// Application name
  static const String name = 'Super X App';

  /// Application description
  static const String description = 'A Super App Project.';

  /// Application tagline
  static const String tagline = 'Your All-in-One Solution..';

  /// Application version
  static const String version = '3.3.1';

  /// Build number
  static const int buildNumber = 17;

  /// Full version with build number
  static const String fullVersion = '$version+$buildNumber';

  static const double bottomMargin = 58;

  /// Enable/disable splash screen on app startup
  /// If false, app will skip splash screen and go directly to login
  static const bool enableSplashScreen = true;

  /// Duration of splash screen display (only applies if enableSplashScreen is true)
  static const Duration splashScreenDuration = Duration(seconds: 4);

  // ============================================
  // FEATURE FLAGS
  // ============================================

  /// Enable/disable QR Code scanning feature
  static const bool enableQrScanner = true;

  /// Enable/disable camera photo capture feature
  static const bool enableCameraCapture = true;

  /// Enable/disable gallery upload feature
  static const bool enableGalleryUpload = true;

  /// Enable/disable Google login/register feature
  static const bool enableGoogleLogin = true;

  /// Enable/disable Dummy login/register feature
  static const bool enableDummyLogin = true;

  /// Auth provider strategy: 'firebase' or 'customApi'
  /// - 'firebase': Use Firebase Auth + Google Sign-In (requires firebase configuration)
  /// - 'customApi': Use Google Sign-In + Custom Backend API (no Firebase needed)
  static const String authProvider = 'customApi'; // 'firebase', 'customApi'

  static const bool enableNotification = false;
  static const String notificationProvider = 'firebase'; // 'firebase', 'onesignal', 'mock'
  static const bool enableNotificationBanner = false;

  /// OneSignal App ID - get from https://onesignal.com dashboard
  static const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';

  /// Google Web Client ID - get from Google Cloud Console
  /// This is the Web Client ID (not Android Client ID)
  /// Required for google_sign_in v7.x on Android
  static const String googleServerClientId = 'your_client_id';

  static const bool enableDangerZone = true;
  static const bool enableDeleteAccount = true;

  static const String emailSupport = "support@yourdomain.com";
  static const String phoneSupport = "+62 890 1234 567";
}
