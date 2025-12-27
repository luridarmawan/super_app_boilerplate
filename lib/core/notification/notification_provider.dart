import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_info.dart';
import 'notification_interface.dart';
// import 'fcm_notification_service.dart';  // Disabled to reduce APK size
// import 'onesignal_notification_service.dart';  // Disabled to reduce APK size
import 'mock_notification_service.dart';

/// Enum untuk push notification provider
enum PushProvider {
  firebase,
  onesignal,
  mock,
}

/// Helper function to get PushProvider from AppInfo.notificationProvider string
PushProvider get currentPushProvider {
  switch (AppInfo.notificationProvider.toLowerCase()) {
    case 'firebase':
    case 'fcm':
      return PushProvider.firebase;
    case 'onesignal':
      return PushProvider.onesignal;
    case 'mock':
    case 'test':
      return PushProvider.mock;
    default:
      return PushProvider.mock; // Default to mock (Firebase disabled to reduce APK size)
  }
}

/// Provider untuk notification service
/// Returns the appropriate notification service based on AppInfo.notificationProvider
final notificationServiceProvider = Provider<BaseNotificationService>((ref) {
  // Check if notifications are enabled
  if (!AppInfo.enableNotification) {
    // Return mock service when notifications are disabled
    return MockNotificationService();
  }

  switch (currentPushProvider) {
    case PushProvider.firebase:
      return MockNotificationService(); // FcmNotificationService disabled to reduce APK size
    case PushProvider.onesignal:
      return MockNotificationService(); // OneSignalNotificationService disabled to reduce APK size
    case PushProvider.mock:
      return MockNotificationService();
  }
});

/// State untuk notification
class NotificationState {
  final bool isInitialized;
  final bool hasPermission;
  final String? deviceToken;
  final NotificationMessage? lastMessage;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationState({
    this.isInitialized = false,
    this.hasPermission = false,
    this.deviceToken,
    this.lastMessage,
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    bool? isInitialized,
    bool? hasPermission,
    String? deviceToken,
    NotificationMessage? lastMessage,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      deviceToken: deviceToken ?? this.deviceToken,
      lastMessage: lastMessage ?? this.lastMessage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Notifier untuk mengelola notification state
class NotificationNotifier extends StateNotifier<NotificationState> {
  final BaseNotificationService _service;

  NotificationNotifier(this._service) : super(const NotificationState());

  /// Initialize notification service
  Future<void> initialize() async {
    if (!AppInfo.enableNotification) {
      state = state.copyWith(
        isInitialized: false,
        error: 'Notifications are disabled',
      );
      return;
    }

    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _service.initialize();

      // Check current permission status
      final permissionStatus = await _service.getPermissionStatus();
      final hasPermission =
          permissionStatus == NotificationPermissionStatus.authorized ||
              permissionStatus == NotificationPermissionStatus.provisional;

      // Get token if we have permission
      String? token;
      if (hasPermission) {
        token = await _service.getToken();
      }

      state = state.copyWith(
        isInitialized: true,
        hasPermission: hasPermission,
        deviceToken: token,
        isLoading: false,
      );

      // Listen to foreground messages
      _service.onForegroundMessage.listen((message) {
        state = state.copyWith(lastMessage: message);
      });

      // Listen to token refresh
      _service.onTokenRefresh.listen((token) {
        state = state.copyWith(deviceToken: token);
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    if (!AppInfo.enableNotification) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final status = await _service.requestPermission();
      final hasPermission =
          status == NotificationPermissionStatus.authorized ||
              status == NotificationPermissionStatus.provisional;

      String? token;
      if (hasPermission) {
        token = await _service.getToken();
      }

      state = state.copyWith(
        hasPermission: hasPermission,
        deviceToken: token,
        isLoading: false,
      );

      return hasPermission;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    if (!AppInfo.enableNotification) return;

    try {
      await _service.subscribeToTopic(topic);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!AppInfo.enableNotification) return;

    try {
      await _service.unsubscribeFromTopic(topic);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Show a local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!AppInfo.enableNotification) return;

    try {
      await _service.showLocalNotification(
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get initial message (if app was opened from notification)
  Future<NotificationMessage?> getInitialMessage() async {
    if (!AppInfo.enableNotification) return null;

    return await _service.getInitialMessage();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Increment unread notification count
  void incrementUnreadCount() {
    state = state.copyWith(unreadCount: state.unreadCount + 1);
  }

  /// Clear unread notification count (when user views notifications)
  void clearUnreadCount() {
    state = state.copyWith(unreadCount: 0);
  }

  /// Set unread count to specific value
  void setUnreadCount(int count) {
    state = state.copyWith(unreadCount: count);
  }

  /// Handle received message - update lastMessage and increment count
  void onMessageReceived(NotificationMessage message) {
    state = state.copyWith(
      lastMessage: message,
      unreadCount: state.unreadCount + 1,
    );
  }
}

/// Provider untuk notification notifier
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationNotifier(service);
});

/// Provider untuk check apakah notification enabled
final isNotificationEnabledProvider = Provider<bool>((ref) {
  return AppInfo.enableNotification;
});

/// Stream provider untuk notification taps
final notificationTapProvider = StreamProvider<NotificationMessage>((ref) {
  if (!AppInfo.enableNotification) {
    return const Stream.empty();
  }
  final service = ref.watch(notificationServiceProvider);
  return service.onNotificationTap;
});

/// Stream provider untuk foreground messages
final foregroundMessageProvider = StreamProvider<NotificationMessage>((ref) {
  if (!AppInfo.enableNotification) {
    return const Stream.empty();
  }
  final service = ref.watch(notificationServiceProvider);
  return service.onForegroundMessage;
});

/// Provider untuk unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});
