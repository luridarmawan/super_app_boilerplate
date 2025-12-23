import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Model untuk artikel
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

  /// Sample articles untuk demo
  static List<Article> get sampleArticles => [
        Article(
          id: '1',
          title: 'How to Maximize Your Super App Experience',
          excerpt:
              'Learn the tips and tricks to get the most out of your Super App...',
          imageUrl: 'https://picsum.photos/400/200?random=10',
          author: 'John Doe',
          publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
          category: 'Tips',
        ),
        Article(
          id: '2',
          title: 'New Payment Features Released',
          excerpt:
              'We have added new payment methods to make your transactions easier...',
          imageUrl: 'https://picsum.photos/400/200?random=11',
          author: 'Jane Smith',
          publishedAt: DateTime.now().subtract(const Duration(days: 1)),
          category: 'News',
        ),
        Article(
          id: '3',
          title: 'Security Tips for Mobile Banking',
          excerpt:
              'Keep your account safe with these essential security practices...',
          imageUrl: 'https://picsum.photos/400/200?random=12',
          author: 'Security Team',
          publishedAt: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Security',
        ),
        Article(
          id: '4',
          title: 'Introducing Loyalty Points Program',
          excerpt:
              'Earn points on every transaction and redeem exciting rewards...',
          imageUrl: 'https://picsum.photos/400/200?random=13',
          author: 'Marketing Team',
          publishedAt: DateTime.now().subtract(const Duration(days: 3)),
          category: 'Promo',
        ),
      ];

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
