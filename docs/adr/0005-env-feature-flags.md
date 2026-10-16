# ADR 0005 — Konfigurasi & feature flag lewat `.env` (dotenv), bukan build flavor

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `.env.example`, `lib/core/constants/app_info.dart`, `lib/core/config/app_config.dart`, `ModuleRegistry.isModuleEnabled`

## Konteks

Satu basis kode harus melayani beberapa varian: boilerplate publik, produk OSA, dan turunan lain. Yang berbeda antar-varian bukan hanya URL API, tapi juga *fitur mana yang ada*: push notification, Google Sign-In, GPS, splash screen, quick action, registrasi mandiri, dan setiap modul.

Menyimpan perbedaan itu sebagai `const` di kode berarti setiap varian butuh branch atau patch. Build flavor Flutter menyelesaikan sebagian, tapi memaksa konfigurasi masuk ke Gradle/Xcode dan menambah matriks build.

## Keputusan

Seluruh konfigurasi runtime dibaca dari satu berkas `.env` (paket `flutter_dotenv`), dimuat paling awal di `main()` — sebelum apa pun yang lain:

```dart
await dotenv.load(fileName: ".env");
```

Konvensi yang berlaku:

- **Flag modul**: `ENABLE_MODULE_{NAMA_MODUL}` (huruf besar). `ModuleRegistry.isModuleEnabled` menerima `true`, `1`, atau `yes`. Modul yang flag-nya tidak terisi **tidak diregistrasi sama sekali** — route, workspace icon, dashboard widget, dan quick action-nya tidak ada.
- **Flag fitur**: `ENABLE_GPS`, `ENABLE_SPLASH_SCREEN`, `ENABLE_GOOGLE_LOGIN`, `ENABLE_QUICK_ACTION`, `REMOTE_CONFIG_ENABLE`, dst.
- **Konfigurasi modul**: berprefiks nama modul — `ARROW_SENSE_API_BASE_URL`, `ARROW_SENSE_ENDPOINT_*`, `ARROW_SENSE_EVENT_WIDGET_ENABLE`.
- Nilai dibaca lewat `AppInfo` (accessor bertipe) untuk shell, dan langsung lewat `dotenv.env[...]` di dalam modul (modul tidak boleh bergantung pada `AppInfo` milik shell).

`.env` tidak di-track Git; `.env.example` yang di-track dan menjadi dokumentasi kunci yang ada.

## Konsekuensi

**Positif**
- Menghidupkan/mematikan fitur = mengubah satu baris teks, tanpa rebuild konfigurasi native.
- Rahasia (client ID, URL internal) tidak masuk repo.
- Feature flag dan kill-switch bisa dipakai untuk menekan ukuran APK: push notification dimatikan dengan `NOTIFICATION_PROVIDER=mock` (lihat [ADR 0010](0010-notification-abstraction.md)).

**Negatif / biaya**
- **Tidak ada validasi skema.** Salah ketik nama kunci menghasilkan `null` yang diam-diam jatuh ke nilai default, bukan error. Contoh nyata yang tercatat di `BRIEF.md`: `AppInfo.authUseCookie` (`lib/core/constants/app_info.dart:259`) membandingkan dengan string `'false'` sehingga `AUTH_USE_COOKIE=true` justru **mematikan** cookie interceptor.
- Kunci yatim menumpuk tanpa terdeteksi: `PRIMARY_COLOR`, `PRIMARY_COLOR_DARK`, `X_COLOR_1..3`, dan `API_ENDPOINT_*` ada di `.env` tetapi tidak dibaca kode mana pun.
- `.env` ikut ter-*bundle* sebagai asset di APK — **bukan tempat menyimpan rahasia yang benar-benar rahasia**; anggap isinya dapat dibaca siapa pun yang membongkar APK.
- Karena flag dievaluasi saat runtime, kode fitur yang mati **tetap ikut ter-compile** ke dalam binary kecuali dependensinya juga dilepas dari `pubspec.yaml`.

## Alternatif yang ditolak

- **Build flavor (Android product flavor / Xcode scheme)** — ditolak: memindahkan konfigurasi ke ranah native dan menggandakan matriks build.
- **`--dart-define`** — ditolak: aman dari bundling asset, tetapi daftar flag yang panjang jadi tidak praktis di perintah build dan tidak bisa diubah tanpa rebuild.
- **Konstanta di kode** — ditolak: setiap varian produk butuh patch.

## Referensi

- [`docs/Development-and-Build.md`](../Development-and-Build.md)
- [`BRIEF.md` §6 Status Fitur](../../BRIEF.md)
