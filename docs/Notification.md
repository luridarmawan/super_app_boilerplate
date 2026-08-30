# Push Notification

> ## ⚠️ STATUS SAAT INI: NONAKTIF
>
> Implementasi **FCM dan OneSignal seluruhnya di-*comment out*** untuk menekan ukuran APK:
> - `lib/core/notification/fcm_notification_service.dart` — isi file dikomentari
> - `lib/core/notification/onesignal_notification_service.dart` — isi file dikomentari
> - `firebase_messaging` & `onesignal_flutter` dinonaktifkan di `pubspec.yaml`
> - `notification_provider.dart` mengembalikan `MockNotificationService()` untuk **semua** nilai provider
>
> Konfigurasi produksi (`.env`): `ENABLE_NOTIFICATION=false`, `NOTIFICATION_PROVIDER="mock"`.
>
> **Untuk mengaktifkan kembali:** ikuti
> [`Notification-Firebase-Restore.md`](./Notification-Firebase-Restore.md) atau
> [`Notification-Onesignal-Restore.md`](./Notification-Onesignal-Restore.md).
>
> Dokumen ini menjelaskan arsitektur dan cara pakai sistem notifikasi setelah diaktifkan kembali.

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

No need to modify multiple files! All notification configuration lives in **`.env`**:

📁 **`.env`**

```env
# Enable/disable entire notification feature
ENABLE_NOTIFICATION=true

# Choose provider: 'firebase', 'onesignal', 'mock'
NOTIFICATION_PROVIDER="firebase"

# Optional: in-app notification banner
ENABLE_NOTIFICATION_BANNER=false

# Required only when NOTIFICATION_PROVIDER=onesignal
ONESIGNAL_APP_ID="YOUR_ONESIGNAL_APP_ID"
```

Nilai-nilai tersebut dibaca lewat getter di `lib/core/constants/app_info.dart` — **bukan** konstanta:

```dart
static bool get enableNotification =>
    dotenv.env['ENABLE_NOTIFICATION']?.toLowerCase() == 'true';

static String get notificationProvider =>
    dotenv.env['NOTIFICATION_PROVIDER'] ?? 'firebase';
```

### How to Change Provider

Just **change 1 line** in `.env` (tidak perlu menyentuh kode Dart):

```env
NOTIFICATION_PROVIDER="firebase"    # Firebase Cloud Messaging
NOTIFICATION_PROVIDER="onesignal"   # OneSignal
NOTIFICATION_PROVIDER="mock"        # Testing / Development
```

### Available Providers

| Value | Provider | Description | When to Use |
|-------|----------|-------------|-------------|
| `firebase` / `fcm` | Firebase Cloud Messaging | Push notification from Google | Production (default) — **perlu di-restore lebih dulu** |
| `onesignal` | OneSignal | Alternative push notification | If you need OneSignal features — **perlu di-restore lebih dulu** |
| `mock` / `test` | Mock Service | No server connection | Testing & Development — **nilai aktif saat ini** |

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
| Configuration scattered across many files | All config in `.env` |
| Hard to test because it needs connection | `MockNotificationService` for testing |
| Need major refactor to change provider | Change 1 line, done! |
---

## Detailed Configuration

### 1. Enable/Disable Notification

```env
# Set to false to disable entire notification feature
# UI still runs normally, only notification is off
ENABLE_NOTIFICATION=true
```

**What happens if `false`:**
- No Firebase/OneSignal initialization
- No permission request
- `MockNotificationService` used internally
- No error in UI

### 2. Choose Provider

```env
# Options: 'firebase', 'onesignal', 'mock'
NOTIFICATION_PROVIDER="firebase"
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
├── notification_test_panel.dart # Debug panel untuk uji notifikasi
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

```dart
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
2. Enter package name: `id.ihasa.app` (adjust for your app)
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

File: `.env`

```env
# Replace with App ID from OneSignal Dashboard
ONESIGNAL_APP_ID="YOUR_ONESIGNAL_APP_ID"
```

### 3. Set Provider to OneSignal

File: `.env`

```env
NOTIFICATION_PROVIDER="onesignal"
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
// Di .env, set provider ke mock:  NOTIFICATION_PROVIDER="mock"

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

*Updated: 28 Agustus 2026*
*Version: 1.1.0*
