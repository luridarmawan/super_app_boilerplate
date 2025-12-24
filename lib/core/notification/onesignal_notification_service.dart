import 'dart:async';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_info.dart';
import 'notification_interface.dart';

/// OneSignal implementation of BaseNotificationService
class OneSignalNotificationService implements BaseNotificationService {
  FlutterLocalNotificationsPlugin? _localNotifications;

  final _foregroundMessageController =
      StreamController<NotificationMessage>.broadcast();
  final _notificationTapController =
      StreamController<NotificationMessage>.broadcast();
  final _tokenRefreshController = StreamController<String>.broadcast();

  bool _isInitialized = false;

  // Android notification channel
  static const String _defaultChannelId = 'high_importance_channel';
  static const String _defaultChannelName = 'High Importance Notifications';
  static const String _defaultChannelDescription =
      'This channel is used for important notifications.';

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize OneSignal with App ID from AppInfo
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(AppInfo.oneSignalAppId);

      // Set up notification handlers
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        _handleForegroundNotification(event);
      });

      OneSignal.Notifications.addClickListener((event) {
        _handleNotificationClick(event);
      });

      // Listen to subscription changes for token
      OneSignal.User.pushSubscription.addObserver((state) {
        final token = state.current.id;
        if (token != null) {
          _tokenRefreshController.add(token);
        }
      });

      // Initialize local notifications for custom display
      _localNotifications = FlutterLocalNotificationsPlugin();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );

      // Create notification channel
      await _createNotificationChannel();

      _isInitialized = true;
    } catch (e) {
      // print('OneSignal initialization error: $e');
      rethrow;
    }
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _defaultChannelId,
      _defaultChannelName,
      description: _defaultChannelDescription,
      importance: Importance.high,
    );

    await _localNotifications
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _handleForegroundNotification(
      OSNotificationWillDisplayEvent event) {
    final notification = _convertOSNotification(event.notification);
    _foregroundMessageController.add(notification);

    // Let OneSignal display the notification by default
    event.notification.display();
  }

  void _handleNotificationClick(OSNotificationClickEvent event) {
    final notification = _convertOSNotification(event.notification);
    _notificationTapController.add(notification);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    _notificationTapController.add(NotificationMessage(
      id: response.id?.toString(),
      data: {'payload': response.payload},
      receivedAt: DateTime.now(),
    ));
  }

  NotificationMessage _convertOSNotification(OSNotification notification) {
    return NotificationMessage(
      id: notification.notificationId,
      title: notification.title,
      body: notification.body,
      data: notification.additionalData,
      receivedAt: DateTime.now(),
    );
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    final granted = await OneSignal.Notifications.requestPermission(true);
    return granted
        ? NotificationPermissionStatus.authorized
        : NotificationPermissionStatus.denied;
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    final hasPermission = OneSignal.Notifications.permission;
    return hasPermission
        ? NotificationPermissionStatus.authorized
        : NotificationPermissionStatus.denied;
  }

  @override
  Future<String?> getToken() async {
    return OneSignal.User.pushSubscription.id;
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    // OneSignal uses tags for topic-like functionality
    await OneSignal.User.addTagWithKey(topic, 'true');
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await OneSignal.User.removeTag(topic);
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
    // OneSignal handles initial message through click listener
    // Return null as OneSignal manages this automatically
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
    final androidDetails = AndroidNotificationDetails(
      channelId ?? _defaultChannelId,
      channelName ?? _defaultChannelName,
      channelDescription: _defaultChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications?.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: data?.toString(),
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _localNotifications?.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _localNotifications?.cancelAll();
  }

  @override
  Future<void> dispose() async {
    await _foregroundMessageController.close();
    await _notificationTapController.close();
    await _tokenRefreshController.close();
  }
}
