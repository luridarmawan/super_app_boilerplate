import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_client.dart';
import '../repository/base_repository.dart';
import '../models/base_response.dart';

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

  const ArticleModel({
    required this.id,
    required this.title,
    this.excerpt,
    this.imageUrl,
    this.author,
    this.publishedAt,
    this.category,
  });

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
      };
}

/// Article Repository
/// Repository untuk mengambil data artikel dari API
class ArticleRepository extends BaseRepository {
  /// Base URL untuk API artikel
  /// Ganti dengan URL API Anda
  static const String _articleApiUrl = 'https://api.carik.id/dummy/article.json';

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
      // Fetch langsung dari URL eksternal
      // Menggunakan dio.get dengan URL lengkap
      final response = await dio.get(_articleApiUrl);

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

  /// Ambil artikel berdasarkan kategori
  Future<BaseResponse<List<ArticleModel>>> getArticlesByCategory(
    String category,
  ) async {
    try {
      final response = await getArticles();

      if (response.success && response.data != null) {
        final filtered = response.data!
            .where((a) =>
                a.category?.toLowerCase() == category.toLowerCase())
            .toList();
        return BaseResponse.success(data: filtered);
      }

      return BaseResponse.error(message: 'Failed to fetch articles');
    } catch (e) {
      return BaseResponse.error(message: e.toString());
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
