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

  /// Normalize base URL by removing trailing slash
  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Normalize endpoint by ensuring it starts with /
  static String _normalizeEndpoint(String endpoint) {
    return endpoint.startsWith('/') ? endpoint : '/$endpoint';
  }

  /// Full API base URL (normalized, without trailing slash)
  static String get fullBaseUrl => _normalizeBaseUrl('$baseUrl$apiVersion');

  /// Build complete URL from base URL and endpoint
  /// Handles duplicate slashes automatically
  /// Example: buildUrl('/auth/login/') => 'https://api.yourdomain.com/auth/login/'
  static String buildUrl(String endpoint) {
    return '$fullBaseUrl${_normalizeEndpoint(endpoint)}';
  }

  /// Connection timeout in milliseconds
  static const int connectTimeout = 30000;

  /// Receive timeout in milliseconds
  static const int receiveTimeout = 30000;

  /// Send timeout in milliseconds
  static const int sendTimeout = 30000;

  /// Default headers for all requests
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
        'X-Platform': 'mobile',
        'X-App-Version': AppInfo.version,
      };

  /// Browser-like User-Agent to avoid bot detection
  /// Used for external API calls that may have bot protection
  static const String browserUserAgent = 
      'Mozilla/5.0 (Linux; Android 13; SM-G998B) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

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
