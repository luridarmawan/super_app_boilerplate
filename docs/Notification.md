# Push Notification

> **📚 Related Documents:**
> - **[README.md](../README.md)** - Main project documentation
> - **[Modular.md](./Modular.md)** - Modular architecture

## Overview

Super App implements **Multi-Provider Push Notification** with an abstraction layer, allowing notification provider switching without changing UI code.

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

| Benefit | Description |
|---------|-------------|
| **Clean Separation** | No `if (isFcm)` logic in UI layer |
| **Easy Switching** | Change provider by modifying 1 line of const |
| **A/B Testing Ready** | Can be controlled via remote config |
| **Testable** | `MockNotificationService` for unit testing |
| **Clean Architecture** | Consistent with app architecture |

---

## ⚡ Easy Provider Selection

### All Configuration in One Place

No need to modify multiple files! All notification configuration is in **one file**:

📁 **`lib/core/constants/app_info.dart`**

```dart
class AppInfo {
  // ... other configs ...

  // ============================================
  // NOTIFICATION CONFIGURATION
  // ============================================
  
  /// Enable/disable entire notification feature
  static const bool enableNotification = true;
  
  /// Choose provider: 'firebase', 'onesignal', 'mock'
  static const String notificationProvider = 'firebase';
}
```

### How to Change Provider

Just **change 1 line** in `app_info.dart`:

```dart
// For Firebase Cloud Messaging (default)
static const String notificationProvider = 'firebase';

// For OneSignal
static const String notificationProvider = 'onesignal';

// For Testing/Development
static const String notificationProvider = 'mock';
```

### Available Providers

| Value | Provider | Description | When to Use |
|-------|----------|-------------|-------------|
| `firebase` / `fcm` | Firebase Cloud Messaging | Push notification from Google | Production (default) |
| `onesignal` | OneSignal | Alternative push notification | If you need OneSignal features |
| `mock` / `test` | Mock Service | No server connection | Testing & Development |

### Provider Comparison

| Feature | Firebase (FCM) | OneSignal |
|---------|----------------|-----------|
| **Free** | ✅ Unlimited | ✅ Up to 10k subscribers |
| **Setup Complexity** | Medium | Easy |
| **Analytics** | Via Firebase Console | Built-in dashboard |
| **Segmentation** | Manual via topics | Automatic |
| **A/B Testing** | Via Remote Config | Built-in |
| **Rich Notifications** | ✅ | ✅ |
| **iOS Support** | ✅ | ✅ |
| **Android Support** | ✅ | ✅ |

### Anti-Patterns Avoided

| ❌ Anti-Pattern | ✅ Applied Solution |
|-----------------|---------------------|
| `if (provider == 'fcm')` in every screen | Abstraction layer with interface |
| Configuration scattered across many files | All config in `app_info.dart` |
| Hard to test because it needs connection | `MockNotificationService` for testing |
| Need major refactor to change provider | Change 1 line, done! |
---

## Detailed Configuration

### 1. Enable/Disable Notification

```dart
// Set to false to disable entire notification feature
// UI still runs normally, only notification is off
static const bool enableNotification = true;
```

**What happens if `false`:**
- No Firebase/OneSignal initialization
- No permission request
- `MockNotificationService` used internally
- No error in UI

### 2. Choose Provider

```dart
// Options: 'firebase', 'onesignal', 'mock'
static const String notificationProvider = 'firebase';
```

---

## File Structure

```
lib/core/notification/
├── notification.dart            # Barrel export
├── notification_interface.dart  # Abstract interface
├── notification_provider.dart   # Riverpod providers & state
├── notification_widgets.dart    # Reusable widgets
├── fcm_notification_service.dart       # FCM implementation
├── onesignal_notification_service.dart # OneSignal implementation
├── mock_notification_service.dart      # Mock for testing
└── README.md                    # Detailed documentation
```

---

## 📖 Quick Example

### Initialization (Already Automatic)

Notification is **automatically initialized** in `MainDashboard`. For manual initialization:

```dart
// 1. Initialize & request permission
await ref.read(notificationProvider.notifier).initialize();
await ref.read(notificationProvider.notifier).requestPermission();
```

### Show Local Notification

```dart
// 2. Show local notification
await ref.read(notificationProvider.notifier).showLocalNotification(
  title: 'Hello!',
  body: 'This is a notification',
  data: {'route': '/details', 'id': '123'},
);
```

### Subscribe to Topic

```dart
// 3. Subscribe to topic
await ref.read(notificationProvider.notifier).subscribeToTopic('news');
await ref.read(notificationProvider.notifier).subscribeToTopic('promotions');

// Unsubscribe
await ref.read(notificationProvider.notifier).unsubscribeFromTopic('news');
```

### Listen to Notification Tap

```dart
// 4. Listen to notification tap
ref.listen(notificationTapProvider, (prev, next) {
  next.whenData((message) {
    // Navigate based on message.data
    if (message.data?['route'] != null) {
      context.go(message.data!['route']);
    }
  });
});
```

### Listen to Foreground Message

```dart
// 5. Listen to foreground messages
ref.listen(foregroundMessageProvider, (prev, next) {
  next.whenData((message) {
    // Show in-app notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.title ?? 'New notification')),
    );
  });
});
```

### Get Device Token

// 6. Get device token (to send to backend)
final state = ref.read(notificationProvider);

