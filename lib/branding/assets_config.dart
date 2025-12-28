/// Asset path configuration for the application.
/// 
/// This class centralizes all asset paths, making it easy to
/// manage and update asset references across the app.
class AssetsConfig {
  AssetsConfig._();

  // ============================================
  // BASE PATHS
  // ============================================

  static const String _imagesBase = 'assets/images';
  static const String _logoBase = '$_imagesBase/logo';
  static const String _bannerBase = '$_imagesBase/banners';
  static const String _iconBase = '$_imagesBase/icons';

  // ============================================
  // LOGOS
  // ============================================

  /// Main app logo
  static const String logo = '$_logoBase/app_logo.png';

  /// Logo for light background
  static const String logoLight = '$_logoBase/logo_light.png';

  /// Logo for dark background
  static const String logoDark = '$_logoBase/logo_dark.png';

  /// Launcher icon
  static const String launcherIcon = '$_logoBase/launcher_icon.png';

  /// Splash screen logo
  static const String splashLogo = '$_logoBase/splash_logo.png';

  // ============================================
  // PLACEHOLDERS
  // ============================================

  /// Default avatar for users without photo
  static const String defaultAvatar = '$_imagesBase/default_avatar.png';

  /// Placeholder for loading images
  static const String imagePlaceholder = '$_imagesBase/placeholder.png';

  /// Error/broken image placeholder
  static const String imageError = '$_imagesBase/image_error.png';

  // ============================================
  // ILLUSTRATIONS
  // ============================================

  /// Empty state illustration
  static const String emptyState = '$_imagesBase/empty_state.png';

  /// Error state illustration
  static const String errorState = '$_imagesBase/error_state.png';

  /// Success state illustration
  static const String successState = '$_imagesBase/success_state.png';

  /// No internet illustration
  static const String noInternet = '$_imagesBase/no_internet.png';

  /// Maintenance illustration
  static const String maintenance = '$_imagesBase/maintenance.png';

  // ============================================
  // AUTH SCREENS
  // ============================================

  /// Login screen background
  static const String loginBackground = '$_imagesBase/login_bg.png';

  /// Register screen background
  static const String registerBackground = '$_imagesBase/register_bg.png';

  // ============================================
  // BANNERS
  // ============================================

  /// Default banner 1
  static const String banner1 = '$_bannerBase/banner1.png';

  /// Default banner 2
  static const String banner2 = '$_bannerBase/banner2.png';

  /// Default banner 3
  static const String banner3 = '$_bannerBase/banner3.png';

  // ============================================
  // ICONS
  // ============================================

  /// Google icon for auth buttons
  static const String googleIcon = '$_iconBase/google.png';

  /// Facebook icon for auth buttons
  static const String facebookIcon = '$_iconBase/facebook.png';

  /// Apple icon for auth buttons
  static const String appleIcon = '$_iconBase/apple.png';

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get all banner paths as a list
  static List<String> get allBanners => [banner1, banner2, banner3];

  /// Check if an asset exists (for runtime checking)
  /// Note: This is a simplified check, actual asset existence
  /// should be verified at build time
  static bool isValidAssetPath(String path) {
    return path.startsWith('assets/');
  }
}
