import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_client.dart';
import '../api_config.dart';
import '../repository/base_repository.dart';
import '../models/base_response.dart';
import '../../constants/app_info.dart';

class CampaignHomeItem {
  final String mediaUrl;
  final String title;
  final String subtitle;
  final String url;

  const CampaignHomeItem({
    required this.mediaUrl,
    required this.title,
    required this.subtitle,
    required this.url,
  });

  factory CampaignHomeItem.fromJson(Map<String, dynamic> json) {
    return CampaignHomeItem(
      mediaUrl: json['media_url'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'media_url': mediaUrl,
        'title': title,
        'subtitle': subtitle,
        'url': url,
      };
}

class CampaignHomeRepository extends BaseRepository {
  static String get _campaignApiUrl => AppInfo.campaignApiURL;

  CampaignHomeRepository({required super.apiClient});

  Future<BaseResponse<List<CampaignHomeItem>>> getCampaignHome() async {
    try {
      debugPrint('[CampaignHome] Fetching from: $_campaignApiUrl');

      final response = await fetchWithCloudflareRetry(
        () => dio.get(
          _campaignApiUrl,
          options: Options(
            headers: {
              'User-Agent': ApiConfig.browserUserAgent,
              'Accept': 'application/json, text/plain, */*',
              'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
            },
          ),
        ),
        apiName: 'CampaignHome',
      );

      debugPrint('[CampaignHome] Response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final home = data['home'];

        if (home is List) {
          debugPrint('[CampaignHome] Found ${home.length} items');
          final items = <CampaignHomeItem>[];
          for (final item in home) {
            if (item is Map<String, dynamic>) {
              items.add(CampaignHomeItem.fromJson(item));
            }
          }
          return BaseResponse.success(
            data: items,
            statusCode: response.statusCode,
          );
        }

        debugPrint('[CampaignHome] No home field found');
        return BaseResponse.success(
          data: <CampaignHomeItem>[],
          statusCode: response.statusCode,
        );
      }

      debugPrint('[CampaignHome] Failed with status: ${response.statusCode}');
      return BaseResponse.error(
        message: 'Failed to fetch campaign home',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('[CampaignHome] Error: ${e.toString()}');
      return BaseResponse.error(
        message: 'Error fetching campaign home: ${e.toString()}',
      );
    }
  }
}

final campaignHomeRepositoryProvider = Provider<CampaignHomeRepository>((ref) {
  return CampaignHomeRepository(apiClient: ref.watch(apiClientProvider));
});

class CampaignHomeNotifier
    extends StateNotifier<AsyncValue<List<CampaignHomeItem>>> {
  final CampaignHomeRepository _repository;

  CampaignHomeNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchCampaignHome();
  }

  Future<void> fetchCampaignHome() async {
    state = const AsyncValue.loading();

    final response = await _repository.getCampaignHome();

    if (response.success && response.data != null) {
      debugPrint('[CampaignHomeNotifier] Loaded ${response.data!.length} items');
      state = AsyncValue.data(response.data!);
    } else {
      debugPrint('[CampaignHomeNotifier] Error: ${response.message}');
      state = AsyncValue.error(
        response.message ?? 'Failed to fetch campaign home',
        StackTrace.current,
      );
    }
  }

  Future<void> refresh() async {
    await fetchCampaignHome();
  }
}

final campaignHomeProvider =
    StateNotifierProvider<CampaignHomeNotifier, AsyncValue<List<CampaignHomeItem>>>(
  (ref) => CampaignHomeNotifier(ref.watch(campaignHomeRepositoryProvider)),
);
