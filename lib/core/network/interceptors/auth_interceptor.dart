import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_config.dart';

/// Auth Interceptor
/// Automatically adds authentication headers to all requests
/// Handles token refresh and 401 responses
class AuthInterceptor extends Interceptor {
  final Ref? ref;
  final Future<String?> Function()? getToken;
  final Future<String?> Function()? refreshToken;
  final VoidCallback? onUnauthorized;

  AuthInterceptor({
    this.ref,
    this.getToken,
    this.refreshToken,
    this.onUnauthorized,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for requests that don't need it
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    // Get the current token
    String? token;
    if (getToken != null) {
      token = await getToken!();
    }

    // Add authorization header if token exists
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add default headers from config
    options.headers.addAll(ApiConfig.defaultHeaders);

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      if (refreshToken != null) {
        try {
          final newToken = await refreshToken!();
          if (newToken != null && newToken.isNotEmpty) {
            // Retry the original request with new token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            // Create a new Dio instance for retry to avoid interceptor loop
            final dio = Dio();
            final response = await dio.fetch(options);
            return handler.resolve(response);
          }
        } catch (_) {
          // Token refresh failed, proceed with error
        }
      }

      // Call unauthorized callback
      onUnauthorized?.call();
    }

    handler.next(err);
  }
}

/// Token storage abstraction
abstract class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<void> clearTokens();
}

/// Simple in-memory token storage (for demo/testing)
/// Replace with SharedPreferences or secure storage in production
class InMemoryTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}
