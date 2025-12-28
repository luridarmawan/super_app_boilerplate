import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Branding configuration for the application.
/// 
/// This class centralizes all branding-related configurations,
/// making it easy to customize the app for different clients.
/// 
/// Values can be overridden via environment variables in .env file.
class BrandingConfig {
  BrandingConfig._();

  // ============================================
  // APP IDENTITY
  // ============================================

  /// Application name
  /// Can be overridden via APP_NAME in .env
  static String get appName => dotenv.env['APP_NAME'] ?? 'Super App';

  /// Company/Organization name
  static String get companyName => dotenv.env['COMPANY_NAME'] ?? 'PT. Super Tech';

  /// Application tagline
  static String get tagline => dotenv.env['APP_TAGLINE'] ?? 'Your All-in-One Solution';

  /// Application description
  static String get description => dotenv.env['APP_DESCRIPTION'] ?? 'A Super App Project';

  // ============================================
  // COLORS
  // ============================================

  /// Primary brand color
  /// Can be overridden via PRIMARY_COLOR in .env (hex format: #RRGGBB)
  static Color get primaryColor =>
      _parseColor(dotenv.env['PRIMARY_COLOR']) ?? const Color(0xFF1565C0);

  /// Secondary/Accent color
  static Color get accentColor =>
      _parseColor(dotenv.env['ACCENT_COLOR']) ?? const Color(0xFF00BCD4);

  /// Error color
  static Color get errorColor =>
      _parseColor(dotenv.env['ERROR_COLOR']) ?? const Color(0xFFB00020);

  /// Success color
  static Color get successColor =>
      _parseColor(dotenv.env['SUCCESS_COLOR']) ?? const Color(0xFF4CAF50);

  /// Warning color
  static Color get warningColor =>
      _parseColor(dotenv.env['WARNING_COLOR']) ?? const Color(0xFFFFC107);

  // ============================================
  // ASSETS
  // ============================================

  /// Main app logo path
  static String get logoPath =>
      dotenv.env['LOGO_PATH'] ?? 'assets/images/logo/app_logo.png';

  /// Launcher icon path
  static String get launcherIconPath =>
      dotenv.env['LAUNCHER_ICON'] ?? 'assets/images/logo/carik_blue_logo.png';

  /// Splash screen logo path
  static String get splashLogoPath =>
      dotenv.env['SPLASH_LOGO'] ?? 'assets/images/logo/carik_blue_logo.png';

  /// Default avatar/placeholder image
  static String get defaultAvatarPath =>
      dotenv.env['DEFAULT_AVATAR'] ?? 'assets/images/default_avatar.png';

  /// Login/Register background image (optional)
  static String? get authBackgroundPath => dotenv.env['AUTH_BACKGROUND'];

  // ============================================
  // SOCIAL & LINKS
  // ============================================

  /// Company website URL
  static String get websiteUrl =>
      dotenv.env['WEBSITE_URL'] ?? 'https://example.com';

  /// Support email address
  static String get supportEmail =>
      dotenv.env['SUPPORT_EMAIL'] ?? 'support@example.com';

  /// Support phone number
  static String get supportPhone =>
      dotenv.env['SUPPORT_PHONE'] ?? '+62 890 1234 567';

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

  // ============================================
  // LEGAL
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
    return dotenv.env['COPYRIGHT_TEXT'] ?? '© $year $companyName. All rights reserved.';
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Parse hex color string to Color
  /// Accepts formats: #RRGGBB, #AARRGGBB, RRGGBB
  static Color? _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;

    try {
      String hex = hexColor.replaceAll('#', '');

      // Handle 6-digit hex (RGB)
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add full opacity
      }

      // Handle 8-digit hex (ARGB)
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get gradient for branded backgrounds
  static LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          primaryColor.withValues(alpha: 0.7),
        ],
      );

  /// Check if social links are configured
  static bool get hasSocialLinks =>
      facebookUrl != null ||
      instagramUrl != null ||
      twitterUrl != null ||
      linkedInUrl != null;

  /// Check if app store links are configured
  static bool get hasAppStoreLinks =>
      playStoreUrl != null || appStoreUrl != null;
}
