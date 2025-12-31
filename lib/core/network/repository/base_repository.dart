import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api_client.dart';
import '../models/base_response.dart';
import '../exceptions/api_exception.dart';

/// Base Repository
/// Abstract class that provides common HTTP operations for all repositories
abstract class BaseRepository {
  final ApiClient apiClient;

  /// Maximum retry attempts when Cloudflare protection is detected
  static const int _maxCloudflareRetries = 3;

  /// Delay between retry attempts (in milliseconds)
  static const int _cloudflareRetryDelayMs = 2000;

  BaseRepository({required this.apiClient});

  /// Get Dio instance
  Dio get dio => apiClient.dio;

  /// Bot protection detection result
  static const String protectionNone = 'none';
  static const String protectionCloudflare = 'cloudflare';
  static const String protectionImunify360 = 'imunify360';
  static const String protectionGeneric = 'generic';

  /// Check if response is a Cloudflare anti-bot challenge page
  /// 
  /// Cloudflare protection typically returns:
  /// - Status code 503 with "One moment, please..." or "Checking your browser"
  /// - HTML content with cf-browser-verification class
  /// - Headers with cf-ray or cf-cache-status
  bool isCloudflareResponse(Response response) {
    return detectBotProtection(response) == protectionCloudflare;
  }

  /// Check if response is blocked by Imunify360
  bool isImunify360Response(Response response) {
    return detectBotProtection(response) == protectionImunify360;
  }

  /// Check if response is blocked by any bot protection
  bool isBotProtectedResponse(Response response) {
    return detectBotProtection(response) != protectionNone;
  }

  /// Detect what type of bot protection is blocking the request
  /// Returns: 'none', 'cloudflare', 'imunify360', or 'generic'
  String detectBotProtection(Response response) {
    final responseData = response.data?.toString() ?? '';
    final contentType = response.headers.value('content-type') ?? '';
    final isHtml = contentType.contains('text/html');

    // Check for Imunify360 (returns JSON with message)
    if (responseData.toLowerCase().contains('imunify360') ||
        responseData.toLowerCase().contains('access denied by imunify') ||
        responseData.toLowerCase().contains('bot-protection')) {
      return protectionImunify360;
    }

    // Check for Cloudflare (returns HTML challenge page)
    if (isHtml) {
      final cloudflareSignatures = [
        'One moment, please...',
        'Checking your browser',
        'cf-browser-verification',
        'cloudflare',
        'Just a moment...',
        'Enable JavaScript and cookies',
        '__cf_chl_opt',
        'challenge-platform',
      ];

      for (final signature in cloudflareSignatures) {
        if (responseData.toLowerCase().contains(signature.toLowerCase())) {
          return protectionCloudflare;
        }
      }

      // Check for Cloudflare headers
      final cfRay = response.headers.value('cf-ray');
      if (cfRay != null) {
        return protectionCloudflare;
      }
    }

    // Check for generic access denied
    if (responseData.toLowerCase().contains('access denied') ||
        responseData.toLowerCase().contains('forbidden') ||
        response.statusCode == 403) {
      return protectionGeneric;
    }

    return protectionNone;
  }

  /// Fetch URL with automatic bot protection retry
  /// 
  /// If Cloudflare protection is detected, waits and retries automatically.
  /// For Imunify360 (IP-based blocking), fails immediately as retry won't help.
  /// Returns the response after successful fetch or throws after max retries.
  /// 
  /// Usage:
  /// ```dart
  /// final response = await fetchWithCloudflareRetry(
  ///   () => dio.get(apiUrl),
  ///   'banner API',
  /// );
  /// ```
  Future<Response> fetchWithCloudflareRetry(
    Future<Response> Function() fetchFunction, {
    String? apiName,
    int maxRetries = _maxCloudflareRetries,
    int retryDelayMs = _cloudflareRetryDelayMs,
  }) async {
    int attempts = 0;
    Response? lastResponse;
    String? lastProtectionType;

    while (attempts < maxRetries) {
      attempts++;

      try {
        final response = await fetchFunction();
        lastResponse = response;

        // Detect bot protection type
        final protectionType = detectBotProtection(response);
        lastProtectionType = protectionType;

        // Handle Imunify360 - IP-based blocking, retry won't help
        if (protectionType == protectionImunify360) {
          debugPrint(
            '[${apiName ?? 'API'}] Imunify360 bot protection detected. '
            'Request blocked by server. Using fallback data.'
          );
          // Don't retry - Imunify360 blocks by IP, retrying won't help
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: 'Access denied by Imunify360 bot-protection. Using fallback data.',
            type: DioExceptionType.badResponse,
          );
        }
        
        // Handle Cloudflare - might pass after waiting
        if (protectionType == protectionCloudflare) {
          debugPrint(
            '[${apiName ?? 'API'}] Cloudflare protection detected (attempt $attempts/$maxRetries). '
            'Waiting ${retryDelayMs}ms before retry...'
          );

          // Wait before retry
          await Future.delayed(Duration(milliseconds: retryDelayMs));
          continue;
        }

        // Handle generic access denied
        if (protectionType == protectionGeneric) {
          debugPrint(
            '[${apiName ?? 'API'}] Access denied (attempt $attempts/$maxRetries). '
            'Waiting ${retryDelayMs}ms before retry...'
          );
          await Future.delayed(Duration(milliseconds: retryDelayMs));
          continue;
        }

        // Successful non-protected response
        if (attempts > 1) {
          debugPrint('[${apiName ?? 'API'}] Successfully bypassed protection on attempt $attempts');
        }
        return response;

      } catch (e) {
        // If it's already a DioException from Imunify360, rethrow immediately
        if (e is DioException && e.message?.contains('Imunify360') == true) {
          rethrow;
        }

        debugPrint('[${apiName ?? 'API'}] Error on attempt $attempts: $e');

        if (attempts >= maxRetries) {
          rethrow;
        }

        // Wait before retry on error
        await Future.delayed(Duration(milliseconds: retryDelayMs));
      }
    }

