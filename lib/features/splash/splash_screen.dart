import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_info.dart';
import '../../core/constants/assets.dart';

/// Splash Screen full screen dengan gambar utama
/// 
/// SMOOTH TRANSITION FLOW:
/// 1. Native splash (solid color) tampil instan
/// 2. Flutter splash ini muncul di atas native splash
/// 3. Background image di-preload
/// 4. Setelah image ready, native splash dihapus dengan crossfade
/// 5. Animasi logo dan content masuk
class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  final Duration splashDuration;

  const SplashScreen({
    super.key,
    this.onComplete,
    this.splashDuration = AppInfo.splashScreenDuration,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backgroundFadeAnimation;
  
  bool _nativeSplashRemoved = false;

  @override
  void initState() {
    super.initState();
    
    // Set status bar transparan untuk full-screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Background fade in lebih cepat untuk smooth transition
    _backgroundFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Preload background image untuk smooth transition
    _preloadBackgroundImage();

    // Navigate setelah durasi splash
    Future.delayed(widget.splashDuration, () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  /// Preload background image sebelum start animasi
  Future<void> _preloadBackgroundImage() async {
    final backgroundUrl = AppInfo.splashBackground;
    
    if (backgroundUrl.isEmpty) {
      // Tidak ada background URL, langsung mulai animasi
      _onBackgroundReady();
      return;
    }

    try {
      // Preload image menggunakan CachedNetworkImageProvider
      final imageProvider = CachedNetworkImageProvider(backgroundUrl);
      
      // Precache image
      if (mounted) {
        await precacheImage(imageProvider, context).timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            // Timeout, lanjutkan tanpa menunggu
            debugPrint('Background image preload timeout, continuing...');
          },
        );
      }
    } catch (e) {
      debugPrint('Background image preload error: $e');
    }
    
    _onBackgroundReady();
  }

  /// Called when background is ready (loaded or timeout/error)
  void _onBackgroundReady() {
    if (!mounted) return;
    
    // Start animation setelah background ready
    _animationController.forward();
    
    // Remove native splash dengan sedikit delay agar transisi smooth
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !_nativeSplashRemoved) {
        _nativeSplashRemoved = true;
        // Native splash akan otomatis hilang saat kita tidak lagi preserve-nya
        // Tidak perlu import flutter_native_splash jika tidak menggunakan preserve
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Reset system UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
              colorScheme.secondaryContainer,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background image dengan fade animation untuk smooth transition
            // dari native splash (solid color) ke gambar background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _backgroundFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _backgroundFadeAnimation.value,
                    child: child,
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: AppInfo.splashBackground,
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.3),
                  colorBlendMode: BlendMode.darken,
                  // Placeholder transparan karena kita sudah punya gradient background
                  placeholder: (context, url) => const SizedBox.shrink(),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          Assets.logo,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.apps_rounded,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Name
                    Text(
                      AppInfo.name,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      AppInfo.tagline,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 48,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Version at bottom
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: Text(
                'v${AppInfo.version} build ${AppInfo.buildNumber}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
