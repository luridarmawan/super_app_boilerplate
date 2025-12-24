import 'dart:async';
import 'notification_interface.dart';

/// Mock implementation of BaseNotificationService for testing
class MockNotificationService implements BaseNotificationService {
  final _foregroundMessageController =
      StreamController<NotificationMessage>.broadcast();
  final _notificationTapController =
      StreamController<NotificationMessage>.broadcast();
  final _tokenRefreshController = StreamController<String>.broadcast();

  bool _isInitialized = false;
  NotificationPermissionStatus _permissionStatus =
      NotificationPermissionStatus.notDetermined;
  String _mockToken = 'mock_device_token_${DateTime.now().millisecondsSinceEpoch}';

  final Set<String> _subscribedTopics = {};
  final List<NotificationMessage> _notifications = [];

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 100));
    _isInitialized = true;
    print('MockNotificationService initialized');
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    // Simulate permission request
    await Future.delayed(const Duration(milliseconds: 50));
    _permissionStatus = NotificationPermissionStatus.authorized;
    return _permissionStatus;
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    return _permissionStatus;
  }

  @override
  Future<String?> getToken() async {
    return _mockToken;
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    _subscribedTopics.add(topic);
    print('MockNotificationService: Subscribed to topic "$topic"');
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    _subscribedTopics.remove(topic);
    print('MockNotificationService: Unsubscribed from topic "$topic"');
  }

  @override
  Stream<NotificationMessage> get onForegroundMessage =>
      _foregroundMessageController.stream;

  @override
  Stream<NotificationMessage> get onNotificationTap =>
      _notificationTapController.stream;

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Future<NotificationMessage?> getInitialMessage() async {
    return null;
  }

  @override
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? channelId,
    String? channelName,
  }) async {
    final notification = NotificationMessage(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      data: data,
      receivedAt: DateTime.now(),
    );
    _notifications.add(notification);
    print('MockNotificationService: Local notification shown - $title');
  }

  @override
  Future<void> cancelNotification(int id) async {
    print('MockNotificationService: Cancelled notification $id');
  }

  @override
  Future<void> cancelAllNotifications() async {
    _notifications.clear();
    print('MockNotificationService: All notifications cancelled');
  }

  @override
  Future<void> dispose() async {
    await _foregroundMessageController.close();
    await _notificationTapController.close();
    await _tokenRefreshController.close();
  }

  // ============================================
  // TESTING HELPERS
  // ============================================

  /// Simulate receiving a foreground notification (for testing)
  void simulateForegroundNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    final notification = NotificationMessage(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      data: data,
      receivedAt: DateTime.now(),
    );
    _foregroundMessageController.add(notification);
    _notifications.add(notification);
  }

  /// Simulate a notification tap (for testing)
  void simulateNotificationTap(NotificationMessage notification) {
    _notificationTapController.add(notification);
  }

  /// Simulate token refresh (for testing)
  void simulateTokenRefresh(String newToken) {
    _mockToken = newToken;
    _tokenRefreshController.add(newToken);
  }

  /// Set permission status for testing
  void setPermissionStatus(NotificationPermissionStatus status) {
    _permissionStatus = status;
  }

  /// Get list of subscribed topics (for testing)
  Set<String> get subscribedTopics => Set.unmodifiable(_subscribedTopics);

  /// Get list of shown notifications (for testing)
  List<NotificationMessage> get shownNotifications =>
      List.unmodifiable(_notifications);

  /// Check if initialized (for testing)
  bool get isInitialized => _isInitialized;
}
