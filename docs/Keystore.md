# Keystore & SHA-1

Catatan perintah `keytool` untuk **debug keystore** — dipakai saat mendaftarkan SHA-1 ke
Google Cloud Console (Google Sign-In) atau Firebase Console.

> Untuk **release keystore** dan signing, lihat [`Release.md`](./Release.md).

---

## Melihat SHA-1 debug keystore

```bash
# Linux / macOS
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

```bat
:: Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" ^
  -alias androiddebugkey -storepass android -keypass android
```

---

## Membuat ulang debug keystore

Diperlukan bila `debug.keystore` hilang atau rusak.

```bat
:: Windows
keytool -genkey -v -keystore "%USERPROFILE%\.android\debug.keystore" ^
  -storepass android -alias androiddebugkey -keypass android ^
  -keyalg RSA -keysize 2048 -validity 10000
```

```bash
# Di dalam project (mis. untuk CI)
keytool -genkey -v -keystore android/keystores/debug.keystore \
  -storepass android -alias androiddebugkey -keypass android \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Android Debug,O=Android,C=US"
```

---

## Mendaftarkan SHA-1

Salin nilai **SHA1** dari output `keytool -list`, lalu tambahkan ke:

1. **Google Cloud Console** → *APIs & Services* → *Credentials* → OAuth Client ID (Android)
   — isi package name `id.ihasa.app` dan SHA-1 tersebut.
2. **Firebase Console** → *Project settings* → aplikasi Android → *Add fingerprint*
   (bila Firebase digunakan).

Package name harus sama dengan `applicationId` di `android/app/build.gradle.kts`.

---

## Terkait

- [`Release.md`](./Release.md) — release keystore & signing
- [`Auth.md`](./Auth.md) — konfigurasi Google Sign-In
- [`Change-Application-Id.md`](./Change-Application-Id.md) — mengganti application ID

---

*Diperbarui: 28 Agustus 2026*
