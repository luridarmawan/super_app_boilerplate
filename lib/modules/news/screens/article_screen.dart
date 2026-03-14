import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import '../../../core/network/repository/article_repository.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../features/dashboard/widgets/article_list.dart';

class ArticleScreen extends ConsumerWidget {
  final String slug;

  const ArticleScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch article detail provider
    final articleAsync = ref.watch(articleDetailProvider(slug));

    return Scaffold(
      body: articleAsync.when(
        loading: () => _buildSkeleton(context),
        error: (err, stack) => _buildError(context, ref, err.toString()),
        data: (article) => _ArticleContent(article: article),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: Container(color: colorScheme.surfaceContainerHighest),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Divider(height: 48),
                for (int i = 0; i < 5; i++) ...[
                  Container(
                    width: double.infinity,
                    height: 16,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(articleDetailProvider(slug)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleContent extends StatelessWidget {
  final ArticleModel article;

  const _ArticleContent({required this.article});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy HH:mm').format(date);
  }

  String _stripHtml(String htmlString) {
    if (htmlString.isEmpty) return '';
    
    // Preserve links by converting <a href="url">text</a> to a marker [L:text|url]
    String content = htmlString.replaceAllMapped(
      RegExp(r'''<a[^>]+href=["']([^"']+)["'][^>]*>(.*?)</a>''', caseSensitive: false),
      (match) {
        final url = match.group(1) ?? '';
        final text = (match.group(2) ?? '').replaceAll(RegExp(r'<[^>]*>'), '');
        if (url.isEmpty) return text;
        return '[L:$text|$url]';
      },
    );

    // Replace block-level tags with newlines
    content = content
        .replaceAll(RegExp(r'</p>|<br\s*/?>|</div>|</h1>|</h2>|</h3>|</h4>|</h5>|</h6>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ')
        // Remove multiple spaces/newlines
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n+'), '\n\n')
        .trim();
        
    return content;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    
    // Split content into paragraphs for lazy rendering
    final content = _stripHtml(article.content ?? '');
    final paragraphs = content.split('\n').where((p) => p.trim().isNotEmpty).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: article.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: colorScheme.surfaceContainerHighest),
                    errorWidget: (context, url, error) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported, size: 64),
                    ),
                  )
                : Container(color: colorScheme.surfaceContainerHighest),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(article.publishedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const Divider(height: 32),
              ],
            ),
          ),
        ),
        // Handle empty content
        if (paragraphs.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No content available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _LinkifiedParagraph(
                    text: paragraphs[index],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          letterSpacing: 0.2,
                        ) ?? const TextStyle(),
                  ),
                ),
                childCount: paragraphs.length,
              ),
            ),
          ),
        // Navigation and Related Articles
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildNavigationButtons(context),
                if (article.related != null && article.related!.isNotEmpty) ...[
                  const SizedBox(height: 48),
                  Text(
                    l10n.recommendedForYou,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ArticleList(
                    articles: article.related!.map(Article.fromModel).toList(),
                    isHorizontal: true,
                    onArticleTap: (item) {
                       if (item.slug != null) {
                         context.pushReplacement('/article/${item.slug}');
                       }
                    },
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (article.prev != null)
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pushReplacement('/article/${article.prev!.slug}'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_ios_new, size: 16),
                  SizedBox(width: 8),
                  Text('Prev'),
                ],
              ),
            ),
          )
        else
          const Spacer(),
        const SizedBox(width: 16),
        if (article.next != null)
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pushReplacement('/article/${article.next!.slug}'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Next'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          )
        else
          const Spacer(),
      ],
    );
  }
}

/// A widget that renders text with clickable URLs
class _LinkifiedParagraph extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _LinkifiedParagraph({required this.text, required this.style});

  @override
    Widget build(BuildContext context) {
    final List<InlineSpan> spans = [];
    
    // Regex to match both our custom [L:text|url] markers and plain URLs
    final combinedRegExp = RegExp(
      r"\[L:([^|\]]+)\|([^\]]+)\]|(https?://[^\s)\]]+)",
      caseSensitive: false,
    );
    
    int lastMatchEnd = 0;
    final matches = combinedRegExp.allMatches(text);

    if (matches.isEmpty) {
      return SelectableText(text, style: style);
    }

    for (final match in matches) {
      // Add text before the match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      
      if (match.group(1) != null) {
        // CASE 1: Custom marker [L:text|url]
        final linkText = match.group(1)!;
        final url = match.group(2)!;
        spans.add(_buildLinkSpan(context, linkText, url));
      } else {
        // CASE 2: Plain URL
        final url = match.group(3)!;
        spans.add(_buildLinkSpan(context, url, url));
      }
      
      lastMatchEnd = match.end;
    }
    
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return SelectableText.rich(
      TextSpan(children: spans, style: style),
    );
  }

  InlineSpan _buildLinkSpan(BuildContext context, String label, String destination) {
    return TextSpan(
      text: label,
      style: style.copyWith(
        color: Theme.of(context).colorScheme.primary,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w500,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          final uri = Uri.tryParse(destination);
          if (uri != null) {
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint('Could not launch $destination: $e');
            }
          }
        },
    );
  }
}
