import 'package:dio/dio.dart';
import '../exceptions/api_exception.dart';

/// Error Interceptor
/// Centralizes error handling and transforms DioExceptions to ApiExceptions
class ErrorInterceptor extends Interceptor {
  final void Function(ApiException)? onApiError;
  final void Function()? onServerError;
  final void Function()? onNetworkError;

  ErrorInterceptor({
    this.onApiError,
    this.onServerError,
    this.onNetworkError,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = ApiException.fromDioException(err);

    // Invoke callbacks based on error type
    onApiError?.call(apiException);

    if (apiException.isServerError) {
      onServerError?.call();
    }

    if (apiException.isNetworkError) {
      onNetworkError?.call();
    }

    // Transform to ApiException and continue
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
        message: apiException.message,
      ),
    );
  }
}

/// Retry Interceptor
/// Automatically retries failed requests based on configuration
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;
  final List<int> retryStatusCodes;
  final List<DioExceptionType> retryExceptionTypes;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.retryStatusCodes = const [500, 502, 503, 504],
    this.retryExceptionTypes = const [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _shouldRetry(err);
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    if (shouldRetry && retryCount < maxRetries) {
      // Increment retry count
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      // Wait before retrying
      await Future.delayed(retryDelay * (retryCount + 1)); // Exponential backoff

      try {
        // Retry the request
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // If retry also fails, continue with error
        if (e is DioException) {
          return handler.next(e);
        }
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Don't retry if explicitly disabled
    if (err.requestOptions.extra['noRetry'] == true) {
      return false;
    }

    // Check if status code should be retried
    if (err.response != null &&
        retryStatusCodes.contains(err.response!.statusCode)) {
      return true;
    }

    // Check if exception type should be retried
    if (retryExceptionTypes.contains(err.type)) {
      return true;
    }

    return false;
  }
}

/// Header Injection Interceptor
/// Adds common headers to all requests without modifying auth
class CommonHeadersInterceptor extends Interceptor {
  final Map<String, String> Function()? dynamicHeaders;

  CommonHeadersInterceptor({this.dynamicHeaders});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add common headers
    options.headers['X-Request-ID'] = _generateRequestId();
    options.headers['X-Timestamp'] = DateTime.now().toIso8601String();

    // Add any dynamic headers
    if (dynamicHeaders != null) {
      options.headers.addAll(dynamicHeaders!());
    }

    handler.next(options);
  }

  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_randomHex(8)}';
  }

  String _randomHex(int length) {
    const chars = '0123456789abcdef';
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(chars[DateTime.now().microsecond % chars.length]);
    }
    return buffer.toString();
  }
}
