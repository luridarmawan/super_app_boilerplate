// flutter test test/notification_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_app/core/notification/notification.dart';

void main() {
  group('MockNotificationService', () {
    late ProviderContainer container;
    late MockNotificationService mockService;

    setUp(() {
      container = ProviderContainer();
      mockService = container.read(notificationServiceProvider) as MockNotificationService;
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize successfully', () async {
      await mockService.initialize();
      expect(mockService.isInitialized, true);
    });

    test('should request permission', () async {
      await mockService.initialize();
      final status = await mockService.requestPermission();
      expect(status, NotificationPermissionStatus.authorized);
    });

    test('should show local notification', () async {
      await mockService.initialize();
      await mockService.showLocalNotification(
        title: 'Test',
        body: 'Test body',
      );
      expect(mockService.shownNotifications.length, 1);
      expect(mockService.shownNotifications.first.title, 'Test');
    });

    test('should subscribe to topic', () async {
      await mockService.initialize();
      await mockService.subscribeToTopic('news');
      expect(mockService.subscribedTopics.contains('news'), true);
    });

    test('should simulate foreground notification', () async {
      await mockService.initialize();
      
      final messages = <NotificationMessage>[];
      mockService.onForegroundMessage.listen((msg) => messages.add(msg));

      mockService.simulateForegroundNotification(
        title: 'Simulated',
        body: 'Simulated body',
      );

      await Future.delayed(Duration(milliseconds: 100));
      expect(messages.length, 1);
      expect(messages.first.title, 'Simulated');
    });
  });
}