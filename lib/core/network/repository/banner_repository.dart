import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_client.dart';
import '../repository/base_repository.dart';
import '../models/base_response.dart';

/// Banner Model
/// Model for banner data from API
class BannerModel {
  final String imageUrl;
  final String title;
  final String? subtitle;

  const BannerModel({
    required this.imageUrl,
    required this.title,
    this.subtitle,
  });

  /// Parse from JSON
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      imageUrl: json['imageUrl'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'title': title,
        'subtitle': subtitle,
      };
}

/// Banner Repository
/// Repository to fetch banner data from API
class BannerRepository extends BaseRepository {
  /// Base URL for banner API
  /// Replace with your API URL
  static const String _bannerApiUrl = 'https://api.carik.id/dummy/banner.json';

  BannerRepository({required super.apiClient});

  /// Get all banners
  ///
  /// Usage example:
  /// ```dart
  /// final response = await bannerRepository.getBanners();
  /// if (response.success && response.data != null) {
  ///   for (final banner in response.data!) {
  ///     print(banner.title);
  ///   }
  /// }
  /// ```
  Future<BaseResponse<List<BannerModel>>> getBanners() async {
    try {
      // Fetch directly from external URL
      final response = await dio.get(_bannerApiUrl);

      if (response.statusCode == 200 && response.data != null) {
        final List<BannerModel> banners = [];

        // Parse response (direct array)
        if (response.data is List) {
          for (final item in response.data) {
            if (item is Map<String, dynamic>) {
              banners.add(BannerModel.fromJson(item));
            }
          }
        }

        return BaseResponse.success(
          data: banners,
          statusCode: response.statusCode,
        );
      }

      return BaseResponse.error(
        message: 'Failed to fetch banners',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return BaseResponse.error(
        message: 'Error fetching banners: ${e.toString()}',
      );
    }
  }
}

/// Banner Repository Provider
/// Using Riverpod for dependency injection
final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  return BannerRepository(apiClient: ref.watch(apiClientProvider));
});

/// Banners State Provider
/// StateNotifier to manage banner state with loading, error, and data
class BannersNotifier extends StateNotifier<AsyncValue<List<BannerModel>>> {
  final BannerRepository _repository;

  BannersNotifier(this._repository) : super(const AsyncValue.loading()) {
    // Auto-fetch when provider is created
    fetchBanners();
  }

  /// Fetch banners from API
  Future<void> fetchBanners() async {
    state = const AsyncValue.loading();

    final response = await _repository.getBanners();

    if (response.success && response.data != null) {
      state = AsyncValue.data(response.data!);
    } else {
      state = AsyncValue.error(
        response.message ?? 'Failed to fetch banners',
        StackTrace.current,
      );
    }
  }

  /// Refresh banners
  Future<void> refresh() async {
    await fetchBanners();
  }
}

/// Banners Provider
/// Provider to access banner list with auto-fetch
final bannersProvider =
    StateNotifierProvider<BannersNotifier, AsyncValue<List<BannerModel>>>(
  (ref) => BannersNotifier(ref.watch(bannerRepositoryProvider)),
);
