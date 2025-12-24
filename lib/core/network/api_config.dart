import '../constants/app_info.dart';

/// API Configuration
/// Contains base URLs and environment-specific configurations
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Base URL for API calls
  /// Change this based on your environment (dev, staging, prod)
  static const String baseUrl = 'https://api.example.com';

  /// API version prefix
  static const String apiVersion = '/api/v1';

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

  /// Environment configuration
  static const bool enableLogging = true; // Set to false in production
}

/// Environment types for different API configurations
enum Environment {
  development,
  staging,
  production,
}

/// Environment-specific URLs
class EnvironmentConfig {
  final Environment environment;
  final String baseUrl;

  const EnvironmentConfig._({
    required this.environment,
    required this.baseUrl,
  });

  static const EnvironmentConfig development = EnvironmentConfig._(
    environment: Environment.development,
    baseUrl: 'https://dev-api.example.com',
  );

  static const EnvironmentConfig staging = EnvironmentConfig._(
    environment: Environment.staging,
    baseUrl: 'https://staging-api.example.com',
  );

  static const EnvironmentConfig production = EnvironmentConfig._(
    environment: Environment.production,
    baseUrl: 'https://api.example.com',
  );

  /// Current active environment
  static EnvironmentConfig current = development;
}
