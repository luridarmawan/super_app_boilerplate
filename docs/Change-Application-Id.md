# Change Application ID

Tool untuk mengubah Application ID (Package Name / Bundle Identifier) di seluruh project Flutter secara otomatis.

> **📚 Related Documents:**
> - **[README.md](../README.md)** - Main project documentation
> - **[SuperApp-Architecture.md](./SuperApp-Architecture.md)** - Architecture overview
> - **[Auth.md](./Auth.md)** - Authentication documentation

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [What Gets Changed](#what-gets-changed)
- [Application ID Format](#application-id-format)
- [Usage Examples](#usage-examples)
- [Post-Change Steps](#post-change-steps)
  - [Clean & Rebuild](#1-clean--rebuild)
  - [Update Firebase](#2-update-firebase)
  - [Update Google Sign-In](#3-update-google-sign-in-oauth)
  - [Fix Google Sign-In Error](#fix-google-sign-in-error-after-app-id-change)
- [Manual Change Guide](#manual-change-guide)
- [Troubleshooting](#troubleshooting)

---

## Overview

Application ID adalah identifier unik untuk aplikasi di Play Store (Android) dan App Store (iOS). Tool ini memudahkan proses perubahan Application ID yang biasanya harus dilakukan secara manual di banyak file.

### Kenapa Perlu Mengubah Application ID?

| Situasi | Alasan |
|---------|--------|
| **Branding** | Menggunakan package name perusahaan sendiri |
| **Publishing** | Setiap app di Play Store/App Store harus memiliki ID unik |
| **Fork Project** | Membuat aplikasi baru dari boilerplate |
| **White Label** | Membuat versi berbeda dari aplikasi yang sama |

### Keuntungan Menggunakan Tool Ini

| Fitur | Deskripsi |
|-------|-----------|
| **Otomatis** | Semua file diubah dengan satu command |
| **Validasi** | Format Application ID divalidasi sebelum perubahan |
| **Cross-Platform** | Android dan iOS diubah bersamaan |
| **Dokumentasi** | File dokumentasi juga terupdate |
| **Cleanup** | Folder lama dihapus otomatis |

---

## Quick Start

### Command Format

```bash
dart run tool/change_app_id.dart <new_app_id>
```

### Contoh Penggunaan

```bash
# Ubah ke com.example.myapp
dart run tool/change_app_id.dart com.example.myapp

# Ubah ke com.company.project
dart run tool/change_app_id.dart com.company.project

# Ubah ke org.company.appname
dart run tool/change_app_id.dart org.company.appname
```

### Output yang Diharapkan

```
╔══════════════════════════════════════════════════════════════╗
║           🔧 CHANGE APPLICATION ID TOOL                      ║
╚══════════════════════════════════════════════════════════════╝

📁 Project directory: D:\project\super_app
🆔 New Application ID: com.example.myapp

📌 Current Application ID: id.carik.superapp_demo

═══════════════════════════════════════════════════════════════
🔄 Memulai proses perubahan...
═══════════════════════════════════════════════════════════════

✅ [OK] android/app/build.gradle.kts
✅ [OK] android/app/src/main/kotlin/com/example/myapp/MainActivity.kt (created)
🗑️  [DEL] android/app/src/main/kotlin/id/carik/ (deleted)
✅ [OK] ios/Runner.xcodeproj/project.pbxproj
✅ [OK] README.md
✅ [OK] docs/SuperApp-Architecture.md
✅ [OK] docs/Notification.md

═══════════════════════════════════════════════════════════════
✅ Application ID berhasil diubah!
   Dari: id.carik.superapp_demo
   Ke:   com.example.myapp

📊 Total file yang diubah: 6
═══════════════════════════════════════════════════════════════

📋 Langkah selanjutnya:
   1. Jalankan: flutter clean
   2. Jalankan: flutter pub get
   3. Jika menggunakan Firebase, update google-services.json
   4. Jika menggunakan Google Sign-In, update SHA-1 di Google Cloud Console
```

---

## What Gets Changed

Tool ini mengubah file-file berikut:

### Android Files

| File | Perubahan |
|------|-----------|
| `android/app/build.gradle.kts` | `namespace` dan `applicationId` |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Package declaration dan file location |

### iOS Files

| File | Perubahan |
|------|-----------|
| `ios/Runner.xcodeproj/project.pbxproj` | `PRODUCT_BUNDLE_IDENTIFIER` (semua build configuration) |

### Documentation Files

| File | Perubahan |
|------|-----------|
| `README.md` | Org/Package reference |
| `docs/SuperApp-Architecture.md` | Package reference |
| `docs/Notification.md` | Package reference |
| `docs/Auth.md` | Package reference (jika ada) |
| `docs/API.md` | Package reference (jika ada) |

---

## Application ID Format

### Format yang Valid

Application ID harus mengikuti aturan berikut:

| Rule | Contoh Valid | Contoh Invalid |
|------|--------------|----------------|
| Minimal 2 segmen | `com.app` | `myapp` |
| Dipisahkan titik | `com.example.app` | `com-example-app` |
| Dimulai dengan huruf | `com.example.myapp` | `123.app.name` |
| Boleh underscore | `com.my_app` | `com.my-app` |
| Huruf, angka, underscore | `com.app123` | `com.app@name` |

### Contoh Application ID

```
# Format Umum
com.companyname.appname
id.companyname.appname
org.organization.appname

# Contoh Spesifik
com.example.myapp
com.example.myflutterapp
org.openstreetmap.osmand
id.co.tokopedia.tkpd
```

### Naming Convention

| Platform | Convention | Contoh |
|----------|------------|--------|
| Android | Lowercase, underscore | `com.example.my_app` |
| iOS | Lowercase | `com.example.myapp` |
| **Recommended** | Lowercase, no underscore | `com.example.myapp` |

---

## Usage Examples

### Basic Usage

```bash
# Cek current app ID (tidak ada perubahan)
dart run tool/change_app_id.dart

# Output error dengan instruksi penggunaan
```

### Change to New ID

```bash
# Dari id.carik.superapp_demo ke com.example.myapp
dart run tool/change_app_id.dart com.example.myapp
```

### Error Handling

```bash
# Invalid format - missing segment
dart run tool/change_app_id.dart myapp
# ❌ Error: Format Application ID tidak valid!

# Invalid format - starts with number
dart run tool/change_app_id.dart 123.app.name
# ❌ Error: Format Application ID tidak valid!

# Same as current
dart run tool/change_app_id.dart com.example.myapp
# ℹ️ Application ID sudah "com.example.myapp". Tidak ada perubahan.
```

---

## Post-Change Steps

Setelah menjalankan tool, lakukan langkah-langkah berikut:

### 1. Clean & Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

### 2. Update Firebase

> ⚠️ **WAJIB** jika menggunakan Firebase (FCM, Auth, Firestore, dll)

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project Anda
3. Klik ⚙️ **Settings** → **Project settings**
4. Scroll ke **Your apps**

#### Android:
1. Klik **Add app** → **Android**
2. Masukkan:
   - **Package name**: `com.example.myapp` (sesuai app ID baru)
   - **App nickname**: (opsional)
   - **Debug signing certificate SHA-1**: (lihat cara mendapatkan di bawah)
3. Klik **Register app**
4. Download **`google-services.json`**
5. Ganti file di `android/app/google-services.json`

#### iOS:
1. Klik **Add app** → **iOS**
2. Masukkan:
   - **Bundle ID**: `com.example.myapp` (sesuai app ID baru)
3. Download **`GoogleService-Info.plist`**
4. Ganti file di `ios/Runner/GoogleService-Info.plist`

### 3. Update Google Sign-In (OAuth)

> ⚠️ **WAJIB** jika menggunakan Google Sign-In

#### Langkah 1: Dapatkan SHA-1 Fingerprint

Jalankan command ini di terminal:

```bash
cd android
call gradlew.bat signingReport
```

Cari bagian **debug** dan catat nilai **SHA1**:

```
> Task :app:signingReport
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
MD5:  XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX  ← COPY INI
SHA-256: ...
```

#### Langkah 2: Update Firebase Console

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project Anda
3. Klik ⚙️ Settings → Project settings
4. Scroll ke **Your apps** → Android app
5. Di bagian **SHA certificate fingerprints**, klik **Add fingerprint**
6. Paste SHA-1 dari langkah 1
7. Download **`google-services.json`** baru
8. Ganti file di `android/app/google-services.json`

#### Langkah 3: Update Google Cloud Console

1. Buka [Google Cloud Console](https://console.cloud.google.com)
2. Pilih project yang sama dengan Firebase
3. Navigasi ke **APIs & Services → Credentials**
4. Di bagian **OAuth 2.0 Client IDs**, cari yang bertipe **Android**
5. Jika belum ada untuk package baru, klik **+ CREATE CREDENTIALS → OAuth client ID**
6. Pilih **Android**
7. Isi:
   - **Package name**: `com.example.myapp`
   - **SHA-1 certificate fingerprint**: (paste SHA-1 dari langkah 1)
8. Klik **Create**

#### Langkah 4: Rebuild Aplikasi

```bash
flutter clean
flutter pub get
flutter run
```

---

## Fix Google Sign-In Error After App ID Change

### Error Message

Jika Anda melihat error seperti ini setelah mengubah Application ID:

```
I/PlayServicesImpl: No cancellationSignal found
GoogleSignInException(code GoogleSignInExceptionCode.canceled, activity is cancelled by the user., null)
```

### Penyebab

Error ini terjadi karena **Google Sign-In terikat dengan package name** yang didaftarkan di Google Cloud Console. Setelah mengubah Application ID, OAuth client tidak mengenali package name baru.

### Solusi Step-by-Step

#### Step 1: Dapatkan SHA-1 Fingerprint

```bash
cd android
call gradlew.bat signingReport
```

Output:
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
```

**Catat nilai SHA1 tersebut!**

#### Step 2: Update Firebase Console

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project → ⚙️ Settings → Project settings
3. Di **Your apps**, klik **Add app** → **Android**
4. Masukkan:
   | Field | Value |
   |-------|-------|
   | Package name | `com.example.myapp` |
   | SHA-1 certificate | (paste SHA-1 dari step 1) |
5. Download `google-services.json`
6. **Ganti** file di `android/app/google-services.json`

#### Step 3: Update Google Cloud Console

1. Buka [Google Cloud Console](https://console.cloud.google.com)
2. Pilih project yang sama dengan Firebase
3. **APIs & Services → Credentials**
4. Di **OAuth 2.0 Client IDs**:
   - Jika sudah ada Android client untuk package lama → Edit dan update package name
   - Jika belum ada → Create baru dengan:
     | Field | Value |
     |-------|-------|
     | Application type | Android |
     | Package name | `com.example.myapp` |
     | SHA-1 fingerprint | (paste dari step 1) |

#### Step 4: Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

### Checklist Troubleshooting

| ✅ | Item | Keterangan |
|----|------|------------|
| ☐ | Package name di Firebase Console | Harus `com.example.myapp` |
| ☐ | SHA-1 di Firebase Console | Harus sesuai dengan debug keystore |
| ☐ | google-services.json diupdate | File baru setelah add app |
| ☐ | OAuth Client di Google Cloud | Package name dan SHA-1 harus match |
| ☐ | flutter clean | Wajib setelah update google-services.json |

### Catatan Penting

| Item | Keterangan |
|------|------------|
| **Debug vs Release** | SHA-1 untuk debug dan release **berbeda**. Untuk development, gunakan debug SHA-1. Untuk production, tambahkan juga release SHA-1. |
| **Waktu Propagasi** | Perubahan di Google Cloud Console mungkin butuh **beberapa menit** untuk aktif |
| **Web Client ID** | Tidak perlu diubah, tetap gunakan Web Client ID yang sama |

---

## Manual Change Guide

Jika Anda ingin mengubah Application ID secara manual:

### Android

#### 1. Edit `android/app/build.gradle.kts`

```kotlin
android {
    namespace = "com.example.myapp"  // Change this
    
    defaultConfig {
        applicationId = "com.example.myapp"  // Change this
        // ...
    }
}
```

#### 2. Pindahkan MainActivity.kt

```bash
# Old location
android/app/src/main/kotlin/id/carik/superapp_demo/MainActivity.kt

# New location
android/app/src/main/kotlin/com/example/myapp/MainActivity.kt
```

#### 3. Update Package Declaration

```kotlin
// File: android/app/src/main/kotlin/com/example/myapp/MainActivity.kt
package com.example.myapp

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

### iOS

#### Edit `ios/Runner.xcodeproj/project.pbxproj`

Cari dan ganti semua occurrence dari:
- `PRODUCT_BUNDLE_IDENTIFIER = old.app.id;`

Menjadi:
- `PRODUCT_BUNDLE_IDENTIFIER = com.example.myapp;`

Or buka di Xcode:
1. Buka `ios/Runner.xcworkspace`
2. Select Runner → Signing & Capabilities
3. Update Bundle Identifier

---

## Troubleshooting

### Script tidak jalan

```bash
# Error: Dart not found
# Solusi: Pastikan Dart/Flutter ada di PATH

flutter doctor
```

### File tidak ditemukan

```bash
# Error: File build.gradle.kts tidak ditemukan
# Solusi: Jalankan dari root project directory

cd path/to/super_app
dart run tool/change_app_id.dart com.example.myapp
```

### Build Error setelah perubahan

```bash
# Error: package not found
# Solusi: Clean dan rebuild

flutter clean
flutter pub get
flutter run
```

### Gradle Sync Failed (Android Studio)

1. File → Invalidate Caches / Restart
2. Build → Clean Project
3. Build → Rebuild Project

### iOS Build Error

```bash
# Clean iOS build
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter run
```

### Google Sign-In Error: "activity is cancelled by the user"

Lihat bagian [Fix Google Sign-In Error After App ID Change](#fix-google-sign-in-error-after-app-id-change).

### Sign-In Masih Gagal Setelah Update

1. Pastikan SHA-1 benar (bukan SHA-256)
2. Tunggu beberapa menit untuk propagasi
3. Coba uninstall app dari device dan install ulang
4. Pastikan google-services.json sudah yang terbaru

---

## Script Source

Script tersedia di: `tool/change_app_id.dart`

### Key Functions

| Function | Description |
|----------|-------------|
| `_isValidAppId()` | Validasi format Application ID |
| `_detectCurrentAppId()` | Deteksi app ID saat ini dari build.gradle.kts |
| `_updateBuildGradleKts()` | Update namespace dan applicationId |
| `_updateMainActivity()` | Buat MainActivity.kt baru dan hapus yang lama |
| `_updateIosProjectPbxproj()` | Update bundle identifier di Xcode project |
| `_updateDocumentation()` | Update referensi di file dokumentasi |

---

## See Also

- **[README.md](../README.md)** - Main project documentation
- **[SuperApp-Architecture.md](./SuperApp-Architecture.md)** - Architecture overview
- **[Auth.md](./Auth.md)** - Authentication documentation
- [Android App ID Guide](https://developer.android.com/studio/build/application-id)
- [iOS Bundle ID Guide](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleidentifier)
- [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
- [Google Sign-In Setup](https://pub.dev/packages/google_sign_in)

---

*Updated: January 10, 2026*
*Version: 1.1.0*
