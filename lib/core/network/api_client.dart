import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// API Client
/// Centralized Dio instance with pre-configured interceptors
class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;

  Dio get dio => _dio;

  ApiClient({
    String? baseUrl,
    TokenStorage? tokenStorage,
    List<Interceptor>? additionalInterceptors,
    void Function()? onUnauthorized,
  }) : _tokenStorage = tokenStorage ?? InMemoryTokenStorage() {
    _dio = _createDio(
      baseUrl: baseUrl,
      onUnauthorized: onUnauthorized,
    );

    // Add additional interceptors if provided
    if (additionalInterceptors != null) {
      for (final interceptor in additionalInterceptors) {
        _dio.interceptors.add(interceptor);
      }
    }
  }

  Dio _createDio({
    String? baseUrl,
    void Function()? onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConfig.fullBaseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
        headers: ApiConfig.defaultHeaders,
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add interceptors in order
    // 1. Timing interceptor (records start time)
    dio.interceptors.add(RequestTimingInterceptor());

    // 2. Common headers interceptor
    dio.interceptors.add(CommonHeadersInterceptor());

    // 3. Auth interceptor
    dio.interceptors.add(
      AuthInterceptor(
        getToken: _tokenStorage.getAccessToken,
        refreshToken: _tokenStorage.getRefreshToken,
        onUnauthorized: onUnauthorized,
      ),
    );

    // 4. Retry interceptor
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        maxRetries: 3,
      ),
    );

    // 5. Error interceptor
    dio.interceptors.add(ErrorInterceptor());

    // 6. Logging interceptor (should be last to capture final request/response)
    dio.interceptors.add(
      LoggingInterceptor(
        enableLogging: ApiConfig.enableLogging,
      ),
    );

    return dio;
  }

  /// Token storage access
  TokenStorage get tokenStorage => _tokenStorage;

  /// Save tokens after successful login
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    await _tokenStorage.clearTokens();
  }

  /// Cancel all pending requests
  void cancelAllRequests([CancelToken? cancelToken]) {
    cancelToken?.cancel('Cancelled by user');
  }
}

/// API Client Provider
/// Provides a singleton instance of ApiClient through Riverpod
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: EnvironmentConfig.current.baseUrl,
    onUnauthorized: () {
      // Handle unauthorized - typically navigate to login
      // You can use ref.read to access other providers here
    },
  );
});

/// Dio Provider
/// Direct access to Dio instance if needed
final dioProvider = Provider<Dio>((ref) {
  return ref.watch(apiClientProvider).dio;
});
