# Cara Restore OneSignal

Dokumen ini berisi langkah-langkah untuk mengaktifkan kembali OneSignal setelah sebelumnya di-disable untuk mengurangi ukuran APK.

## Mengapa OneSignal Di-disable?

OneSignal SDK menambah sekitar **1-2 MB** ke ukuran APK. Jika aplikasi Anda tidak membutuhkan push notification, maka OneSignal bisa di-disable untuk menghemat ukuran.

---

## Langkah-langkah Restore OneSignal

### 1. Uncomment Dependency di `pubspec.yaml`

Buka file `pubspec.yaml` dan uncomment baris berikut:

```yaml
# Push Notifications
# firebase_core: ^4.3.0  # Disabled to reduce APK size
# firebase_messaging: ^16.1.0  # Disabled to reduce APK size
flutter_local_notifications: ^19.5.0
onesignal_flutter: ^5.2.7  # Hapus tanda # di depan
```

### 2. Update `lib/core/notification/notification_provider.dart`

Uncomment import:

```dart
// Ubah dari:
// import 'onesignal_notification_service.dart';  // Disabled to reduce APK size

// Menjadi:
import 'onesignal_notification_service.dart';
```

Ubah case OneSignal:

```dart
// Ubah dari:
case PushProvider.onesignal:
  return MockNotificationService(); // OneSignalNotificationService disabled to reduce APK size

// Menjadi:
case PushProvider.onesignal:
  return OneSignalNotificationService();
```

### 3. Restore `lib/core/notification/onesignal_notification_service.dart`

Buka file dan hapus comment block `/* ... */` di awal dan akhir file sehingga seluruh kode kembali aktif.

File harus dimulai dengan:

```dart
import 'dart:async';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ... dst
```

### 4. Jalankan Flutter Pub Get

```bash
flutter pub get
```

### 5. Konfigurasi OneSignal

Pastikan konfigurasi di `.env` sudah benar:

```env
ENABLE_NOTIFICATION=true
NOTIFICATION_PROVIDER=onesignal
ONESIGNAL_APP_ID=your-onesignal-app-id-here
```

### 6. Dapatkan OneSignal App ID

1. Buka [OneSignal Dashboard](https://app.onesignal.com)
2. Pilih atau buat app baru
3. Copy App ID dari Settings > Keys & IDs
4. Paste ke `.env` file

### 7. Build Ulang

```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## Troubleshooting

### Error: OneSignal not initialized

Pastikan `ONESIGNAL_APP_ID` sudah diisi dengan benar di `.env` file.

### Notifikasi tidak muncul

1. Pastikan `ENABLE_NOTIFICATION=true` di `.env`
2. Pastikan `NOTIFICATION_PROVIDER=onesignal` di `.env`
3. Pastikan permission notification sudah diizinkan di device

### Error: No implementation found

Pastikan import dan case di `notification_provider.dart` sudah di-uncomment.

---

## File-file yang Terpengaruh

| File | Perubahan |
|------|-----------|
| `pubspec.yaml` | Uncomment onesignal_flutter |
| `lib/core/notification/notification_provider.dart` | Uncomment import dan ubah case |
| `lib/core/notification/onesignal_notification_service.dart` | Hapus comment block |
| `.env` | Set NOTIFICATION_PROVIDER=onesignal |

---

## Referensi

- [OneSignal Flutter SDK](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [OneSignal Dashboard](https://app.onesignal.com)
