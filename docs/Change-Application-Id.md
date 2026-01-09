# Change Application ID

Tool untuk mengubah Application ID (Package Name / Bundle Identifier) di seluruh project Flutter secara otomatis.

> **📚 Related Documents:**
> - **[README.md](../README.md)** - Main project documentation
> - **[SuperApp-Architecture.md](./SuperApp-Architecture.md)** - Architecture overview

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [What Gets Changed](#what-gets-changed)
- [Application ID Format](#application-id-format)
- [Usage Examples](#usage-examples)
- [Post-Change Steps](#post-change-steps)
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
# Ubah ke id.ihasa.app
dart run tool/change_app_id.dart id.ihasa.app

# Ubah ke com.example.myapp
dart run tool/change_app_id.dart com.example.myapp

# Ubah ke org.company.appname
dart run tool/change_app_id.dart org.company.appname
```

### Output yang Diharapkan

```
╔══════════════════════════════════════════════════════════════╗
║           🔧 CHANGE APPLICATION ID TOOL                      ║
╚══════════════════════════════════════════════════════════════╝

📁 Project directory: D:\project\super_app
🆔 New Application ID: id.ihasa.app

📌 Current Application ID: id.carik.superapp_demo

═══════════════════════════════════════════════════════════════
🔄 Memulai proses perubahan...
═══════════════════════════════════════════════════════════════

✅ [OK] android/app/build.gradle.kts
✅ [OK] android/app/src/main/kotlin/id/ihasa/app/MainActivity.kt (created)
🗑️  [DEL] android/app/src/main/kotlin/id/carik/ (deleted)
✅ [OK] ios/Runner.xcodeproj/project.pbxproj
✅ [OK] README.md
✅ [OK] docs/SuperApp-Architecture.md
✅ [OK] docs/Notification.md

═══════════════════════════════════════════════════════════════
✅ Application ID berhasil diubah!
   Dari: id.carik.superapp_demo
   Ke:   id.ihasa.app

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
| Dimulai dengan huruf | `id.ihasa.app` | `123.app.name` |
| Boleh underscore | `com.my_app` | `com.my-app` |
| Huruf, angka, underscore | `com.app123` | `com.app@name` |

### Contoh Application ID

```
# Format Umum
com.companyname.appname
id.companyname.appname
org.organization.appname

# Contoh Spesifik
id.ihasa.app
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
# Dari id.carik.superapp_demo ke id.ihasa.app
dart run tool/change_app_id.dart id.ihasa.app
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
dart run tool/change_app_id.dart id.ihasa.app
# ℹ️ Application ID sudah "id.ihasa.app". Tidak ada perubahan.
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

### 2. Update Firebase (Jika Menggunakan)

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project Anda
3. **Android:**
   - Settings → Add app → Android
   - Masukkan package name baru
   - Download `google-services.json` baru
   - Ganti file di `android/app/google-services.json`
4. **iOS:**
   - Settings → Add app → iOS
   - Masukkan bundle ID baru
   - Download `GoogleService-Info.plist` baru
   - Ganti file di `ios/Runner/GoogleService-Info.plist`

### 3. Update Google Sign-In (Jika Menggunakan)

1. Buka [Google Cloud Console](https://console.cloud.google.com)
2. Pilih project Anda
3. APIs & Services → Credentials
4. Update OAuth 2.0 Client IDs dengan package name baru
5. Tambahkan SHA-1 fingerprint untuk package baru:

```bash
# Debug SHA-1
cd android
./gradlew signingReport
```

### 4. Update Play Store & App Store (Jika Sudah Published)

> ⚠️ **PENTING**: Application ID **TIDAK BISA DIUBAH** setelah app dipublish ke store. Jika perlu mengubah, Anda harus membuat app baru.

---

## Manual Change Guide

Jika Anda ingin mengubah Application ID secara manual:

### Android

#### 1. Edit `android/app/build.gradle.kts`

```kotlin
android {
    namespace = "id.ihasa.app"  // Change this
    
    defaultConfig {
        applicationId = "id.ihasa.app"  // Change this
        // ...
    }
}
```

#### 2. Pindahkan MainActivity.kt

```bash
# Old location
android/app/src/main/kotlin/id/carik/superapp_demo/MainActivity.kt

# New location
android/app/src/main/kotlin/id/ihasa/app/MainActivity.kt
```

#### 3. Update Package Declaration

```kotlin
// File: android/app/src/main/kotlin/id/ihasa/app/MainActivity.kt
package id.ihasa.app

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

### iOS

#### Edit `ios/Runner.xcodeproj/project.pbxproj`

Cari dan ganti semua occurrence dari:
- `PRODUCT_BUNDLE_IDENTIFIER = old.app.id;`

Menjadi:
- `PRODUCT_BUNDLE_IDENTIFIER = id.ihasa.app;`

Atau buka di Xcode:
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
dart run tool/change_app_id.dart id.ihasa.app
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

### Sign-In Tidak Berfungsi

Jika Google Sign-In error setelah perubahan:
1. Pastikan SHA-1 didaftarkan di Firebase Console
2. Pastikan OAuth Client ID terupdate di Google Cloud Console
3. Download ulang `google-services.json`

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
- [Android App ID Guide](https://developer.android.com/studio/build/application-id)
- [iOS Bundle ID Guide](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleidentifier)

---

*Updated: January 10, 2026*
*Version: 1.0.0*
