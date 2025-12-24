import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/network/repository/banner_repository.dart';

/// Model for banner item
class BannerItem {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const BannerItem({
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  /// Convert from BannerModel (from API)
  factory BannerItem.fromModel(BannerModel model) {
    return BannerItem(
      imageUrl: model.imageUrl,
      title: model.title,
      subtitle: model.subtitle,
    );
  }

  /// Default banner items for offline mode or when API fails
  static List<BannerItem> get defaultItems => [
    const BannerItem(
      imageUrl: 'https://picsum.photos/800/400?random=1',
      title: 'Offline Mode',
      subtitle: 'You are in offline mode',
    ),
    const BannerItem(
      imageUrl: 'https://picsum.photos/800/400?random=2',
      title: 'Special Promo',
      subtitle: 'Get 50% off on first transaction',
    ),
  ];
}

/// Widget to display banner carousel from API
///
/// Usage example:
/// ```dart
/// // Using data from API (recommended)
/// const BannerCarouselFromApi()
///
/// // Or with manual data (regular BannerCarousel)
/// BannerCarousel(
///   items: myBanners,
/// )
/// ```
class BannerCarouselFromApi extends ConsumerWidget {
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enlargeCenterPage;
  final double viewportFraction;
  final ValueChanged<BannerItem>? onBannerTap;

  const BannerCarouselFromApi({
    super.key,
    this.height = 180,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.enlargeCenterPage = true,
    this.viewportFraction = 0.92,
    this.onBannerTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch banners provider to get data from API
    final bannersAsync = ref.watch(bannersProvider);

    return bannersAsync.when(
      // Loading state - Shimmer skeleton for better UX
      loading: () => _buildShimmerLoading(context),

      // Error state
      error: (error, stack) => _buildError(context, error.toString(), ref),

      // Success state
      data: (banners) {
        // Convert BannerModel to BannerItem
        final bannerItems = banners.map((model) {
          final item = BannerItem.fromModel(model);
          // Wrap with onTap callback
          return BannerItem(
            imageUrl: item.imageUrl,
            title: item.title,
            subtitle: item.subtitle,
            onTap: onBannerTap != null ? () => onBannerTap!(item) : null,
          );
        }).toList();

        return BannerCarousel(
          items: bannerItems,
          height: height,
          autoPlay: autoPlay,
          autoPlayInterval: autoPlayInterval,
          enlargeCenterPage: enlargeCenterPage,
          viewportFraction: viewportFraction,
        );
      },
    );
  }

  /// Shimmer skeleton loading for more interactive UX
  Widget _buildShimmerLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Shimmer banner
        Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: _BannerShimmer(colorScheme: colorScheme),
        ),
        const SizedBox(height: 12),
        // Shimmer indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              width: index == 0 ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Display default banners when offline or API fails
  Widget _buildError(BuildContext context, String error, WidgetRef ref) {
    // Show default banners instead of error UI for better UX
    return BannerCarousel(
      items: BannerItem.defaultItems,
      height: height,
      autoPlay: autoPlay,
      autoPlayInterval: autoPlayInterval,
      enlargeCenterPage: enlargeCenterPage,
      viewportFraction: viewportFraction,
    );
  }
}

/// Banner shimmer skeleton with animation
class _BannerShimmer extends StatefulWidget {
  final ColorScheme colorScheme;

  const _BannerShimmer({required this.colorScheme});

  @override
  State<_BannerShimmer> createState() => _BannerShimmerState();
}

class _BannerShimmerState extends State<_BannerShimmer>
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
    final shimmerColor = widget.colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                shimmerColor,
                shimmerColor.withAlpha(120),
                shimmerColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Shimmer text placeholders
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 20,
                      decoration: BoxDecoration(
                        color: shimmerColor.withAlpha(180),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: shimmerColor.withAlpha(180),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Banner Carousel for dashboard with Material 3 styling
class BannerCarousel extends StatefulWidget {
  final List<BannerItem> items;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enlargeCenterPage;
  final double viewportFraction;

  const BannerCarousel({
    super.key,
    required this.items,
    this.height = 180,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.enlargeCenterPage = true,
    this.viewportFraction = 0.92,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.items.isEmpty) {
      return Container(
        height: widget.height,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No banners available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index, realIndex) {
            final item = widget.items[index];
            return _buildBannerItem(context, item, colorScheme);
          },
          options: CarouselOptions(
            height: widget.height,
            autoPlay: widget.autoPlay,
            autoPlayInterval: widget.autoPlayInterval,
            enlargeCenterPage: widget.enlargeCenterPage,
            viewportFraction: widget.viewportFraction,
            enlargeFactor: 0.2,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildIndicator(colorScheme),
      ],
    );
  }

  Widget _buildBannerItem(
    BuildContext context,
    BannerItem item,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: colorScheme.onPrimaryContainer,
                    size: 48,
                  ),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(153),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Text content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withAlpha(230),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.items.asMap().entries.map((entry) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _currentIndex == entry.key ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentIndex == entry.key
                ? colorScheme.primary
                : colorScheme.primary.withAlpha(77),
          ),
        );
      }).toList(),
    );
  }
}
