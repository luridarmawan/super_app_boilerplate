import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_info.dart';
import '../../core/network/repository/campaign_home_repository.dart';

class CampaignHomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const CampaignHomeScreen({
    super.key,
    this.onComplete,
  });

  @override
  ConsumerState<CampaignHomeScreen> createState() => _CampaignHomeScreenState();
}

class _CampaignHomeScreenState extends ConsumerState<CampaignHomeScreen> {
  int _currentIndex = 0;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _onTap() {
    final campaignState = ref.read(campaignHomeProvider);
    campaignState.whenData((items) {
      if (items.isNotEmpty) {
        final nextIndex = _currentIndex + 1;
        
        // If on last item, go to next screen
        if (nextIndex >= items.length) {
          debugPrint('[CampaignScreen] Last item tapped, calling onComplete');
          widget.onComplete?.call();
          return;
        }
        
        setState(() {
          _currentIndex = nextIndex;
        });
        _initMediaForIndex(nextIndex, items);
      }
    });
  }

  void _initMediaForIndex(int index, List<CampaignHomeItem> items) {
    _videoController?.dispose();
    _videoController = null;

    if (index >= 0 && index < items.length) {
      final item = items[index];
      final mediaUrl = item.mediaUrl;

      if (mediaUrl.isNotEmpty) {
        final isVideo = mediaUrl.endsWith('.mp4') ||
            mediaUrl.endsWith('.webm') ||
            mediaUrl.contains('video');

        if (isVideo) {
          _videoController = VideoPlayerController.networkUrl(
            Uri.parse(mediaUrl),
          )..initialize().then((_) {
              if (mounted) {
                _videoController?.play();
                setState(() {});
              }
            });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaignState = ref.watch(campaignHomeProvider);
    final size = MediaQuery.of(context).size;

    debugPrint('[CampaignScreen] Building screen, state: ${campaignState.when<String>(
      loading: () => 'loading',
      error: (e, s) => 'error: $e',
      data: (d) => 'data: ${d.length} items',
    )}');

    return GestureDetector(
      onTap: _onTap,
      child: Scaffold(
        body: campaignState.when(
          loading: () => _buildLoadingBackground(size),
          error: (error, stack) {
            debugPrint('[CampaignScreen] Error state, calling onComplete immediately');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onComplete?.call();
            });
            return _buildLoadingBackground(size);
          },
          data: (items) {
            debugPrint('[CampaignScreen] Data: ${items.length} items');
            if (items.isEmpty) {
              debugPrint('[CampaignScreen] Empty data, calling onComplete');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onComplete?.call();
              });
              return _buildLoadingBackground(size);
            }

            final item = items[_currentIndex];
            final mediaUrl = item.mediaUrl;
            final isVideo = mediaUrl.endsWith('.mp4') ||
                mediaUrl.endsWith('.webm') ||
                mediaUrl.contains('video');

            if (_videoController == null && isVideo && mediaUrl.isNotEmpty) {
              _initMediaForIndex(_currentIndex, items);
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                if (isVideo && mediaUrl.isNotEmpty && _videoController != null)
                  _buildVideoBackground()
                else if (mediaUrl.isNotEmpty)
                  _buildImageBackground(mediaUrl)
                else
                  _buildGradientBackground(context),
                _buildContent(context, item),
                if (items.length > 1) _buildPageIndicator(items.length),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingBackground(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5), Color(0xFF90CAF9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImageBackground(String mediaUrl) {
    return CachedNetworkImage(
      imageUrl: mediaUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.black,
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.black,
      ),
    );
  }

  Widget _buildVideoBackground() {
    if (_videoController != null &&
        _videoController!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }
    return Container(color: Colors.black);
  }

  Widget _buildGradientBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppInfo.splashGradientColors ?? [
            colorScheme.primary,
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CampaignHomeItem item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Text(
              item.title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              item.subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Text(
                'Tap to continue',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 32,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: index == _currentIndex ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index == _currentIndex
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
