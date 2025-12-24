/// Informasi aplikasi dari pubspec.yaml
/// File ini menyimpan konstanta yang sesuai dengan data di pubspec.yaml
class AppInfo {
  AppInfo._();

  /// Nama aplikasi
  static const String name = 'Super X App';

  /// Deskripsi aplikasi
  static const String description = 'A Super App Project.';

  /// Tagline aplikasi
  static const String tagline = 'Your All-in-One Solution..';

  /// Versi aplikasi
  static const String version = '1.0.1';

  /// Build number
  static const int buildNumber = 17;

  /// Versi lengkap dengan build number
  static const String fullVersion = '$version+$buildNumber';
}
