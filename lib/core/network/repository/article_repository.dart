import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_client.dart';
import '../api_config.dart';
import '../repository/base_repository.dart';
import '../models/base_response.dart';
import '../../constants/app_info.dart';

/// Article Model
/// Model untuk data artikel dari API
class ArticleModel {
  final String id;
  final String title;
  final String? excerpt;
  final String? imageUrl;
  final String? author;
  final DateTime? publishedAt;
  final String? category;
  final String? slug;

  const ArticleModel({
    required this.id,
    required this.title,
    this.excerpt,
    this.imageUrl,
    this.author,
    this.publishedAt,
    this.category,
    this.slug,
    this.content,
    this.prev,
    this.next,
  });

  final String? content;
  final ArticleModel? prev;
  final ArticleModel? next;

  /// Parse from JSON
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      excerpt: json['excerpt'] as String?,
      imageUrl: json['imageUrl'] as String?,
      author: json['author'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      category: json['category'] as String?,
      slug: json['slug'] as String?,
      content: json['content'] as String?,
      prev: json['prev'] != null ? ArticleModel.fromJson(json['prev'] as Map<String, dynamic>) : null,
      next: json['next'] != null ? ArticleModel.fromJson(json['next'] as Map<String, dynamic>) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'excerpt': excerpt,
        'imageUrl': imageUrl,
        'author': author,
        'publishedAt': publishedAt?.toIso8601String(),
        'category': category,
        'slug': slug,
        'content': content,
        'prev': prev?.toJson(),
        'next': next?.toJson(),
      };
}

/// Article Repository
/// Repository untuk mengambil data artikel dari API
class ArticleRepository extends BaseRepository {
  /// Base URL untuk API artikel
  /// Configured via ARTICLE_API_URL in .env file
  static String get _articleLastApiUrl => AppInfo.articleLastApiURL;

  ArticleRepository({required super.apiClient});

