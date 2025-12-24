/// Base Response Model
/// Standard wrapper for all API responses
class BaseResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? meta;

  const BaseResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.errorCode,
    this.meta,
  });

  /// Create a successful response
  factory BaseResponse.success({
    T? data,
    String? message,
    int? statusCode,
    Map<String, dynamic>? meta,
  }) {
    return BaseResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
      meta: meta,
    );
  }

  /// Create an error response
  factory BaseResponse.error({
    String? message,
    String? errorCode,
    int? statusCode,
    Map<String, dynamic>? meta,
  }) {
    return BaseResponse(
      success: false,
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
      meta: meta,
    );
  }

  /// Parse from JSON with a data parser function
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? dataParser,
  ) {
    final dynamic rawData = json['data'];
    T? parsedData;

    if (rawData != null && dataParser != null) {
      if (rawData is Map<String, dynamic>) {
        parsedData = dataParser(rawData);
      }
    } else if (rawData is T) {
      parsedData = rawData;
    }

    return BaseResponse(
      success: json['success'] ?? (json['status'] == 'success'),
      message: json['message'] as String?,
      data: parsedData,
      statusCode: json['status_code'] as int?,
      errorCode: json['error_code'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  /// Check if response has data
  bool get hasData => data != null;

  /// Check if response has error
  bool get hasError => !success;

  @override
  String toString() {
    return 'BaseResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> extends BaseResponse<List<T>> {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  const PaginatedResponse({
    required super.success,
    super.message,
    super.data,
    super.statusCode,
    super.errorCode,
    super.meta,
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  /// Parse from JSON with item parser
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final List<T> items = [];
    final dynamic rawData = json['data'];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          items.add(itemParser(item));
        }
      }
    }

    final meta = json['meta'] as Map<String, dynamic>?;
    final pagination = json['pagination'] as Map<String, dynamic>?;

    return PaginatedResponse(
      success: json['success'] ?? (json['status'] == 'success'),
      message: json['message'] as String?,
      data: items,
      statusCode: json['status_code'] as int?,
      errorCode: json['error_code'] as String?,
      meta: meta,
      currentPage: pagination?['current_page'] ?? meta?['current_page'],
      lastPage: pagination?['last_page'] ?? meta?['last_page'],
      perPage: pagination?['per_page'] ?? meta?['per_page'],
      total: pagination?['total'] ?? meta?['total'],
    );
  }

  /// Check if there are more pages
  bool get hasNextPage {
    if (currentPage == null || lastPage == null) return false;
    return currentPage! < lastPage!;
  }

  /// Check if at first page
  bool get isFirstPage => currentPage == 1;

  /// Check if at last page
  bool get isLastPage => !hasNextPage;
}
