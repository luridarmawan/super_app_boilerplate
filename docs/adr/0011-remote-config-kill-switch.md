# ADR 0011 — Remote Config dua sumber (Firebase / JSON kustom) sebagai kill-switch & force-update

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `lib/core/services/remote_config_service.dart`, `lib/features/maintenance/maintenance_mode_screen.dart`

## Konteks

Aplikasi mobile terdistribusi lewat store: begitu versi rilis, tidak ada cara menariknya kembali dengan cepat. OSA butuh dua kemampuan operasional:

- **Maintenance mode** — menahan pengguna di layar informasi ketika backend sedang turun, tanpa menunggu rilis baru.
- **Force update** — memaksa pengguna dengan build lama memperbarui aplikasi ketika kontrak API berubah.

Firebase Remote Config menyediakan ini, tetapi menyeret ketergantungan penuh pada Firebase (inisialisasi, `google-services.json`, ukuran APK) untuk kebutuhan yang inti-nya hanyalah "ambil satu berkas JSON".

## Keputusan

`RemoteConfigService` mendukung **dua sumber** dengan API pembacaan yang sama:

| Sumber | Aktivasi | Catatan |
|--------|----------|---------|
| Firebase Remote Config | `REMOTE_CONFIG_ENABLE=true`, tanpa custom URL | `Firebase.initializeApp()` dipanggil di `main()` dan dibungkus `catchError` — kegagalan bersifat **non-fatal** |
| JSON kustom | `REMOTE_CONFIG_CUSTOM_URL` terisi | OSA produksi memakai ini: `https://api.carik.id/osa/remote_config.json` |

Kunci yang dikenali beserta nilai default: `maintenance_mode` (false), `force_update` (false), `minimum_version_number` (0), `latest_version`, `update_url`, `widget_location_enable`, `ai_provider`. Semua dibaca lewat getter statis (`RemoteConfigService.maintenanceMode`, dst.) sehingga pemanggil tidak tahu sumbernya yang mana.

Pengecekan versi membandingkan **build number** (`AppInfo.buildNumber`) terhadap `latest_version_number` dan `minimum_version_number`, dengan beberapa alias kunci yang diterima (`min_version_number`, blok `version` di root JSON) demi kompatibilitas format. `fetchRealtime()` memaksa fetch dengan `minimumFetchInterval: Duration.zero` untuk kasus yang tidak boleh menunggu cache.

## Konsekuensi

**Positif**
- Kill-switch dan force-update tersedia tanpa rilis baru.
- Produk yang tidak memakai Firebase tetap mendapat kemampuan penuh dengan satu berkas JSON statis — cukup di-*host* di CDN mana pun.
- Kegagalan inisialisasi Firebase tidak menjatuhkan startup; aplikasi jatuh ke nilai default.

**Negatif / biaya**
- **Dua jalur kode untuk satu fitur** (`_initializeFirebase` dan `_fetchCustomConfig`), dengan penanganan alias kunci yang berbeda. Menambah parameter baru berarti memastikan keduanya konsisten.
- `RemoteConfigService` berupa **state statis global** (`_customConfig`, `_versionInfo`, `_updateDialogShown`). Sulit di-test dan tidak bisa punya dua konfigurasi berbeda dalam satu proses.
- Jalur JSON kustom tidak punya penandatanganan atau autentikasi: siapa pun yang menguasai URL itu bisa memicu maintenance mode di seluruh basis pengguna. URL harus diperlakukan sebagai aset produksi.
- Perbandingan versi bergantung pada build number numerik. Penomoran versi di repo saat ini tidak konsisten (`CHANGELOG.md` masih di `v1.0.2-61` sementara `pubspec.yaml` sudah `1.1.6+92`), jadi disiplin `tool/add_version.dart` menjadi wajib — lihat [ADR 0012](0012-dart-tooling-scripts.md).

## Alternatif yang ditolak

- **Firebase Remote Config saja** — ditolak: memaksa setiap turunan produk memakai Firebase.
- **Feature flag `.env` saja** — ditolak: `.env` ter-bundle saat build, jadi tidak bisa mengubah perilaku aplikasi yang sudah terpasang di perangkat pengguna.

## Referensi

- [`docs/Remote-Config.md`](../Remote-Config.md)
