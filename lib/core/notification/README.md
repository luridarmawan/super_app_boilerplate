# Push Notification Module

## Overview

This module provides a **multi-provider abstraction layer** for push notifications in Flutter, following Clean Architecture principles.

## Architecture

```
UI Layer
 └── NotificationProvider (Riverpod)
      └── BaseNotificationService  ← Abstract Interface
           ├── FcmNotificationService       (Firebase Cloud Messaging)
           ├── OneSignalNotificationService (OneSignal)
           └── MockNotificationService      (For Testing)
```

## Benefits

- ✅ **No `if (isFcm)` logic in UI** - Clean separation of concerns
- ✅ **Easy provider switching** - Change 1 line of const to switch providers
- ✅ **A/B Testing ready** - Can be controlled via remote config
- ✅ **Testable** - Use MockNotificationService for unit tests
- ✅ **Clean Architecture** - Consistent with the rest of the codebase

## Configuration

### 1. Enable/Disable Notifications

In `lib/core/constants/app_info.dart`:

```dart
static const bool enableNotification = true; // Set to false to disable
```

### 2. Choose Push Provider

In `lib/core/notification/notification_provider.dart`:

```dart
/// Available providers
enum PushProvider {
  fcm,        // Firebase Cloud Messaging
  oneSignal,  // OneSignal
  mock,       // For testing
}

/// Change this to switch providers
const PushProvider pushProvider = PushProvider.fcm;
```

## Usage

### Initialize Notifications

In your main screen or app entry point:

```dart
@override
void initState() {
  super.initState();
  _initializeNotifications();
}

Future<void> _initializeNotifications() async {
  if (!AppInfo.enableNotification) return;
  
  await ref.read(notificationProvider.notifier).initialize();
  await ref.read(notificationProvider.notifier).requestPermission();
}
```

### Listen to Notification Taps

```dart
ref.listen(notificationTapProvider, (previous, next) {
  next.whenData((message) {
    // Handle notification tap - navigate to specific screen
    print('User tapped notification: ${message.title}');
  });
});
```

### Listen to Foreground Messages

```dart
ref.listen(foregroundMessageProvider, (previous, next) {
  next.whenData((message) {
    // Handle foreground message - show in-app alert
    print('Received message: ${message.title}');
  });
});
```

### Show Local Notification

```dart
await ref.read(notificationProvider.notifier).showLocalNotification(
  title: 'Hello',
  body: 'This is a local notification',
  data: {'route': '/details', 'id': '123'},
);
```

### Subscribe to Topics

```dart
await ref.read(notificationProvider.notifier).subscribeToTopic('news');
await ref.read(notificationProvider.notifier).unsubscribeFromTopic('news');
```

### Get Device Token

```dart
final state = ref.read(notificationProvider);
print('Device Token: ${state.deviceToken}');
```

## Using NotificationWrapper Widget

For simpler integration, wrap your main screen:

```dart
NotificationWrapper(
  requestPermissionOnInit: true,
  onNotificationTap: (message) {
    // Handle tap
  },
  onForegroundMessage: (message) {
    // Handle foreground message
  },
  child: MainDashboard(),
)
```

## Firebase Setup (for FCM)

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add your Android/iOS app to the project
3. Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
4. Place the files in:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### Android Configuration

In `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

In `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

## OneSignal Setup

1. Create a OneSignal account at [OneSignal](https://onesignal.com)
2. Get your App ID from the OneSignal dashboard
3. Update `lib/core/notification/onesignal_notification_service.dart`:

```dart
static const String _oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';
```

## Testing with MockNotificationService

```dart
// In your test setup
const PushProvider pushProvider = PushProvider.mock;

// In your test
final mockService = ref.read(notificationServiceProvider) as MockNotificationService;

// Simulate receiving a notification
mockService.simulateForegroundNotification(
  title: 'Test Notification',
  body: 'This is a test',
);

// Verify notification was handled
expect(mockService.shownNotifications.length, 1);
```

## Files

| File | Description |
|------|-------------|
| `notification_interface.dart` | Abstract interface definition |
| `fcm_notification_service.dart` | Firebase Cloud Messaging implementation |
| `onesignal_notification_service.dart` | OneSignal implementation |
| `mock_notification_service.dart` | Mock for testing |
| `notification_provider.dart` | Riverpod providers and state management |
| `notification_widgets.dart` | Reusable UI widgets |
| `notification.dart` | Barrel file (exports all) |

## State Properties

```dart
class NotificationState {
  final bool isInitialized;      // Service initialized
  final bool hasPermission;      // User granted permission
  final String? deviceToken;     // Push token for this device
  final NotificationMessage? lastMessage;  // Last received message
  final bool isLoading;          // Async operation in progress
  final String? error;           // Error message if any
}
```