    // If we've exhausted retries and last response was protected, throw error
    if (lastResponse != null && lastProtectionType != protectionNone) {
      throw DioException(
        requestOptions: lastResponse.requestOptions,
        response: lastResponse,
        message: 'Bot protection active ($lastProtectionType) after $maxRetries attempts. Using fallback data.',
        type: DioExceptionType.badResponse,
      );
    }

    // Return last response if available
    if (lastResponse != null) {
      return lastResponse;
    }

    throw DioException(
      requestOptions: RequestOptions(path: ''),
      message: 'Failed to fetch after $maxRetries attempts',
      type: DioExceptionType.unknown,
    );
  }

  /// Perform GET request
  Future<BaseResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
    Options? options,
    CancelToken? cancelToken,
    bool skipAuth = false,
  }) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: _mergeOptions(options, skipAuth: skipAuth),
        cancelToken: cancelToken,
      );

      return _parseResponse(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Perform POST request
  Future<BaseResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
    Options? options,
    CancelToken? cancelToken,
    bool skipAuth = false,
  }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options, skipAuth: skipAuth),
        cancelToken: cancelToken,
      );

      return _parseResponse(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Perform PUT request
  Future<BaseResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
    Options? options,
    CancelToken? cancelToken,
    bool skipAuth = false,
  }) async {
    try {
      final response = await dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options, skipAuth: skipAuth),
        cancelToken: cancelToken,
      );

      return _parseResponse(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Perform PATCH request
  Future<BaseResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
    Options? options,
    CancelToken? cancelToken,
    bool skipAuth = false,
  }) async {
    try {
      final response = await dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options, skipAuth: skipAuth),
        cancelToken: cancelToken,
      );

      return _parseResponse(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Perform DELETE request
  Future<BaseResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
    Options? options,
    CancelToken? cancelToken,
    bool skipAuth = false,
  }) async {
    try {
      final response = await dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options, skipAuth: skipAuth),
        cancelToken: cancelToken,
      );

      return _parseResponse(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Perform multipart file upload
  Future<BaseResponse<T>> uploadFile<T>(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    T Function(Map<String, dynamic>)? parser,
    void Function(int, int)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      final response = await dio.post(
        endpoint,
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
      );

      return _parseResponse(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download file
  Future<void> downloadFile(
    String url,
    String savePath, {
    void Function(int, int)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Parse response to BaseResponse
  BaseResponse<T> _parseResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? parser,
  ) {
    if (response.data == null) {
      return BaseResponse.success(statusCode: response.statusCode);
    }

    // Check if response indicates an error
    if (response.statusCode != null && response.statusCode! >= 400) {
      final data = response.data;
      String? message;
      String? errorCode;

      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? data['error'] as String?;
        errorCode = data['error_code'] as String?;
      }

      return BaseResponse.error(
        message: message,
        errorCode: errorCode,
        statusCode: response.statusCode,
      );
    }

    // Parse successful response
    if (response.data is Map<String, dynamic>) {
      return BaseResponse.fromJson(response.data, parser);
    }

    // Return raw data if not a map
    return BaseResponse.success(
      data: response.data as T?,
      statusCode: response.statusCode,
    );
  }

  /// Merge options with skipAuth extra
  Options _mergeOptions(Options? options, {bool skipAuth = false}) {
    final baseOptions = options ?? Options();
    return baseOptions.copyWith(
      extra: {
        ...?baseOptions.extra,
        'skipAuth': skipAuth,
      },
    );
  }

  /// Handle Dio errors
  ApiException _handleError(DioException e) {
    // If error is already an ApiException, return it
    if (e.error is ApiException) {
      return e.error as ApiException;
    }
    return ApiException.fromDioException(e);
  }
}
