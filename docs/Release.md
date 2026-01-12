# Release & Keystore Management

Dokumentasi untuk manajemen keystore dan proses release aplikasi Android.

## Daftar Isi

- [Overview](#overview)
- [Keystore Types](#keystore-types)
- [Team Development Setup](#team-development-setup)
- [Google Sign-In Configuration](#google-sign-in-configuration)
- [Build Commands](#build-commands)
- [Production Release](#production-release)
- [Troubleshooting](#troubleshooting)

---

## Overview

Aplikasi Android memerlukan **digital signature** untuk diinstal di perangkat. Signature ini dibuat menggunakan **keystore** yang berisi private key.

Ada 2 jenis keystore yang digunakan:
1. **Debug Keystore** - untuk development
2. **Release Keystore** - untuk production/Play Store

---

## Keystore Types

### Debug Keystore

| Property | Value |
|----------|-------|
| Location | `%USERPROFILE%\.android\debug.keystore` (Windows) |
|          | `~/.android/debug.keystore` (Mac/Linux) |
| Password | `android` |
| Key Alias | `androiddebugkey` |
| Key Password | `android` |
| Validity | Auto-generated, 30 years |

**Keamanan:** AMAN untuk dimasukkan ke repository karena:
- Tidak bisa digunakan untuk publish ke Play Store
- Password sudah diketahui publik
- Hanya untuk development/testing

### Release Keystore

| Property | Value |
|----------|-------|
| Location | Disimpan secara aman (tidak di repo) |
| Password | Rahasia |
| Key Alias | Custom |
| Key Password | Rahasia |
| Validity | 25+ years (recommended) |

**Keamanan:** JANGAN dimasukkan ke repository karena:
- Digunakan untuk menandatangani APK resmi
- Jika bocor, orang lain bisa upload update berbahaya
- Simpan di secure storage (1Password, HashiCorp Vault, dll)

---

## Team Development Setup

### Masalah: Setiap Developer Punya Keystore Berbeda

Secara default, setiap developer memiliki `debug.keystore` yang berbeda dengan SHA-1 fingerprint yang unik. Ini menyebabkan masalah pada:
- Google Sign-In
- Firebase Authentication
- Google Maps API
- Fitur lain yang memerlukan SHA-1 verification

### Solusi: Shared Debug Keystore

**Opsi 1: Share keystore file ke semua developer**

1. Salin `debug.keystore` dari developer yang sudah terdaftar di Google Cloud Console
2. Simpan di folder project: `android/keystores/debug.keystore`
3. Setiap developer menyalin ke lokasi default:
   ```bash
   # Windows
   copy android\keystores\debug.keystore %USERPROFILE%\.android\debug.keystore
   
   # Mac/Linux
   cp android/keystores/debug.keystore ~/.android/debug.keystore
   ```

**Opsi 2: Daftarkan semua SHA-1 di Google Cloud Console**

Setiap developer mendapatkan SHA-1 masing-masing:

```bash
# Windows
keytool -list -v -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android

# Mac/Linux
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android
```

Kemudian daftarkan semua SHA-1 di:
- **Firebase Console** > Project Settings > Your Apps > Add fingerprint
- **Google Cloud Console** > APIs & Credentials > OAuth 2.0 Client IDs

### Rekomendasi

Gunakan **Opsi 1 (shared keystore)** untuk kemudahan:
- Setup sekali, jalan untuk semua developer
- Tidak perlu update setiap ada developer baru
- Konsistensi di seluruh tim

---

## Google Sign-In Configuration

### Prerequisites

1. **Google Cloud Console** project dengan OAuth 2.0 configured
2. **SHA-1 fingerprint** terdaftar untuk package name aplikasi
3. **Web Client ID** untuk `serverClientId` di Flutter

### Mendapatkan SHA-1 Fingerprint

```bash
# Debug keystore
keytool -list -v -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android 2>&1 | findstr "SHA1"

# Release keystore
keytool -list -v -alias YOUR_KEY_ALIAS -keystore path/to/release.keystore
```

### Mendaftarkan SHA-1

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Pilih project > APIs & Services > Credentials
3. Buat atau edit **OAuth 2.0 Client ID** untuk Android:
   - Package name: `id.ihasa.app`
   - SHA-1 certificate fingerprint: `XX:XX:XX:...`

### Konfigurasi di Aplikasi

Pastikan `.env` memiliki Web Client ID yang benar:

```env
GOOGLE_CLIENT_ID=xxxxxxxxxxxxx.apps.googleusercontent.com
AUTH_GOOGLE_VERIFICATION_URL=https://your-api.com/auth/google/verify
```

---

## Build Commands

### Development

```bash
# Run di emulator/device (debug mode)
flutter run

# Run dengan release mode (untuk testing performance)
flutter run --release
```

### Build APK

```bash
# Build APK (release mode, semua arsitektur)
flutter build apk

# Build APK dengan analisis ukuran
flutter build apk --analyze-size --target-platform=android-arm64

# Build APK split per arsitektur (ukuran lebih kecil)
flutter build apk --split-per-abi
```

### Build App Bundle (untuk Play Store)

```bash
# Build AAB (format yang diterima Play Store)
flutter build appbundle
```

### Tabel Build Mode

| Perintah | Mode | Signing Config |
|----------|------|----------------|
| `flutter run` | Debug | debug.keystore |
| `flutter run --release` | Release | Sesuai build.gradle.kts |
| `flutter build apk` | Release | Sesuai build.gradle.kts |
| `flutter build apk --debug` | Debug | debug.keystore |
| `flutter build appbundle` | Release | Sesuai build.gradle.kts |

---

## Production Release

### 1. Buat Release Keystore

```bash
keytool -genkey -v -keystore release.keystore -alias app_release_key -keyalg RSA -keysize 2048 -validity 10000
```

Simpan informasi berikut dengan aman:
- File `release.keystore`
- Store password
- Key alias
- Key password

### 2. Buat key.properties

Buat file `android/key.properties` (JANGAN commit ke repo):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=app_release_key
storeFile=../keystores/release.keystore
```

### 3. Update .gitignore

Pastikan file sensitif tidak masuk repository:

```gitignore
# Keystore
android/key.properties
android/keystores/release.keystore
*.jks
*.keystore
!android/keystores/debug.keystore
```

### 4. Update build.gradle.kts

```kotlin
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "id.ihasa.app"
    compileSdk = flutter.compileSdkVersion
    
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }
    
    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### 5. Daftarkan SHA-1 Release di Google Cloud Console

```bash
keytool -list -v -alias app_release_key -keystore release.keystore
```

Tambahkan SHA-1 ke:
- Google Cloud Console
- Firebase Console (jika menggunakan Firebase)

### 6. Build untuk Release

```bash
# Build App Bundle untuk Play Store
flutter build appbundle

# Atau APK untuk distribusi langsung
flutter build apk --release
```

---

## Troubleshooting

### Error: Google Sign-In Canceled

**Gejala:**
```
GoogleSignInException(code GoogleSignInExceptionCode.canceled, activity is cancelled by the user., null)
```

**Penyebab:**
- SHA-1 fingerprint tidak terdaftar di Google Cloud Console
- Package name tidak cocok
- Web Client ID salah

**Solusi:**
1. Cek SHA-1: `keytool -list -v -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android`
2. Pastikan terdaftar di Google Cloud Console
3. Pastikan package name sesuai (`id.ihasa.app`)
4. Pastikan `GOOGLE_CLIENT_ID` di `.env` adalah Web Client ID (bukan Android Client ID)

### Error: APK tidak bisa diinstall

**Penyebab:**
- APK di-sign dengan keystore berbeda dari versi sebelumnya

**Solusi:**
- Uninstall versi lama terlebih dahulu
- Atau pastikan menggunakan keystore yang sama

### Error: Play Store menolak upload

**Penyebab:**
- Menggunakan debug keystore
- App bundle di-sign dengan keystore berbeda

**Solusi:**
- Pastikan menggunakan release keystore yang sama seperti versi sebelumnya
- Jika kehilangan keystore, hubungi Google Play Support

---

## Quick Reference

### Lokasi File Penting

| File | Lokasi | Masuk Repo? |
|------|--------|-------------|
| Debug Keystore (shared) | `android/keystores/debug.keystore` | ✅ Ya |
| Release Keystore | Secure storage | ❌ Tidak |
| key.properties | `android/key.properties` | ❌ Tidak |
| build.gradle.kts | `android/app/build.gradle.kts` | ✅ Ya |

### Perintah Berguna

```bash
# Cek SHA-1 debug keystore
keytool -list -v -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android 2>&1 | findstr "SHA1"

# Cek SHA-1 release keystore
keytool -list -v -alias YOUR_ALIAS -keystore path/to/release.keystore 2>&1 | findstr "SHA1"

# Clean build
flutter clean && flutter pub get && flutter build apk

# Build dengan verbose
flutter build apk -v
```

---

*Dokumentasi ini terakhir diupdate: Januari 2026*
