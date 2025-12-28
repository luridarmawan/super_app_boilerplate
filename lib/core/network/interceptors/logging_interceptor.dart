import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api_config.dart';

/// Logging Interceptor
/// Logs all HTTP requests and responses for debugging
class LoggingInterceptor extends Interceptor {
  final bool enableLogging;
  final bool logRequestBody;
  final bool logResponseBody;
  final int maxBodyLength;

  LoggingInterceptor({
    this.enableLogging = true,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.maxBodyLength = 500,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_shouldLog()) {
      return handler.next(options);
    }

    final buffer = StringBuffer();
    buffer.writeln('┌──────────────────────────────────────────────────────────');
    buffer.writeln('│ 🚀 REQUEST');
    buffer.writeln('├──────────────────────────────────────────────────────────');
    buffer.writeln('│ ${options.method.toUpperCase()} ${options.uri}');
    buffer.writeln('│ Timestamp: ${DateTime.now().toIso8601String()}');

    // Log headers (excluding sensitive data)
    if (options.headers.isNotEmpty) {
      buffer.writeln('│ Headers:');
      options.headers.forEach((key, value) {
        if (!_isSensitiveHeader(key)) {
          buffer.writeln('│   $key: $value');
        } else {
          buffer.writeln('│   $key: [REDACTED]');
        }
      });
    }

    // Log query parameters
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query: ${options.queryParameters}');
    }

    // Log request body
    if (logRequestBody && options.data != null) {
      buffer.writeln('│ Body: ${_truncateBody(options.data)}');
    }

    buffer.writeln('└──────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_shouldLog()) {
      return handler.next(response);
    }

    final buffer = StringBuffer();
    buffer.writeln('┌──────────────────────────────────────────────────────────');
    buffer.writeln('│ ✅ RESPONSE');
    buffer.writeln('├──────────────────────────────────────────────────────────');
    buffer.writeln('│ ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}');
    buffer.writeln('│ Duration: ${_calculateDuration(response)}');

    // Log response body
    if (logResponseBody && response.data != null) {
      buffer.writeln('│ Body: ${_truncateBody(response.data)}');
    }

    buffer.writeln('└──────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_shouldLog()) {
      return handler.next(err);
    }

    final buffer = StringBuffer();
    buffer.writeln('┌──────────────────────────────────────────────────────────');
    buffer.writeln('│ ❌ ERROR');
    buffer.writeln('├──────────────────────────────────────────────────────────');
    buffer.writeln('│ ${err.response?.statusCode ?? 'N/A'} ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}');
    buffer.writeln('│ Type: ${err.type}');
    buffer.writeln('│ Message: ${err.message}');

    // Log error response body
    if (err.response?.data != null) {
      buffer.writeln('│ Response: ${_truncateBody(err.response?.data)}');
    }

    buffer.writeln('└──────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());

    handler.next(err);
  }

  bool _shouldLog() => enableLogging && ApiConfig.enableLogging && kDebugMode;

  bool _isSensitiveHeader(String key) {
    final sensitiveHeaders = ['authorization', 'cookie', 'x-api-key'];
    return sensitiveHeaders.contains(key.toLowerCase());
  }

  String _truncateBody(dynamic data) {
    try {
      String body;
      if (data is Map || data is List) {
        body = const JsonEncoder.withIndent('  ').convert(data);
      } else {
        body = data.toString();
      }

      if (body.length > maxBodyLength) {
        return '${body.substring(0, maxBodyLength)}... [TRUNCATED]';
      }
      return body;
    } catch (_) {
      return data.toString();
    }
  }

  String _calculateDuration(Response response) {
    final requestTime = response.requestOptions.extra['requestTime'];
    if (requestTime is DateTime) {
      final duration = DateTime.now().difference(requestTime);
      return '${duration.inMilliseconds}ms';
    }
    return 'N/A';
  }
}

/// Request timing interceptor (records start time for logging)
class RequestTimingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['requestTime'] = DateTime.now();
    handler.next(options);
  }
}
