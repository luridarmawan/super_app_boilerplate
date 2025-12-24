# Push Notification

## Overview

Super App mengimplementasikan **Multi-Provider Push Notification** dengan abstraction layer, memungkinkan pergantian provider notifikasi tanpa mengubah kode UI.

## Arsitektur

```
UI Layer
 └── NotificationProvider (Riverpod)
      └── BaseNotificationService  ← Abstract Interface
           ├── FcmNotificationService       (Firebase Cloud Messaging)
           ├── OneSignalNotificationService (OneSignal)
           └── MockNotificationService      (For Testing)
```

## Keuntungan

| Benefit | Deskripsi |
|---------|-----------|
| **Clean Separation** | Tidak ada `if (isFcm)` logic di UI layer |
| **Easy Switching** | Ganti provider dengan mengubah 1 baris const |
| **A/B Testing Ready** | Bisa dikontrol via remote config |
| **Testable** | `MockNotificationService` untuk unit testing |
| **Clean Architecture** | Konsisten dengan arsitektur aplikasi |

---

## Konfigurasi

### 1. Enable/Disable Notification

File: `lib/core/constants/app_info.dart`

```dart
// Set to false untuk menonaktifkan seluruh fitur notification
static const bool enableNotification = true;
```

### 2. Pilih Provider

File: `lib/core/notification/notification_provider.dart`

```dart
enum PushProvider {
  fcm,        // Firebase Cloud Messaging
  oneSignal,  // OneSignal
  mock,       // For testing
}

// Ubah baris ini untuk switch provider
const PushProvider pushProvider = PushProvider.fcm;
```

---

## Struktur File

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

## Setup Firebase Cloud Messaging (FCM)

### 1. Buat Project Firebase

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Klik "Add Project" atau "Create Project"
3. Masukkan nama project dan ikuti wizard

### 2. Tambahkan App ke Firebase

#### Android
1. Klik ikon Android di Firebase Console
2. Masukkan package name: `id.carik.superapp` (sesuaikan dengan aplikasi Anda)
3. Download `google-services.json`
4. Letakkan di: `android/app/google-services.json`

#### iOS
1. Klik ikon Apple di Firebase Console
2. Masukkan Bundle ID
3. Download `GoogleService-Info.plist`
4. Letakkan di: `ios/Runner/GoogleService-Info.plist`

### 3. Konfigurasi Android

File: `android/build.gradle`
```gradle
buildscript {
    dependencies {
        // Tambahkan ini
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

File: `android/app/build.gradle`
```gradle
// Di bagian paling bawah file
apply plugin: 'com.google.gms.google-services'
```

### 4. Konfigurasi iOS

1. Buka `ios/Runner.xcworkspace` di Xcode
2. Pilih Runner target > Signing & Capabilities
3. Klik "+ Capability" dan tambahkan "Push Notifications"
4. Tambahkan juga "Background Modes" dan enable "Remote notifications"

---

## Setup OneSignal

### 1. Buat Akun OneSignal

1. Buka [OneSignal Dashboard](https://onesignal.com)
2. Create new app
3. Pilih platform (Android/iOS/Web)
4. Ikuti wizard setup

### 2. Update App ID

File: `lib/core/notification/onesignal_notification_service.dart`

```dart
// Ganti dengan App ID dari OneSignal Dashboard
static const String _oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';
```

---

## Penggunaan

### Inisialisasi

Notification sudah otomatis diinisialisasi di `MainDashboard`. Jika perlu manual:

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

Untuk integrasi lebih mudah, gunakan `NotificationWrapper`:

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
  final bool isInitialized;           // Service sudah diinisialisasi
  final bool hasPermission;           // User sudah memberikan izin
  final String? deviceToken;          // Push token untuk device ini
  final NotificationMessage? lastMessage;  // Pesan terakhir diterima
  final bool isLoading;               // Operasi async sedang berjalan
  final String? error;                // Pesan error jika ada
}
```

---

## Testing dengan MockNotificationService

```dart
// Di test setup, set provider ke mock
const PushProvider pushProvider = PushProvider.mock;

// Di test
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

1. Pastikan `google-services.json` sudah ada di `android/app/`
2. Jalankan `flutter clean` dan `flutter pub get`
3. Pastikan Firebase sudah diinisialisasi di `main.dart`

### Notification Tidak Muncul di Android

1. Pastikan channel sudah dibuat dengan importance HIGH
2. Cek apakah app sudah punya permission di Settings
3. Untuk Android 13+, pastikan `POST_NOTIFICATIONS` permission diminta

### iOS Background Notification Tidak Jalan

1. Pastikan "Background Modes > Remote notifications" enabled di Xcode
2. Upload APNs Authentication Key ke Firebase Console
3. Pastikan `content-available: 1` ada di payload

---

## Referensi

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [OneSignal Flutter SDK](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)

---

📚 **Dokumentasi teknis lengkap:** [`lib/core/notification/README.md`](../lib/core/notification/README.md)
