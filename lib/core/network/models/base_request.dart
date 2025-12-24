/// Base Request Model
/// Contains shared fields that should be included in all API requests
abstract class BaseRequest {
  /// Device ID for tracking
  String? deviceId;

  /// Client timestamp
  DateTime? timestamp;

  /// Request locale
  String? locale;

  /// Platform identifier (android/ios)
  String? platform;

  /// App version
  String? appVersion;

  BaseRequest({
    this.deviceId,
    this.timestamp,
    this.locale,
    this.platform,
    this.appVersion,
  });

  /// Convert to JSON map with common fields
  Map<String, dynamic> toJson();

  /// Get base fields as map for merging
  Map<String, dynamic> get baseFields => {
        if (deviceId != null) 'device_id': deviceId,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
        if (locale != null) 'locale': locale,
        if (platform != null) 'platform': platform,
        if (appVersion != null) 'app_version': appVersion,
      };
}

/// Mixin to add base request fields to any request model
mixin BaseRequestMixin {
  String? deviceId;
  DateTime? timestamp;
  String? locale;
  String? platform;
  String? appVersion;

  /// Get base fields as map for merging
  Map<String, dynamic> get baseFields => {
        if (deviceId != null) 'device_id': deviceId,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
        if (locale != null) 'locale': locale,
        if (platform != null) 'platform': platform,
        if (appVersion != null) 'app_version': appVersion,
      };

  /// Merge base fields with specific request fields
  Map<String, dynamic> mergeWithBase(Map<String, dynamic> specificFields) {
    return {...baseFields, ...specificFields};
  }
}

/// Example concrete request with BaseRequest
class PaginatedRequest extends BaseRequest {
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  PaginatedRequest({
    required this.page,
    this.limit = 20,
    this.sortBy,
    this.sortOrder,
    super.deviceId,
    super.timestamp,
    super.locale,
    super.platform,
    super.appVersion,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...baseFields,
      'page': page,
      'limit': limit,
      if (sortBy != null) 'sort_by': sortBy,
      if (sortOrder != null) 'sort_order': sortOrder,
    };
  }
}
