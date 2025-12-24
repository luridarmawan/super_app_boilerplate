import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/network/repository/article_repository.dart';

/// Model untuk artikel (backward compatible dengan existing code)
class Article {
  final String id;
  final String title;
  final String? excerpt;
  final String? imageUrl;
  final String? author;
  final DateTime? publishedAt;
  final String? category;

  const Article({
    required this.id,
    required this.title,
    this.excerpt,
    this.imageUrl,
    this.author,
    this.publishedAt,
    this.category,
  });

  /// Convert dari ArticleModel (dari API)
  factory Article.fromModel(ArticleModel model) {
    return Article(
      id: model.id,
      title: model.title,
      excerpt: model.excerpt,
      imageUrl: model.imageUrl,
      author: model.author,
      publishedAt: model.publishedAt,
      category: model.category,
    );
  }
}

/// Widget untuk menampilkan artikel dari API
/// 
/// Contoh penggunaan:
/// ```dart
/// // Menggunakan data dari API (recommended)
/// const ArticleListFromApi(
///   title: 'Latest Articles',
///   seeAllText: 'See All',
/// )
/// 
/// // Atau dengan data manual (ArticleList biasa)
/// ArticleList(
///   articles: myArticles,
///   title: 'My Articles',
/// )
/// ```
class ArticleListFromApi extends ConsumerWidget {
  final String? title;
  final String? seeAllText;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<Article>? onArticleTap;
  final bool isHorizontal;
  final double? horizontalHeight;

  const ArticleListFromApi({
    super.key,
    this.title,
    this.seeAllText,
    this.onSeeAllTap,
    this.onArticleTap,
    this.isHorizontal = false,
    this.horizontalHeight = 220,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch articles provider untuk mendapatkan data dari API
    final articlesAsync = ref.watch(articlesProvider);

    return articlesAsync.when(
      // Loading state - Shimmer skeleton untuk UX yang lebih baik
      loading: () => _buildShimmerLoading(context),

      // Error state
      error: (error, stack) => _buildError(context, ref),

      // Success state
      data: (articles) {
        // Convert ArticleModel ke Article
        final articleList = articles.map(Article.fromModel).toList();

        return ArticleList(
          articles: articleList,
          title: title,
          seeAllText: seeAllText,
          onSeeAllTap: onSeeAllTap,
          onArticleTap: onArticleTap,
          isHorizontal: isHorizontal,
          horizontalHeight: horizontalHeight,
        );
      },
    );
  }

  /// Shimmer skeleton loading untuk UX yang lebih interaktif
  Widget _buildShimmerLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (seeAllText != null)
                  _ShimmerBox(
                    width: 60,
                    height: 20,
                    color: colorScheme.surfaceContainerHighest,
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (isHorizontal)
          _buildHorizontalShimmer(context, colorScheme)
        else
          _buildVerticalShimmer(context, colorScheme),
      ],
    );
  }

  Widget _buildHorizontalShimmer(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      height: horizontalHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3, // Show 3 skeleton items
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
            child: SizedBox(
              width: 280,
              child: _HorizontalArticleShimmer(colorScheme: colorScheme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalShimmer(BuildContext context, ColorScheme colorScheme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3, // Show 3 skeleton items
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _VerticalArticleShimmer(colorScheme: colorScheme);
      },
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        const SizedBox(height: 16),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load articles',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.read(articlesProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Shimmer box widget dengan animasi
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.color,
    this.borderRadius = 4,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                widget.color,
                widget.color.withAlpha(120),
                widget.color,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal article shimmer skeleton
class _HorizontalArticleShimmer extends StatelessWidget {
  final ColorScheme colorScheme;

  const _HorizontalArticleShimmer({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = colorScheme.surfaceContainerHighest;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: _ShimmerBox(
              width: double.infinity,
              height: double.infinity,
              color: shimmerColor,
              borderRadius: 0,
            ),
          ),
          // Content placeholder
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(
                    width: double.infinity,
                    height: 16,
                    color: shimmerColor,
                  ),
                  const SizedBox(height: 8),
                  _ShimmerBox(
                    width: 180,
                    height: 14,
                    color: shimmerColor,
                  ),
                  const Spacer(),
                  _ShimmerBox(
                    width: 100,
                    height: 12,
                    color: shimmerColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical article shimmer skeleton
class _VerticalArticleShimmer extends StatelessWidget {
  final ColorScheme colorScheme;

  const _VerticalArticleShimmer({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = colorScheme.surfaceContainerHighest;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Image placeholder
          _ShimmerBox(
            width: 100,
            height: 100,
            color: shimmerColor,
            borderRadius: 0,
          ),
          // Content placeholder
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(
                    width: 50,
                    height: 16,
                    color: shimmerColor,
                  ),
                  const SizedBox(height: 8),
                  _ShimmerBox(
                    width: double.infinity,
                    height: 14,
                    color: shimmerColor,
                  ),
                  const SizedBox(height: 4),
                  _ShimmerBox(
                    width: 150,
                    height: 14,
                    color: shimmerColor,
                  ),
                  const SizedBox(height: 8),
                  _ShimmerBox(
                    width: 80,
                    height: 12,
                    color: shimmerColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// List artikel untuk dashboard
class ArticleList extends StatelessWidget {
  final List<Article> articles;
  final String? title;
  final String? seeAllText;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<Article>? onArticleTap;
  final bool isHorizontal;
  final double? horizontalHeight;

  const ArticleList({
    super.key,
    required this.articles,
    this.title,
    this.seeAllText,
    this.onSeeAllTap,
    this.onArticleTap,
    this.isHorizontal = false,
    this.horizontalHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (seeAllText != null)
                  TextButton(
                    onPressed: onSeeAllTap,
                    child: Text(seeAllText!),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        if (isHorizontal)
          _buildHorizontalList(context)
        else
          _buildVerticalList(context),
      ],
    );
  }

  Widget _buildHorizontalList(BuildContext context) {
    return SizedBox(
      height: horizontalHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < articles.length - 1 ? 12 : 0,
            ),
            child: SizedBox(
              width: 280,
              child: _HorizontalArticleCard(
                article: articles[index],
                onTap: () => onArticleTap?.call(articles[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: articles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _VerticalArticleCard(
          article: articles[index],
          onTap: () => onArticleTap?.call(articles[index]),
        );
      },
    );
  }
}

class _HorizontalArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;

  const _HorizontalArticleCard({
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: article.imageUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.article_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                    ),
                  ),
                  if (article.category != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.category!,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(article.publishedAt),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class _VerticalArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;

  const _VerticalArticleCard({
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Image
            SizedBox(
              width: 100,
              height: 100,
              child: CachedNetworkImage(
                imageUrl: article.imageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.article_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.category!,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(article.publishedAt),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
