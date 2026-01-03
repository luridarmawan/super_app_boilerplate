import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/network/repository/article_repository.dart';

class ArticleScreen extends ConsumerStatefulWidget {
  final String slug;

  const ArticleScreen({super.key, required this.slug});

  @override
  ConsumerState<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  ArticleModel? _article;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchArticle(widget.slug);
  }

  @override
  void didUpdateWidget(ArticleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _fetchArticle(widget.slug);
    }
  }

  Future<void> _fetchArticle(String slug) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(articleRepositoryProvider);
      final response = await repository.getArticleBySlug(slug);

      if (response.success && response.data != null) {
        setState(() {
          _article = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load article';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    // Format: dd mmm yyyy hh:nn -> 26 Jun 2022 12:40
    return DateFormat('dd MMM yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchArticle(widget.slug),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Article not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _article!.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _article!.imageUrl!,
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _article!.title,
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
                        _formatDate(_article!.publishedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    //   if (_article!.author != null) ...[
                    //     const SizedBox(width: 16),
                    //     Icon(Icons.person, size: 16, color: colorScheme.onSurfaceVariant),
                    //     const SizedBox(width: 4),
                    //     Text(
                    //       _article!.author!,
                    //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    //             color: colorScheme.onSurfaceVariant,
                    //           ),
                    //     ),
                    //   ],
                    ],
                  ),
                  const Divider(height: 32),
                  // Content - Simple tag stripping and display
                  Text(
                    _stripHtml(_article!.content ?? ''),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 32),
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_article!.prev != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (_article!.prev?.slug != null) {
                                _fetchArticle(_article!.prev!.slug!);
                              }
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Prev'),
                          ),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: 16),
                      if (_article!.next != null)
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                if (_article!.next?.slug != null) {
                                  _fetchArticle(_article!.next!.slug!);
                                }
                              },
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Next'),
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stripHtml(String htmlString) {
    // Basic HTML tag removal
    final document = htmlString.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ');
    // Remove extra spaces
    return document.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
