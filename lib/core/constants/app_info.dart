/// Application information from pubspec.yaml
/// This file stores constants that correspond to data in pubspec.yaml
class AppInfo {
  AppInfo._();

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

  // ============================================
  // FEATURE FLAGS
  // ============================================

  /// Enable/disable QR Code scanning feature
  static const bool enableQrScanner = true;

  /// Enable/disable camera photo capture feature
  static const bool enableCameraCapture = true;

  /// Enable/disable gallery upload feature
  static const bool enableGalleryUpload = true;
}
