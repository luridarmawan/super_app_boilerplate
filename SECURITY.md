# Security Policy

🇬🇧 English (default) · [🇮🇩 Bahasa Indonesia](#kebijakan-keamanan)

## Supported Versions

| Version              | Supported |
|----------------------|-----------|
| 3.x (latest release) | Yes       |
| < 3.0                | No        |

Security fixes are applied only to the latest release. Please upgrade before
reporting an issue that may already be fixed.

## Reporting a Vulnerability

**Do not open a public issue.** Report privately through GitHub Security
Advisories:

https://github.com/luridarmawan/super_app_boilerplate/security/advisories/new

Please include:

- Steps to reproduce, or a minimal proof of concept.
- The affected version (see `pubspec.yaml`) and platform (Android, iOS, Web).
- The impact you believe it has.

We aim to acknowledge reports within 5 working days. This project is
maintained by volunteers on a best-effort basis, so fix timelines may vary.
We will coordinate public disclosure with you once a fix is available.

## Scope

The following are considered security vulnerabilities:

- Leakage of tokens, credentials, or session data (auth providers,
  `TokenRefreshService`, local storage, preferences).
- Weaknesses in network communication (TLS handling, interceptors, token
  refresh flow).
- A submodule or dynamic module gaining access to core app data or
  credentials beyond what it is granted.
- Deep links or quick actions that can trigger privileged behaviour without
  authorization.
- Code injection through remote configuration or module manifests.

The following are **not** considered vulnerabilities in this project:

- Secrets that a user of this boilerplate bundles into their own APK/IPA.
  See the notes below.
- Bugs in third-party dependencies. Report them upstream; we will bump the
  version once a patch is released.
- Issues that require a rooted or jailbroken device, or physical access to an
  unlocked device.

## Notes for Boilerplate Users

- Never commit `.env`, `android/key.properties`, `*.jks`, `*.keystore`, or
  `google-services.json`. All of them are already listed in `.gitignore`.
- Values in `.env` are compiled into the binary and can be extracted by end
  users. Do not put server-side secrets there; use them only for public
  identifiers and endpoints.
- Change the default Application ID (`id.carik.superapp_demo`) before
  releasing. See `docs/Change-Application-Id.md`.
- Keep your release keystore outside the repository. See `docs/Keystore.md`.
- Review each submodule before adding it; modules run with the same
  permissions as the host app. See `docs/SubModule.md`.

---

# Kebijakan Keamanan

[🇬🇧 English](#security-policy) · 🇮🇩 Bahasa Indonesia

## Versi yang Didukung

| Versi                 | Didukung |
|-----------------------|----------|
| 3.x (rilis terbaru)   | Ya       |
| < 3.0                 | Tidak    |

Perbaikan keamanan hanya diterapkan pada rilis terbaru. Harap perbarui versi
Anda sebelum melaporkan masalah yang mungkin sudah diperbaiki.

## Melaporkan Kerentanan

**Jangan membuka issue publik.** Laporkan secara privat melalui GitHub
Security Advisories:

https://github.com/luridarmawan/super_app_boilerplate/security/advisories/new

Sertakan:

- Langkah reproduksi atau proof of concept minimal.
- Versi yang terdampak (lihat `pubspec.yaml`) dan platform (Android, iOS, Web).
- Dampak yang Anda perkirakan.

Kami menargetkan respons awal dalam 5 hari kerja. Proyek ini dirawat secara
sukarela dengan upaya terbaik, sehingga waktu perbaikan dapat bervariasi.
Pengumuman publik akan kami koordinasikan dengan Anda setelah perbaikan
tersedia.

## Cakupan

Yang dianggap kerentanan keamanan:

- Kebocoran token, kredensial, atau data sesi (auth provider,
  `TokenRefreshService`, penyimpanan lokal, preferences).
- Kelemahan pada komunikasi jaringan (penanganan TLS, interceptor, alur
  refresh token).
- Submodule atau modul dinamis yang memperoleh akses ke data inti aplikasi
  atau kredensial melebihi yang diizinkan.
- Deep link atau quick action yang dapat memicu perilaku istimewa tanpa
  otorisasi.
- Injeksi kode melalui remote configuration atau manifest modul.

Yang **bukan** kerentanan pada proyek ini:

- Secret yang dibundel oleh pengguna boilerplate ke dalam APK/IPA mereka
  sendiri. Lihat catatan di bawah.
- Bug pada dependensi pihak ketiga. Laporkan ke upstream; kami akan menaikkan
  versi setelah patch dirilis.
- Masalah yang memerlukan perangkat root/jailbreak, atau akses fisik ke
  perangkat yang tidak terkunci.

## Catatan untuk Pengguna Boilerplate

- Jangan pernah commit `.env`, `android/key.properties`, `*.jks`,
  `*.keystore`, atau `google-services.json`. Semuanya sudah ada di
  `.gitignore`.
- Nilai di `.env` ikut dikompilasi ke dalam binary dan dapat diekstrak oleh
  pengguna akhir. Jangan menyimpan secret sisi server di sana; gunakan hanya
  untuk identifier publik dan endpoint.
- Ganti Application ID default (`id.carik.superapp_demo`) sebelum rilis.
  Lihat `docs/Change-Application-Id.md`.
- Simpan keystore rilis di luar repository. Lihat `docs/Keystore.md`.
- Tinjau setiap submodule sebelum menambahkannya; modul berjalan dengan izin
  yang sama dengan aplikasi host. Lihat `docs/SubModule.md`.
