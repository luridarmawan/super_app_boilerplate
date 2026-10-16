# ADR 0007 — Network layer: Dio + Retrofit di atas `BaseRepository`, dengan penanganan bot-protection

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `lib/core/network/`, khususnya `repository/base_repository.dart`, `api_client.dart`, `interceptors/`

## Konteks

Backend OSA adalah WordPress di `app.ihasa.id` plus layanan konten `api.carik.id`. Keduanya berada di belakang proteksi anti-bot (Cloudflare, dan pada beberapa host Imunify360). Konsekuensinya, permintaan HTTP yang sah dari aplikasi kadang dibalas **halaman HTML challenge dengan status 200/503**, bukan JSON — kegagalan yang tidak terlihat sebagai error HTTP biasa dan akan meledak sebagai `FormatException` saat parsing.

Selain itu semua request butuh perlakuan yang sama: header auth, logging, penerjemahan error menjadi exception domain.

## Keputusan

1. **Dio** sebagai HTTP client, dengan rantai interceptor di `lib/core/network/interceptors/`: `auth_interceptor` (menyisipkan Bearer token), `error_interceptor` (memetakan error ke `ApiException`), `logging_interceptor`.
2. **Retrofit** (`retrofit` + `retrofit_generator`, hasil generate di `services/api_service.g.dart`) untuk endpoint yang kontraknya stabil.
3. **`BaseRepository`** sebagai kelas abstrak induk semua repository shell (`article_repository`, `banner_repository`, `campaign_home_repository`, `user_repository`). Di dalamnya:
   - `detectBotProtection(response)` mengklasifikasikan respons menjadi `none` / `cloudflare` / `imunify360` / `generic`, berdasarkan tanda tangan HTML (`Just a moment...`, `cf-browser-verification`, `__cf_chl_opt`, …), header `cf-ray`, dan penanda Imunify360.
   - `fetchWithCloudflareRetry(fn)` mengulang hingga 3 kali dengan jeda 2 detik **hanya** untuk Cloudflare. Untuk Imunify360 request **langsung gagal** tanpa retry, karena pemblokiran bersifat per-IP sehingga mengulang tidak akan menolong.
   - `_parseResponse` / `_handleError` menyeragamkan pembungkusan hasil dan error.
4. Aplikasi mengirim **User-Agent menyerupai browser** untuk mengurangi kemungkinan terjaring proteksi bot (`ApiConfig.browserUserAgent`).
5. Cookie jar opsional (`dio_cookie_manager` + `cookie_jar`, diaktifkan lewat `AUTH_USE_COOKIE`) untuk backend yang memerlukan sesi berbasis cookie.

## Konsekuensi

**Positif**
- Kegagalan anti-bot terdeteksi dan diklasifikasikan, bukan muncul sebagai parse error yang membingungkan; UI bisa jatuh ke data fallback dengan pesan yang benar.
- Retry hanya dilakukan untuk kasus yang memang bisa pulih — hemat waktu dan tidak memperburuk pemblokiran per-IP.
- `_handleError` dan `_parseResponse` memiliki fan-in tertinggi kedua di seluruh graf kode: penanganan error benar-benar terpusat di shell.

**Negatif / biaya**
- Deteksi berbasis **pencocokan string** pada isi respons. Halaman challenge yang berubah kata-katanya akan lolos deteksi. Ini rapuh secara inheren dan perlu ditinjau berkala.
- Menyamar sebagai browser adalah perlombaan yang tidak pernah selesai; kalau backend menambah proteksi, aplikasi perlu penyesuaian lagi.
- Dua gaya pemanggilan hidup berdampingan: Retrofit (generated) dan Dio manual di dalam `BaseRepository`. `build_runner` wajib dijalankan ulang setiap `api_service.dart` berubah.
- **Modul tidak memakai lapisan ini.** `arrow_sense` membangun Dio-nya sendiri, sehingga tidak mendapat retry Cloudflare maupun interceptor apa pun — lihat [ADR modul 0003](../../modules/arrow_sense/docs/adr/0003-standalone-network-layer.md).

## Alternatif yang ditolak

- **`http` polos** — ditolak: tidak ada interceptor, retry, atau cookie jar.
- **Membiarkan proteksi bot menjadi error biasa** — ditolak: pengguna melihat "gagal memuat" padahal cukup ditunggu 2 detik dan diulang.
- **Menaikkan `BaseRepository` ke `module_interface`** — belum dilakukan; akan menyeret `ApiClient` dan konfigurasi shell ke dalam kontrak modul.

## Referensi

- [`docs/API.md`](../API.md)
