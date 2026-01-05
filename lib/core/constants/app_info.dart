import 'dart:ui';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Application information and branding configuration.
/// This file stores constants from pubspec.yaml and .env file.
/// All branding, social links, and assets are centralized here.
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

  /// Application sub tagline
  static String get subTagline => dotenv.env['APP_SUB_TAGLINE'] ?? '';

  /// Application copyright
  static String get copyright => dotenv.env['APP_COPYRIGHT'] ?? '- Developed by CARIK.id -';

  /// Application version (from pubspec.yaml via package_info_plus)
  static String _version = '1.0.0';
  static String get version => _version;

  /// Build number (from pubspec.yaml via package_info_plus)
  static String _buildNumber = '1';
  static String get buildNumber => _buildNumber;

  /// Full version with build number
  static String get fullVersion => '$_version+$_buildNumber';

  /// Initialize version info from pubspec.yaml
  /// Call this method in main() after WidgetsFlutterBinding.ensureInitialized()
  static Future<void> initialize() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
  }

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

  static String get authLoginUrl => dotenv.env['AUTH_LOGIN_URL'] ?? '';
  static String get authLoginContentType => dotenv.env['AUTH_LOGIN_CONTENT_TYPE'] ?? 'application/json';

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
  static Duration get splashScreenDuration => Duration(seconds:int.tryParse(dotenv.env['SPLASH_DURATION'] ?? '5') ?? 5);

  /// Number of initial app launches to show splash screen (default: 5)
  static int get splashShowCount => int.tryParse(dotenv.env['SPLASH_SHOW_COUNT'] ?? '5') ?? 5;

  /// Hours of inactivity after which splash screen will show again (default: 24)
  static int get splashDelayHours => int.tryParse(dotenv.env['SPLASH_DELAY'] ?? '24') ?? 24;

  /// Splash screen background image URL
  static String get splashBackground => dotenv.env['SPLASH_BACKGROUND'] ?? 'https://picsum.photos/800/1600';

  /// Splash gradient start color (top) - hex format e.g. #1E88E5
  static String? get splashGradientStart => dotenv.env['SPLASH_GRADIENT_START'];

  /// Splash gradient middle color - hex format e.g. #42A5F5
  static String? get splashGradientMiddle => dotenv.env['SPLASH_GRADIENT_MIDDLE'];

  /// Splash gradient end color (bottom) - hex format e.g. #90CAF9
  static String? get splashGradientEnd => dotenv.env['SPLASH_GRADIENT_END'];

  /// Parse hex color string to Color, returns null if invalid
  static Color? parseHexColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;

    // Remove # if present
    String hex = hexString.replaceFirst('#', '');

    // Handle 6-digit hex (add FF for full opacity)
    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    // Parse and return color
    final intValue = int.tryParse(hex, radix: 16);
    if (intValue == null) return null;

    return Color(intValue);
  }

  /// Get splash gradient colors, falls back to theme colors if not set
  static List<Color>? get splashGradientColors {
    final start = parseHexColor(splashGradientStart);
    final end = parseHexColor(splashGradientEnd);

    // If both start and end are set, use them
    if (start != null && end != null) {
      final middle = parseHexColor(splashGradientMiddle);
      if (middle != null) {
        return [start, middle, end];
      }
      return [start, end];
    }

    // Return null to indicate use theme colors
    return null;
  }

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

  /// Enable/disable GPS/Location feature
  static bool get enableGps => dotenv.env['ENABLE_GPS']?.toLowerCase() == 'true';
  static String get gpsReverseGeoUrl => dotenv.env['GPS_REVERSE_GEO_URL'] ?? '';

  /// Enable/disable Quick Action Demo (Pay, Bills, Pulsa)
  static bool get enableQuickActionDemo => dotenv.env['ENABLE_QUICK_ACTION_DEMO']?.toLowerCase() == 'true';

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

  static String get authGoogleVerificationUrl => dotenv.env['AUTH_GOOGLE_VERIFICATION_URL'] ?? '';

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

  static String get launcherIcon => dotenv.env['LAUNCHER_ICON'] ?? 'assets/images/logo/carik_blue_logo.png';

  static String get flutterSplashLogo => dotenv.env['SPLASH_LOGO'] ?? 'assets/images/logo/carik_blue_logo.png';

  static String get flutterLauncherIcon => dotenv.env['LAUNCHER_ICON'] ?? 'assets/images/logo/carik_blue_logo.png';

  static String get themeDefault => dotenv.env['THEME_DEFAULT'] ?? '';

  // CONTENT LINK
  static String get bannerApiURL => dotenv.env['BANNER_API_URL'] ?? 'https://api.carik.id/dummy/banner.json';
  static String get articleApiURL => dotenv.env['ARTICLE_API_URL'] ?? 'https://api.carik.id/dummy/article.json?slug={slug}';
  static String get articleLastApiURL => dotenv.env['ARTICLE_LAST_API_URL'] ?? 'https://api.carik.id/dummy/articles.json';
  static String get articleRecommendationApiURL => dotenv.env['ARTICLE_RECOMMENDATION_API_URL'] ?? 'https://api.carik.id/dummy/articles.json';


  // ============================================
  // DEMO/TESTING CONFIGURATION
  // ============================================

  /// Default username for demo/testing purposes
  static String get usernameDefault => _cleanEnvValue(dotenv.env['USERNAME_DEFAULT']);

  /// Default password for demo/testing purposes
  static String get passwordDefault => _cleanEnvValue(dotenv.env['PASSWORD_DEFAULT']);

  /// Helper to clean env values (remove surrounding quotes and handle empty)
  static String _cleanEnvValue(String? value) {
    if (value == null || value.isEmpty) return '';
    // Remove surrounding quotes if present
    if (value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    }
    if (value.startsWith("'") && value.endsWith("'")) {
      value = value.substring(1, value.length - 1);
    }
    return value;
  }

  // ============================================
  // BRANDING - COMPANY INFO
  // ============================================

  /// Company/Organization name
  static String get companyName =>
      dotenv.env['COMPANY_NAME'] ?? 'PT. Super Tech';

  /// Company website URL
  static String get websiteUrl =>
      dotenv.env['WEBSITE_URL'] ?? 'https://example.com';

  // ============================================
  // BRANDING - SOCIAL LINKS
  // ============================================

  /// Play Store URL
  static String? get playStoreUrl => dotenv.env['PLAY_STORE_URL'];

  /// App Store URL
  static String? get appStoreUrl => dotenv.env['APP_STORE_URL'];

  /// Facebook page URL
  static String? get facebookUrl => dotenv.env['FACEBOOK_URL'];

  /// Instagram page URL
  static String? get instagramUrl => dotenv.env['INSTAGRAM_URL'];

  /// Twitter/X page URL
  static String? get twitterUrl => dotenv.env['TWITTER_URL'];

  /// LinkedIn page URL
  static String? get linkedInUrl => dotenv.env['LINKEDIN_URL'];

  /// Check if social links are configured
  static bool get hasSocialLinks =>
      facebookUrl != null ||
      instagramUrl != null ||
      twitterUrl != null ||
      linkedInUrl != null;

  /// Check if app store links are configured
  static bool get hasAppStoreLinks =>
      playStoreUrl != null || appStoreUrl != null;

  // ============================================
  // BRANDING - LEGAL
  // ============================================

  /// Terms of Service URL
  static String get termsUrl =>
      dotenv.env['TERMS_URL'] ?? 'https://example.com/terms';

  /// Privacy Policy URL
  static String get privacyUrl =>
      dotenv.env['PRIVACY_URL'] ?? 'https://example.com/privacy';

  /// Copyright text
  static String get copyrightText {
    final year = DateTime.now().year;
    return dotenv.env['COPYRIGHT_TEXT'] ??
        '© $year $companyName. All rights reserved.';
  }

  // ============================================
  // BRANDING - ASSETS
  // ============================================

  /// Default avatar/placeholder image
  static String get defaultAvatarPath =>
      dotenv.env['DEFAULT_AVATAR'] ?? 'assets/images/default_avatar.png';
}
