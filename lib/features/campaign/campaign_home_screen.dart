import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
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
  ChewieController? _chewieController;
  VideoPlayerController? _preloadController;
  ChewieController? _preloadChewieController;
  bool _isVideoLoading = false;

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
    _videoController?.removeListener(_onVideoStateChanged);
    _videoController?.dispose();
    _chewieController?.dispose();
    _preloadController?.dispose();
    _preloadChewieController?.dispose();
    _isVideoLoading = false;
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

        // Use preloaded controller if available
        if (_preloadController != null && _preloadController!.value.isInitialized) {
          _videoController?.dispose();
          _chewieController?.dispose();

          _videoController = _preloadController;
          _chewieController = _preloadChewieController;
          _preloadController = null;
          _preloadChewieController = null;

          _videoController?.setLooping(true);
          _videoController?.play();
        } else {
          _initMediaForIndex(nextIndex, items);
        }

        setState(() {
          _currentIndex = nextIndex;
        });

        // Preload next video after switch
        _preloadNextVideo(nextIndex, items);
      }
    });
  }

  void _initFirstVideo(List<CampaignHomeItem> items) {
    if (items.isEmpty) return;
    _initMediaForIndex(0, items);
    _preloadNextVideo(0, items);
  }

  void _setVideoLoading(bool loading) {
    setState(() {
      _isVideoLoading = loading;
    });
  }

  void _initMediaForIndex(int index, List<CampaignHomeItem> items) {
    _videoController?.dispose();
    _chewieController?.dispose();
    _videoController = null;
    _chewieController = null;
    _setVideoLoading(true);

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
          );

          _videoController!.addListener(_onVideoStateChanged);

          _videoController!.initialize().then((_) {
            if (mounted) {
              _setVideoLoading(false);
              _chewieController = ChewieController(
                videoPlayerController: _videoController!,
                autoPlay: true,
                looping: true,
                showControls: false,
                showOptions: false,
                allowFullScreen: false,
                allowMuting: false,
                allowPlaybackSpeedChanging: false,
                placeholder: Container(
                  color: Colors.black,
                ),
                aspectRatio: _videoController!.value.aspectRatio,
              );
              _videoController?.setLooping(true);
              _videoController?.play();
              setState(() {});
            }
          }).catchError((_) {
            if (mounted) {
              _setVideoLoading(false);
            }
          });

          _preloadNextVideo(index, items);
        }
      }
    }
  }

  void _onVideoStateChanged() {
    if (_videoController != null && !_videoController!.value.isPlaying) {
      // Auto-resume if paused unexpectedly (not from user interaction)
      if (mounted && _videoController!.value.isInitialized) {
        _videoController?.play();
      }
    }
  }

  void _preloadNextVideo(int currentIndex, List<CampaignHomeItem> items) {
    _preloadController?.dispose();
    _preloadChewieController?.dispose();
    _preloadController = null;
    _preloadChewieController = null;

    final nextIndex = currentIndex + 1;
    if (nextIndex >= items.length) return;

    final nextItem = items[nextIndex];
    final mediaUrl = nextItem.mediaUrl;

    if (mediaUrl.isNotEmpty) {
      final isVideo = mediaUrl.endsWith('.mp4') ||
          mediaUrl.endsWith('.webm') ||
          mediaUrl.contains('video');

      if (isVideo) {
        _preloadController = VideoPlayerController.networkUrl(
          Uri.parse(mediaUrl),
        );
        _preloadController!.initialize().then((_) {
          if (mounted && _preloadController!.value.isInitialized) {
            _preloadChewieController = ChewieController(
              videoPlayerController: _preloadController!,
              autoPlay: false,
              looping: true,
              showControls: false,
              aspectRatio: _preloadController!.value.aspectRatio,
            );
            setState(() {});
          }
        });
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
              _initFirstVideo(items);
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
    if (_chewieController != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Chewie(
            controller: _chewieController!,
          ),
          if (_isVideoLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      );
    }
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
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
