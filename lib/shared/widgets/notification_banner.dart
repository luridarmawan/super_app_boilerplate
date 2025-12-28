import 'dart:async';
import 'package:flutter/material.dart';

/// In-app notification banner that slides down from the top
class NotificationBanner extends StatefulWidget {
  final String title;
  final String? body;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationBanner({
    super.key,
    required this.title,
    this.body,
    this.icon = Icons.notifications,
    this.backgroundColor,
    this.textColor,
    this.duration = const Duration(seconds: 4),
    this.onTap,
    this.onDismiss,
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();

  /// Show notification banner as an overlay
  static void show(
    BuildContext context, {
    required String title,
    String? body,
    IconData icon = Icons.notifications,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _NotificationBannerOverlay(
        title: title,
        body: body,
        icon: icon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        duration: duration,
        onTap: () {
          entry.remove();
          onTap?.call();
        },
        onDismiss: () {
          entry.remove();
          onDismiss?.call();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _NotificationBannerState extends State<NotificationBanner> {
  @override
  Widget build(BuildContext context) {
    return _buildBanner(context);
  }

  Widget _buildBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = widget.backgroundColor ?? colorScheme.primaryContainer;
    final fgColor = widget.textColor ?? colorScheme.onPrimaryContainer;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: fgColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: fgColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: fgColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.body != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.body!,
                          style: TextStyle(
                            color: fgColor.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: fgColor, size: 18),
                  onPressed: widget.onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay widget with animation
class _NotificationBannerOverlay extends StatefulWidget {
  final String title;
  final String? body;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Duration duration;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationBannerOverlay({
    required this.title,
    this.body,
    required this.icon,
    this.backgroundColor,
    this.textColor,
    required this.duration,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationBannerOverlay> createState() => _NotificationBannerOverlayState();
}

class _NotificationBannerOverlayState extends State<_NotificationBannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                _dismiss();
              }
            },
            child: NotificationBanner(
              title: widget.title,
              body: widget.body,
              icon: widget.icon,
              backgroundColor: widget.backgroundColor,
              textColor: widget.textColor,
              onTap: widget.onTap,
              onDismiss: _dismiss,
            ),
          ),
        ),
      ),
    );
  }
}
