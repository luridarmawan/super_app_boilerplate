# ADR 0010 — Notifikasi push di balik `BaseNotificationService`, produksi memakai `mock`

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `lib/core/notification/`

## Konteks

Boilerplate perlu mendukung lebih dari satu penyedia push notification karena tiap turunan produk punya preferensi berbeda (Firebase Cloud Messaging vs OneSignal), dan pengembangan lokal butuh jalur yang tidak menyentuh layanan mana pun.

Untuk OSA sendiri ada kendala konkret: SDK FCM dan OneSignal menambah ukuran APK secara signifikan, sementara push notification belum menjadi fitur yang dipakai produk.

## Keputusan

1. Definisikan antarmuka `BaseNotificationService` (`notification_interface.dart`): `initialize()`, `requestPermission()`, `getPermissionStatus()`, `getToken()`, `subscribeToTopic()` / `unsubscribeFromTopic()`, serta stream `onForegroundMessage` dan `onNotificationTap`. Payload dinormalkan menjadi `NotificationMessage`, status izin menjadi `NotificationPermissionStatus`.
2. Tiga implementasi: `FcmNotificationService`, `OneSignalNotificationService`, `MockNotificationService`.
3. Pemilihan implementasi terjadi saat runtime dari `AppInfo.notificationProvider` (`firebase`/`fcm`, `onesignal`, `mock`/`test`), diekspos ke UI lewat `notificationProvider` Riverpod.
4. **Untuk build produksi OSA, `NOTIFICATION_PROVIDER=mock` dan `ENABLE_NOTIFICATION=false`.** Dependensi FCM dan OneSignal di `pubspec.yaml` di-*comment out* agar tidak ikut ter-link ke APK. Prosedur mengaktifkan kembali didokumentasikan terpisah.

## Konsekuensi

**Positif**
- Mengganti penyedia tidak menyentuh UI: layar dan provider berbicara ke antarmuka.
- `MockNotificationService` membuat alur notifikasi bisa diuji di emulator tanpa kredensial layanan apa pun (ada `notification_test_panel.dart` untuk memicu notifikasi palsu).
- Ukuran APK produksi turun karena SDK push tidak ikut ter-bundle.

**Negatif / biaya**
- **Konfigurasi runtime tidak cukup untuk melepas SDK.** Karena flag hanya memilih implementasi, menghapus SDK dari APK menuntut langkah manual: meng-comment dependensi di `pubspec.yaml` *dan* kode yang meng-import-nya. Akibatnya `fcm_notification_service.dart` dan `onesignal_notification_service.dart` bisa berada dalam keadaan tidak dapat dikompilasi sampai prosedur pemulihan dijalankan.
- Ada dua sumber kebenaran untuk status fitur ini: `.env` dan komentar di `pubspec.yaml`. Keduanya harus diubah bersamaan.
- Antarmuka mencerminkan model FCM (topic, token); memetakan konsep OneSignal ke dalamnya tidak selalu satu-lawan-satu.

## Alternatif yang ditolak

- **Memilih satu penyedia saja** — ditolak: boilerplate harus melayani beberapa produk.
- **Membiarkan SDK tetap ter-bundle dan hanya mematikannya lewat flag** — ditolak: tidak memberi penghematan ukuran APK, yang justru menjadi alasan utama fitur ini dinonaktifkan.

## Referensi

- [`docs/Notification.md`](../Notification.md)
- [`docs/Notification-Firebase-Restore.md`](../Notification-Firebase-Restore.md)
- [`docs/Notification-Onesignal-Restore.md`](../Notification-Onesignal-Restore.md)
