/// Push Notification Module
/// 
/// This module provides a multi-provider abstraction for push notifications.
/// 
/// ## Architecture
/// ```
/// UI
///  └── NotificationProvider (Riverpod)
///       └── BaseNotificationService  ← interface
///            ├── FcmNotificationService      (Firebase Cloud Messaging)
///            ├── OneSignalNotificationService (OneSignal)
///            └── MockNotificationService      (For testing)
/// ```
/// 
/// ## Usage
/// 
/// 1. Enable/disable notifications in `app_info.dart`:
///    ```dart
///    static const bool enableNotification = true;
///    ```
/// 
/// 2. Choose provider in `app_info.dart`:
///    ```dart
///    static const String notificationProvider = 'firebase'; // 'firebase', 'onesignal', 'mock'
///    ```
/// 
/// 3. Initialize in your app:
///    ```dart
///    ref.read(notificationProvider.notifier).initialize();
///    ```
/// 
/// 4. Request permission:
///    ```dart
///    await ref.read(notificationProvider.notifier).requestPermission();
///    ```
/// 
/// 5. Listen to notifications:
///    ```dart
///    ref.listen(notificationTapProvider, (previous, next) {
///      next.whenData((message) {
///        // Handle notification tap
///      });
///    });
///    ```
library;

// Core interface
export 'notification_interface.dart';

// Implementations
export 'fcm_notification_service.dart';
export 'onesignal_notification_service.dart';
export 'mock_notification_service.dart';

// Provider & State
export 'notification_provider.dart';

// Widgets
export 'notification_widgets.dart';

// Testing Tools
export 'notification_test_panel.dart';
