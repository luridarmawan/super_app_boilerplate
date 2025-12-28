# Cara Restore Firebase

Dokumen ini berisi langkah-langkah untuk mengaktifkan kembali Firebase setelah sebelumnya di-disable untuk mengurangi ukuran APK.

## Mengapa Firebase Di-disable?

Firebase packages (`firebase_core`, `firebase_messaging`, `firebase_auth`) menambah sekitar **3-5 MB** ke ukuran APK. Jika aplikasi Anda tidak membutuhkan Firebase (misalnya menggunakan OneSignal untuk push notification dan Custom API untuk authentication), maka Firebase bisa di-disable untuk menghemat ukuran.

---

## Langkah-langkah Restore Firebase

### 1. Uncomment Dependencies di `pubspec.yaml`

Buka file `pubspec.yaml` dan uncomment baris berikut:

```yaml
# Push Notifications
firebase_core: ^4.3.0  # Hapus tanda # di depan
firebase_messaging: ^16.1.0  # Hapus tanda # di depan
flutter_local_notifications: ^19.5.0
onesignal_flutter: ^5.2.7

# Authentication
google_sign_in: ^7.2.0
firebase_auth: ^6.1.3  # Hapus tanda # di depan
```

### 2. Uncomment Import di `lib/main.dart`

Buka file `lib/main.dart` dan uncomment:

```dart
// Ubah dari:
// import 'package:firebase_core/firebase_core.dart';  // Disabled to reduce APK size

// Menjadi:
import 'package:firebase_core/firebase_core.dart';
```

Dan uncomment bagian initialization:

```dart
// Ubah dari:
// Firebase disabled to reduce APK size
// Uncomment below to re-enable Firebase
// final shouldInitFirebase = AppInfo.enableNotification &&
//     (AppInfo.notificationProvider.toLowerCase() == 'firebase' ||
//      AppInfo.notificationProvider.toLowerCase() == 'fcm');

// Menjadi:
// Determine if Firebase should be initialized
final shouldInitFirebase = AppInfo.enableNotification &&
    (AppInfo.notificationProvider.toLowerCase() == 'firebase' ||
     AppInfo.notificationProvider.toLowerCase() == 'fcm');
```

Dan uncomment Firebase.initializeApp():

```dart
// Ubah dari:
await Future.wait([
  PrefsService.initialize(),
  // Firebase initialization disabled
  // if (shouldInitFirebase)
  //   Firebase.initializeApp().catchError((e) {
  //     debugPrint('Firebase initialization error: $e');
  //     return Firebase.app();
  //   }),
]);

// Menjadi:
await Future.wait([
  PrefsService.initialize(),
  // Initialize Firebase if needed
  if (shouldInitFirebase)
    Firebase.initializeApp().catchError((e) {
      debugPrint('Firebase initialization error: $e');
      return Firebase.app();
    }),
]);
```

### 3. Update `lib/core/notification/notification_provider.dart`

Uncomment import dan ubah kembali ke Firebase:

```dart
// Ubah dari:
// import 'fcm_notification_service.dart';  // Disabled to reduce APK size

// Menjadi:
import 'fcm_notification_service.dart';
```

Ubah default provider:

```dart
// Ubah dari:
default:
  return PushProvider.mock; // Default to mock (Firebase disabled to reduce APK size)

// Menjadi:
default:
  return PushProvider.firebase; // Default to Firebase
```

Ubah case Firebase:

```dart
// Ubah dari:
case PushProvider.firebase:
  return MockNotificationService(); // FcmNotificationService disabled to reduce APK size

// Menjadi:
case PushProvider.firebase:
  return FcmNotificationService();
```

### 4. Restore `lib/core/notification/fcm_notification_service.dart`

Buka file dan hapus comment block `/* ... */` di awal dan akhir file sehingga seluruh kode kembali aktif.

File harus dimulai dengan:

```dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// ... dst
```

### 5. Jalankan Flutter Pub Get

```bash
flutter pub get
```

### 6. Konfigurasi Firebase

Pastikan file konfigurasi Firebase sudah ada:

#### Android
- Letakkan file `google-services.json` di folder `android/app/`

#### iOS
- Letakkan file `GoogleService-Info.plist` di folder `ios/Runner/`

### 7. Update `.env`

Pastikan konfigurasi di `.env` sudah benar:

```env
ENABLE_NOTIFICATION=true
NOTIFICATION_PROVIDER=firebase
```

### 8. Build Ulang

```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## Troubleshooting

### Error: FirebaseOptions not found

Pastikan file `google-services.json` sudah ada di `android/app/`.

### Error: Plugin already registered

Ini biasanya warning, bukan error. Bisa diabaikan.

### Error: Missing google-services.json

Download file dari [Firebase Console](https://console.firebase.google.com):
1. Pilih project Anda
2. Klik ikon gear → Project settings
3. Pilih app Android
4. Download `google-services.json`

---

## File-file yang Terpengaruh

| File | Perubahan |
|------|-----------|
| `pubspec.yaml` | Uncomment firebase dependencies |
| `lib/main.dart` | Uncomment import dan initialization |
| `lib/core/notification/notification_provider.dart` | Uncomment import dan ubah provider |
| `lib/core/notification/fcm_notification_service.dart` | Hapus comment block |

---

## Referensi

- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging/flutter/client)
- [Firebase Auth](https://firebase.google.com/docs/auth/flutter/start)
