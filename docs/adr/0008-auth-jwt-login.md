# ADR 0008 — Autentikasi: WordPress *JWT Login* di balik `BaseAuthService`, token dibagi lewat SharedPreferences

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `lib/core/auth/`, `lib/core/config/app_config.dart`, `packages/module_interface/lib/src/token_refresh_service.dart`

## Konteks

Basis pengguna OSA sudah ada di WordPress `app.ihasa.id`; membuat sistem identitas baru bukan pilihan. Sementara itu boilerplate aslinya dirancang untuk Firebase Auth, dan sebagian turunan produk mungkin memang ingin memakai Firebase.

Kebutuhan lain: **modul** (`arrow_sense`) memanggil API yang membutuhkan JWT yang sama, tetapi modul tidak boleh meng-import kode auth milik shell (lihat [ADR 0003](0003-module-interface-contract.md)).

## Keputusan

1. **Abstraksi `BaseAuthService`** (`lib/core/auth/auth_interface.dart`) dengan model netral `AuthUser` dan `AuthResult`. Dua implementasi:
   - `FirebaseAuthProvider`
   - `CustomApiAuthProvider` — jalur yang dipakai OSA Pilihan ditentukan `AuthStrategy` pada `appConfigProvider`; `authServiceProvider` memakai `ref.keepAlive()` agar service bersifat singleton.
2. **Backend auth adalah plugin *JWT Login*, bukan *JWT Authentication for WP REST API*.** `CustomApiAuthProvider` mendeteksi endpoint WordPress dari pola URL (`/wp-json/`, `rest_route=/jwt-login`, `rest_route=/simple-jwt-login`) dan menyesuaikan bentuk request. Nama field login dapat dikonfigurasi — OSA memakai `email`, bukan `username`.
3. **Google Sign-In** (`google_sign_in` v7) memakai jalur yang sama: ID Token diverifikasi ke endpoint OAuth `content.ihasa.id`, hasilnya tetap berupa `AuthUser` dengan `jwt`.
4. **Penyimpanan sesi**: seluruh `AuthUser` (termasuk `jwt`) diserialisasi sebagai JSON ke SharedPreferences dengan kunci **`app_saved_user`**. Kunci ini adalah *kontrak de-facto* antara shell dan modul.
5. **Refresh token** ditangani `TokenRefreshService` singleton: mutex `_isRefreshing` mencegah refresh paralel, URL dan method dikonfigurasi lewat `AUTH_TOKEN_REFRESH_URL` / `AUTH_TOKEN_REFRESH_METHOD`, dan ekstraksi JWT baru toleran terhadap beberapa bentuk respons (`data.jwt`, `data.token`, `data.access_token`, atau di level akar). Setelah sukses, service menulis balik ke `app_saved_user` dan memanggil callback `onTokenRefreshed`. Versi shell menambahkan `onAuthExpired` untuk memicu auto-logout.

## Konsekuensi

**Positif**
- Mengganti backend auth = mengganti satu implementasi `BaseAuthService`; layar login, registrasi, dan lupa password tidak berubah.
- Modul memperoleh JWT tanpa bergantung pada kode shell — cukup membaca `app_saved_user` dan memanggil `TokenRefreshService` dari `module_interface`.
- Refresh token terlindungi mutex, sehingga beberapa request 401 bersamaan tidak memicu banyak refresh.

**Negatif / biaya**
- **Kontrak implisit lewat kunci SharedPreferences.** `app_saved_user` di-*hardcode* di sedikitnya tiga tempat (provider auth shell, `TokenRefreshService` shell, `TokenRefreshService` modul). Mengganti nama kunci akan memutus sesi modul secara diam-diam.
- **Dua singleton `TokenRefreshService`** — satu di `lib/core/auth/`, satu di `packages/module_interface/lib/src/`. Keduanya bisa refresh secara bersamaan karena mutex-nya terpisah, dan hanya versi shell yang punya `onAuthExpired`. Ini utang teknis yang disadari; konsolidasi ke satu implementasi di `module_interface` adalah langkah berikutnya.
- JWT disimpan di SharedPreferences (plaintext), bukan keystore/keychain. Cukup untuk profil risiko saat ini, tetapi bukan penyimpanan aman.
- `authServiceProvider` masih meneruskan `baseUrl: 'https://api.example.com'` sebagai placeholder pada cabang `customApi` (`lib/core/config/app_config.dart:193`); URL sebenarnya datang dari `.env` di dalam provider. Placeholder ini menyesatkan dan perlu dibersihkan.
- Deteksi endpoint WordPress berbasis pencocokan substring URL — akan salah untuk instalasi dengan permalink tidak lazim.

## Alternatif yang ditolak

- **Firebase Auth sebagai satu-satunya jalur** — ditolak: basis pengguna sudah ada di WordPress.
- **Menaruh `BaseAuthService` di `module_interface`** — ditolak untuk saat ini: modul hanya butuh *token*, tidak butuh kemampuan login/registrasi. Yang dinaikkan ke kontrak hanya `TokenRefreshService`.

## Referensi

- [`docs/Auth.md`](../Auth.md), [`docs/WordPress.md`](../WordPress.md)