if (state.hasPermission && state.deviceToken != null) {
  print('Token: ${state.deviceToken}');
  // Send to your backend
  await api.registerDeviceToken(state.deviceToken!);
}
```

---

## Setup Firebase Cloud Messaging (FCM)

### 1. Create Firebase Project

1. Open [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project" or "Create Project"
3. Enter project name and follow the wizard

### 2. Add App to Firebase

#### Android
1. Click Android icon in Firebase Console
2. Enter package name: `id.carik.superapp_demo` (adjust for your app)
3. Download `google-services.json`
4. Place in: `android/app/google-services.json`

#### iOS
1. Click Apple icon in Firebase Console
2. Enter Bundle ID
3. Download `GoogleService-Info.plist`
4. Place in: `ios/Runner/GoogleService-Info.plist`

### 3. Android Configuration

File: `android/build.gradle`
```gradle
buildscript {
    dependencies {
        // Add this
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

File: `android/app/build.gradle`
```gradle
// At the very bottom of the file
apply plugin: 'com.google.gms.google-services'
```

### 4. iOS Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target > Signing & Capabilities
3. Click "+ Capability" and add "Push Notifications"
4. Also add "Background Modes" and enable "Remote notifications"

---

## Setup OneSignal

### 1. Create OneSignal Account

1. Open [OneSignal Dashboard](https://onesignal.com)
2. Create new app
3. Select platform (Android/iOS/Web)
4. Follow setup wizard

### 2. Update App ID

File: `lib/core/constants/app_info.dart`

```dart
// Replace with App ID from OneSignal Dashboard
static const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';
```

### 3. Set Provider to OneSignal

File: `lib/core/constants/app_info.dart`

```dart
static const String notificationProvider = 'onesignal';
```

---

## Usage

### Initialization

Notification is automatically initialized in `MainDashboard`. For manual initialization:

```dart
// Initialize
await ref.read(notificationProvider.notifier).initialize();

// Request permission
await ref.read(notificationProvider.notifier).requestPermission();
```

### Listen Notification Tap

```dart
ref.listen(notificationTapProvider, (previous, next) {
  next.whenData((message) {
    print('User tapped: ${message.title}');
    // Navigate to specific screen based on message.data
  });
});
```

### Listen Foreground Message

```dart
ref.listen(foregroundMessageProvider, (previous, next) {
  next.whenData((message) {
    print('Received: ${message.title}');
    // Show in-app notification or update UI
  });
});
```

### Show Local Notification

```dart
await ref.read(notificationProvider.notifier).showLocalNotification(
  title: 'Hello!',
  body: 'This is a local notification',
  data: {'route': '/details', 'id': '123'},
);
```

### Subscribe to Topic

```dart
// Subscribe
await ref.read(notificationProvider.notifier).subscribeToTopic('news');
await ref.read(notificationProvider.notifier).subscribeToTopic('promotions');

// Unsubscribe
await ref.read(notificationProvider.notifier).unsubscribeFromTopic('news');
```

### Get Device Token

```dart
final state = ref.read(notificationProvider);

if (state.hasPermission) {
  print('Token: ${state.deviceToken}');
  // Send token to your backend
}
```

---

## NotificationWrapper Widget

For easier integration, use `NotificationWrapper`:

```dart
NotificationWrapper(
  requestPermissionOnInit: true,
  onNotificationTap: (message) {
    // Handle tap - navigate to screen
    if (message.data?['route'] != null) {
      context.go(message.data!['route']);
    }
  },
  onForegroundMessage: (message) {
    // Handle foreground message - show toast/snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.title ?? 'New notification')),
    );
  },
  child: MainDashboard(),
)
```

---

## State Properties

```dart
class NotificationState {
  final bool isInitialized;           // Service has been initialized
  final bool hasPermission;           // User has granted permission
  final String? deviceToken;          // Push token for this device
  final NotificationMessage? lastMessage;  // Last received message
  final bool isLoading;               // Async operation in progress
  final String? error;                // Error message if any
}
```

---

## Testing with MockNotificationService

```dart
// In app_info.dart, set provider to mock
static const String notificationProvider = 'mock';

// In test
void main() {
  test('should handle notification tap', () async {
    final mockService = container.read(notificationServiceProvider) 
        as MockNotificationService;
    
    // Simulate notification
    mockService.simulateForegroundNotification(
      title: 'Test Title',
      body: 'Test Body',
      data: {'route': '/test'},
    );
    
    // Verify
    expect(mockService.shownNotifications.length, 1);
    expect(mockService.shownNotifications.first.title, 'Test Title');
  });
}
```

---

## Troubleshooting

### FCM Token Null

1. Make sure `google-services.json` exists in `android/app/`
2. Run `flutter clean` and `flutter pub get`
3. Make sure Firebase is initialized in `main.dart`

### Notification Not Appearing on Android

1. Make sure channel is created with importance HIGH
2. Check if app has permission in Settings
3. For Android 13+, make sure `POST_NOTIFICATIONS` permission is requested

### iOS Background Notification Not Working

1. Make sure "Background Modes > Remote notifications" is enabled in Xcode
2. Upload APNs Authentication Key to Firebase Console
3. Make sure `content-available: 1` is in payload

---

## See Also

- **[README.md](../README.md)** - Main project documentation
- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [OneSignal Flutter SDK](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)

---

📚 **Full technical documentation:** [`lib/core/notification/README.md`](../lib/core/notification/README.md)

---

*Updated: January 1, 2026*
*Version: 1.0.1*
