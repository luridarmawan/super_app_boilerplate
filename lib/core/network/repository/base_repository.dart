import 'package:dio/dio.dart';
import '../api_client.dart';
import '../models/base_response.dart';
import '../exceptions/api_exception.dart';

/// Base Repository
/// Abstract class that provides common HTTP operations for all repositories
abstract class BaseRepository {
  final ApiClient apiClient;

  BaseRepository({required this.apiClient});

  /// Get Dio instance
  Dio get dio => apiClient.dio;

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
