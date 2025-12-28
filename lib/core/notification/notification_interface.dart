/// Push Notification Abstraction Layer
/// 
/// This file defines the interface for push notification services
library;

/// Represents a push notification message
class NotificationMessage {
  final String? id;
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final DateTime? receivedAt;

  const NotificationMessage({
    this.id,
    this.title,
    this.body,
    this.data,
    this.receivedAt,
  });

  @override
  String toString() =>
      'NotificationMessage(id: $id, title: $title, body: $body, data: $data)';
}

/// Notification permission status
enum NotificationPermissionStatus {
  authorized,
  denied,
  notDetermined,
  provisional,
}

/// Base interface for all push notification services
abstract class BaseNotificationService {
  /// Initialize the notification service
  Future<void> initialize();

  /// Request permission to send notifications
  Future<NotificationPermissionStatus> requestPermission();

  /// Get the current permission status
  Future<NotificationPermissionStatus> getPermissionStatus();

  /// Get the device token for push notifications
  Future<String?> getToken();

  /// Subscribe to a topic (for topic-based messaging)
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Stream of foreground notifications
  Stream<NotificationMessage> get onForegroundMessage;

  /// Stream of notification taps (when user taps on notification)
  Stream<NotificationMessage> get onNotificationTap;

  /// Stream of token refresh events
  Stream<String> get onTokenRefresh;

  /// Handle a notification when app is opened from notification
  Future<NotificationMessage?> getInitialMessage();

  /// Show a local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? channelId,
    String? channelName,
  });

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id);

  /// Cancel all notifications
  Future<void> cancelAllNotifications();

  /// Dispose resources
  Future<void> dispose();
}
