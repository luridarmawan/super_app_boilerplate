import 'package:dio/dio.dart';

/// Custom API Exception
/// Unified exception handling for all network errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic data;
  final DioExceptionType? dioErrorType;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.data,
    this.dioErrorType,
  });

  /// Create from DioException
  factory ApiException.fromDioException(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;
    String? errorCode;
    dynamic data = error.response?.data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout. The request took too long.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout. Server took too long to respond.';
        break;
      case DioExceptionType.badResponse:
        message = _parseErrorMessage(error.response);
        errorCode = _parseErrorCode(error.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Invalid SSL certificate.';
        break;
      case DioExceptionType.unknown:
        message = error.message ?? 'An unexpected error occurred.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      data: data,
      dioErrorType: error.type,
    );
  }

  /// Create for specific HTTP status codes
  factory ApiException.fromStatusCode(int statusCode, [String? customMessage]) {
    String message;

    switch (statusCode) {
      case 400:
        message = customMessage ?? 'Bad request. Please check your input.';
        break;
      case 401:
        message = customMessage ?? 'Unauthorized. Please login again.';
        break;
      case 403:
        message = customMessage ?? 'Forbidden. You don\'t have permission.';
        break;
      case 404:
        message = customMessage ?? 'Resource not found.';
        break;
      case 409:
        message = customMessage ?? 'Conflict. Resource already exists.';
        break;
      case 422:
        message = customMessage ?? 'Validation error. Please check your input.';
        break;
      case 429:
        message = customMessage ?? 'Too many requests. Please try again later.';
        break;
      case 500:
        message = customMessage ?? 'Internal server error. Please try again later.';
        break;
      case 502:
        message = customMessage ?? 'Bad gateway. Server is temporarily unavailable.';
        break;
      case 503:
        message = customMessage ?? 'Service unavailable. Please try again later.';
        break;
      default:
        message = customMessage ?? 'An error occurred. Status code: $statusCode';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
    );
  }

  /// Create for network/connection errors
  factory ApiException.noConnection() {
    return const ApiException(
      message: 'No internet connection. Please check your network settings.',
    );
  }

  /// Create for timeout errors
  factory ApiException.timeout() {
    return const ApiException(
      message: 'Request timed out. Please try again.',
    );
  }

  /// Create for unknown errors
  factory ApiException.unknown([String? message]) {
    return ApiException(
      message: message ?? 'An unexpected error occurred.',
    );
  }

  /// Parse error message from response
  static String _parseErrorMessage(Response? response) {
    if (response?.data == null) {
      return 'An error occurred. Status: ${response?.statusCode}';
    }

    final data = response!.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['error_description'] as String? ??
          'An error occurred.';
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return 'An error occurred. Status: ${response.statusCode}';
  }

  /// Parse error code from response
  static String? _parseErrorCode(Response? response) {
    if (response?.data == null) return null;

    final data = response!.data;
    if (data is Map<String, dynamic>) {
      return data['error_code'] as String? ?? data['code'] as String?;
    }

    return null;
  }

  /// Check if error is due to authentication issues
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Check if error is due to network issues
  bool get isNetworkError =>
      dioErrorType == DioExceptionType.connectionError ||
      dioErrorType == DioExceptionType.connectionTimeout;

  /// Check if error is server-side
  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600;

  /// Check if error is client-side
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}
