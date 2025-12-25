import '../constants/app_info.dart';

/// API Configuration
/// Contains base URLs and environment-specific configurations
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Base URL for API calls
  /// Automatically uses the current environment's base URL
  static String get baseUrl => EnvironmentConfig.current.baseUrl;

  /// API version prefix
  static const String apiVersion = '';

  /// Full API base URL
  static String get fullBaseUrl => '$baseUrl$apiVersion';

  /// Connection timeout in milliseconds
  static const int connectTimeout = 30000;

  /// Receive timeout in milliseconds
  static const int receiveTimeout = 30000;

  /// Send timeout in milliseconds
  static const int sendTimeout = 30000;

  /// Default headers for all requests
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Platform': 'mobile',
        'X-App-Version': AppInfo.version,
        'User-Agent': '${AppInfo.name.replaceAll(' ', '')}/${AppInfo.version}',
      };

  /// Environment configuration (automatically set based on AppInfo.environment)
  static bool get enableLogging => EnvironmentConfig.current.enableLogging;
}

/// Environment types for different API configurations
enum Environment {
  development,
  production,
}

/// Environment-specific URLs and configurations
class EnvironmentConfig {
  final Environment environment;
  final String baseUrl;
  final bool enableLogging;
  final String name;

  const EnvironmentConfig._({
    required this.environment,
    required this.baseUrl,
    required this.enableLogging,
    required this.name,
  });

  /// Development environment
  /// Uses staging API for development and testing
  static EnvironmentConfig get development => EnvironmentConfig._(
    environment: Environment.development,
    baseUrl: AppInfo.apiBaseUrlDevelopment,
    enableLogging: true,
    name: 'Development',
  );

  /// Production environment
  /// Uses production API for live app
  static EnvironmentConfig get production => EnvironmentConfig._(
    environment: Environment.production,
    baseUrl: AppInfo.apiBaseUrl,
    enableLogging: false,
    name: 'Production',
  );

  /// Current active environment
  /// Change this based on AppInfo.isProduction flag
  static EnvironmentConfig get current => AppInfo.isProduction 
      ? production 
      : development;

  /// Check if current environment is development
  static bool get isDevelopment => current.environment == Environment.development;

  /// Check if current environment is production
  static bool get isProduction => current.environment == Environment.production;
}
