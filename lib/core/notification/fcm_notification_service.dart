import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_interface.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message here if needed
  print('Handling background message: ${message.messageId}');
}

/// Firebase Cloud Messaging implementation of BaseNotificationService
class FcmNotificationService implements BaseNotificationService {
  FirebaseMessaging? _messaging;
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
      // Initialize Firebase
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Initialize local notifications
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
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create Android notification channel
      await _createNotificationChannel();

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Listen to notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Listen to token refresh
      _messaging!.onTokenRefresh.listen((token) {
        _tokenRefreshController.add(token);
      });

      _isInitialized = true;
    } catch (e) {
      print('FCM initialization error: $e');
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

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = _convertRemoteMessage(message);
    _foregroundMessageController.add(notification);

    // Show local notification when app is in foreground
    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        data: message.data,
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final notification = _convertRemoteMessage(message);
    _notificationTapController.add(notification);
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle local notification tap
    _notificationTapController.add(NotificationMessage(
      id: response.id?.toString(),
      data: {'payload': response.payload},
      receivedAt: DateTime.now(),
    ));
  }

  NotificationMessage _convertRemoteMessage(RemoteMessage message) {
    return NotificationMessage(
      id: message.messageId,
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      receivedAt: message.sentTime ?? DateTime.now(),
    );
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    final settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return _convertAuthorizationStatus(settings.authorizationStatus);
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    final settings = await _messaging!.getNotificationSettings();
    return _convertAuthorizationStatus(settings.authorizationStatus);
  }

  NotificationPermissionStatus _convertAuthorizationStatus(
      AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return NotificationPermissionStatus.authorized;
      case AuthorizationStatus.denied:
        return NotificationPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return NotificationPermissionStatus.notDetermined;
      case AuthorizationStatus.provisional:
        return NotificationPermissionStatus.provisional;
    }
  }

  @override
  Future<String?> getToken() async {
    return await _messaging?.getToken();
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    await _messaging?.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging?.unsubscribeFromTopic(topic);
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
    final message = await _messaging?.getInitialMessage();
    if (message != null) {
      return _convertRemoteMessage(message);
    }
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
