import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_info.dart';
import 'notification_provider.dart';
import 'notification_interface.dart';

/// Widget wrapper untuk menginisialisasi notification service
/// Letakkan di root widget setelah MaterialApp untuk mengaktifkan notification
/// 
/// Usage:
/// ```dart
/// MaterialApp(
///   home: NotificationWrapper(
///     child: MainDashboard(),
///     onNotificationTap: (message) {
///       // Handle notification tap
///     },
///   ),
/// )
/// ```
class NotificationWrapper extends ConsumerStatefulWidget {
  final Widget child;
  
  /// Callback when user taps on notification
  final void Function(NotificationMessage message)? onNotificationTap;
  
  /// Callback when foreground message received
  final void Function(NotificationMessage message)? onForegroundMessage;
  
  /// Whether to request permission automatically on init
  final bool requestPermissionOnInit;

  const NotificationWrapper({
    super.key,
    required this.child,
    this.onNotificationTap,
    this.onForegroundMessage,
    this.requestPermissionOnInit = true,
  });

  @override
  ConsumerState<NotificationWrapper> createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends ConsumerState<NotificationWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    if (!AppInfo.enableNotification) return;

    // Initialize notification service
    await ref.read(notificationProvider.notifier).initialize();
    
    // Request permission if configured
    if (widget.requestPermissionOnInit) {
      await ref.read(notificationProvider.notifier).requestPermission();
    }
    
    // Check for initial message (app opened from notification)
    final initialMessage = await ref.read(notificationProvider.notifier).getInitialMessage();
    if (initialMessage != null && widget.onNotificationTap != null) {
      widget.onNotificationTap!(initialMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to notification taps
    ref.listen(notificationTapProvider, (previous, next) {
      next.whenData((message) {
        if (widget.onNotificationTap != null) {
          widget.onNotificationTap!(message);
        }
      });
    });

    // Listen to foreground messages
    ref.listen(foregroundMessageProvider, (previous, next) {
      next.whenData((message) {
        if (widget.onForegroundMessage != null) {
          widget.onForegroundMessage!(message);
        }
      });
    });

    return widget.child;
  }
}

/// Extension untuk memudahkan akses notification dari BuildContext
extension NotificationContextExtension on BuildContext {
  /// Check if notifications are enabled
  bool get isNotificationEnabled => AppInfo.enableNotification;
}

/// Widget untuk menampilkan badge notifikasi
class NotificationBadge extends ConsumerWidget {
  final Widget child;
  final int? count;
  
  const NotificationBadge({
    super.key,
    required this.child,
    this.count,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch notification state to trigger rebuilds
    ref.watch(notificationProvider);
    
    // Don't show badge if notifications are disabled
    if (!AppInfo.enableNotification) {
      return child;
    }

    final displayCount = count ?? 0;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (displayCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                displayCount > 99 ? '99+' : displayCount.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget untuk permission request dialog
class NotificationPermissionDialog extends ConsumerWidget {
  final String title;
  final String message;
  final String allowButtonText;
  final String denyButtonText;
  final VoidCallback? onAllow;
  final VoidCallback? onDeny;

  const NotificationPermissionDialog({
    super.key,
    this.title = 'Enable Notifications',
    this.message = 'Stay updated with the latest news and offers. Allow notifications?',
    this.allowButtonText = 'Allow',
    this.denyButtonText = 'Not Now',
    this.onAllow,
    this.onDeny,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDeny?.call();
          },
          child: Text(denyButtonText),
        ),
        FilledButton(
          onPressed: () async {
            final granted = await ref.read(notificationProvider.notifier).requestPermission();
            if (context.mounted) {
              Navigator.of(context).pop();
              if (granted) {
                onAllow?.call();
              } else {
                onDeny?.call();
              }
            }
          },
          child: Text(allowButtonText),
        ),
      ],
    );
  }

  /// Show the permission dialog
  static Future<void> show(
    BuildContext context, {
    String title = 'Enable Notifications',
    String message = 'Stay updated with the latest news and offers. Allow notifications?',
    VoidCallback? onAllow,
    VoidCallback? onDeny,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => NotificationPermissionDialog(
        title: title,
        message: message,
        onAllow: onAllow,
        onDeny: onDeny,
      ),
    );
  }
}