  /// Ambil semua artikel
  /// 
  /// Contoh penggunaan:
  /// ```dart
  /// final response = await articleRepository.getArticles();
  /// if (response.success && response.data != null) {
  ///   for (final article in response.data!) {
  ///     print(article.title);
  ///   }
  /// }
  /// ```
  Future<BaseResponse<List<ArticleModel>>> getArticles() async {
    try {
      // Fetch with bot protection retry and browser-like headers
      final response = await fetchWithCloudflareRetry(
        () => dio.get(
          _articleLastApiUrl,
          options: Options(
            headers: {
              'User-Agent': ApiConfig.browserUserAgent,
              'Accept': 'application/json, text/plain, */*',
              'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
            },
          ),
        ),
        apiName: 'Article',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<ArticleModel> articles = [];

        // Parse response (array langsung)
        if (response.data is List) {
          for (final item in response.data) {
            if (item is Map<String, dynamic>) {
              articles.add(ArticleModel.fromJson(item));
            }
          }
        }

        return BaseResponse.success(
          data: articles,
          statusCode: response.statusCode,
        );
      }

      return BaseResponse.error(
        message: 'Failed to fetch articles',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return BaseResponse.error(
        message: 'Error fetching articles: ${e.toString()}',
      );
    }
  }

  /// Ambil artikel berdasarkan ID
  Future<BaseResponse<ArticleModel>> getArticleById(String id) async {
    try {
      final response = await getArticles();

      if (response.success && response.data != null) {
        final article = response.data!.firstWhere(
          (a) => a.id == id,
          orElse: () => throw Exception('Article not found'),
        );
        return BaseResponse.success(data: article);
      }

      return BaseResponse.error(message: 'Article not found');
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }

  /// Ambil detail artikel berdasarkan slug
  Future<BaseResponse<ArticleModel>> getArticleBySlug(String slug) async {
    try {
      final url = AppInfo.articleApiURL.replaceAll('{slug}', slug);

      final response = await fetchWithCloudflareRetry(
        () => dio.get(
          url,
          options: Options(
            headers: {
              'User-Agent': ApiConfig.browserUserAgent,
              'Accept': 'application/json, text/plain, */*',
              'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
            },
          ),
        ),
        apiName: 'Article Detail',
      );

      if (response.statusCode == 200 && response.data != null) {
        return BaseResponse.success(
          data: ArticleModel.fromJson(response.data as Map<String, dynamic>),
          statusCode: response.statusCode,
        );
      }

      return BaseResponse.error(
        message: 'Failed to fetch article detail',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return BaseResponse.error(
        message: 'Error fetching article detail: ${e.toString()}',
      );
    }
  }

  /// Ambil artikel rekomendasi
  Future<BaseResponse<List<ArticleModel>>> getRecommendedArticles() async {
    try {
      final response = await fetchWithCloudflareRetry(
        () => dio.get(
          AppInfo.articleRecommendationApiURL,
          options: Options(
            headers: {
              'User-Agent': ApiConfig.browserUserAgent,
              'Accept': 'application/json, text/plain, */*',
              'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
            },
          ),
        ),
        apiName: 'Article Recommendation',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<ArticleModel> articles = [];

        if (response.data is List) {
          for (final item in response.data) {
            if (item is Map<String, dynamic>) {
              articles.add(ArticleModel.fromJson(item));
            }
          }
        }

        return BaseResponse.success(
          data: articles,
          statusCode: response.statusCode,
        );
      }

      return BaseResponse.error(
        message: 'Failed to fetch recommended articles',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return BaseResponse.error(
        message: 'Error fetching recommended articles: ${e.toString()}',
      );
    }
  }
}

/// Article Repository Provider
/// Menggunakan Riverpod untuk dependency injection
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(apiClient: ref.watch(apiClientProvider));
});

/// Articles State Provider
/// StateNotifier untuk mengelola state artikel dengan loading, error, dan data
class ArticlesNotifier extends StateNotifier<AsyncValue<List<ArticleModel>>> {
  final ArticleRepository _repository;

  ArticlesNotifier(this._repository) : super(const AsyncValue.loading()) {
    // Auto-fetch saat provider dibuat
    fetchArticles();
  }

  /// Fetch articles dari API
  Future<void> fetchArticles() async {
    state = const AsyncValue.loading();

    final response = await _repository.getArticles();

    if (response.success && response.data != null) {
      state = AsyncValue.data(response.data!);
    } else {
      state = AsyncValue.error(
        response.message ?? 'Failed to fetch articles',
        StackTrace.current,
      );
    }
  }

  /// Refresh articles
  Future<void> refresh() async {
    await fetchArticles();
  }
}

/// Articles Provider
/// Provider untuk mengakses daftar artikel dengan auto-fetch
final articlesProvider =
    StateNotifierProvider<ArticlesNotifier, AsyncValue<List<ArticleModel>>>(
  (ref) => ArticlesNotifier(ref.watch(articleRepositoryProvider)),
);

/// Recommended Articles Notifier
class RecommendedArticlesNotifier extends StateNotifier<AsyncValue<List<ArticleModel>>> {
  final ArticleRepository _repository;

  RecommendedArticlesNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    state = const AsyncValue.loading();
    final response = await _repository.getRecommendedArticles();

    if (response.success && response.data != null) {
      state = AsyncValue.data(response.data!);
    } else {
      state = AsyncValue.error(
        response.message ?? 'Failed to fetch recommended articles',
        StackTrace.current,
      );
    }
  }

  Future<void> refresh() async {
    await fetchArticles();
  }
}

/// Recommended Articles Provider
final recommendedArticlesProvider =
    StateNotifierProvider<RecommendedArticlesNotifier, AsyncValue<List<ArticleModel>>>(
  (ref) => RecommendedArticlesNotifier(ref.watch(articleRepositoryProvider)),
);
