import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/repository/article_repository.dart';
import 'article_list.dart';

/// Recommended Article Widget
/// Fetches articles from appinfo.articleRecommendationApiURL
class ArticleRecommendation extends ConsumerWidget {
  final ValueChanged<Article>? onArticleTap;

  const ArticleRecommendation({
    super.key,
    this.onArticleTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recommendedAsync = ref.watch(recommendedArticlesProvider);

    return recommendedAsync.when(
      loading: () => _buildShimmerLoading(context),
      error: (error, stack) => _buildError(context, ref),
      data: (articles) {
        if (articles.isEmpty) return const SizedBox.shrink();
        
        final articleList = articles.map(Article.fromModel).toList();

        return ArticleList(
          articles: articleList,
          title: l10n.recommendedForYou,
          isHorizontal: false,
          onArticleTap: onArticleTap,
        );
      },
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.l10n.recommendedForYou,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 12),
        // Use the shimmer from ArticleListFromApi or define here
        // Since ArticleListFromApi's shimmer is private, we can't reuse it directly
        // unless we make it public. For now, let's keep it simple.
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
             return Card(
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 14,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 150,
                            height: 16,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
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
            const Text('Failed to load recommendations'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => ref.read(recommendedArticlesProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
