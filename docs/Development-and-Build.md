# Development & Build Guide

Panduan lengkap untuk menyiapkan environment development dan build aplikasi.

---

## 📋 Persiapan File Konfigurasi

### 1️⃣ Copy File Konfigurasi

```bash
# Windows Command Prompt
copy .env.example .env
copy pubspec.yaml.example pubspec.yaml
copy modules.yaml.example modules.yaml
copy android\key.properties.example android\key.properties

# Linux / macOS
cp .env.example .env
cp pubspec.yaml.example pubspec.yaml
cp modules.yaml.example modules.yaml
cp android/key.properties.example android/key.properties
```

### 2️⃣ Konfigurasi Environment (.env)

Edit file `.env` dan sesuaikan nilai-nilai berikut:

| Konfigurasi | Deskripsi |
|-------------|-----------|
| `APP_NAME` | Nama aplikasi yang ditampilkan |
| `APP_TAGLINE` | Tagline/deskripsi singkat |
| `API_BASE_URL` | URL API production |
| `API_BASE_URL_DEVELOPMENT` | URL API development |
| `AUTH_LOGIN_URL` | Endpoint login API |
| `GOOGLE_CLIENT_ID` | Google OAuth Client ID (dari [Google Cloud Console](https://console.cloud.google.com/)) |
| `ONESIGNAL_APP_ID` | OneSignal App ID (jika menggunakan OneSignal) |
| `ENABLE_MODULE_ARROW_SENSE` | **Wajib `true`** — tanpa ini modul inti OSA tidak diregistrasi |
| `ARROW_SENSE_API_BASE_URL` | Base URL API Arrow Sense |
| `ARROW_SENSE_ENDPOINT_*` | Endpoint equipment, scoring, practice, mastery, horse, event, news |
| `BANNER_API_URL` | URL API untuk banner |
| `ARTICLE_API_URL` | URL API untuk artikel |
| `COMPANY_NAME` | Nama perusahaan |
| `TERMS_URL` | URL halaman Terms of Service |
| `PRIVACY_URL` | URL halaman Privacy Policy |
| `ENVIRONMENT` | `production` untuk memakai `API_BASE_URL`; nilai lain memakai `API_BASE_URL_DEVELOPMENT` |
| `THEME_DEFAULT` | Tema awal: `defaultBlue`, `modernPurple`, `elegantGreen`, `warmOrange`, `sweetBrown`, `darkMode` |

Seluruh variabel yang dikenali beserta nilai contohnya ada di `.env.example`.

### 3️⃣ Konfigurasi pubspec.yaml

Edit `pubspec.yaml` untuk menyesuaikan:

- **name**: Nama package aplikasi
- **description**: Deskripsi aplikasi
- **version**: Versi aplikasi (format: `major.minor.patch+buildNumber`)
- **External Modules**: Tambahkan modul eksternal yang diperlukan di bagian dependencies

```yaml
dependencies:
  # External Modules (dari modules/ folder)
  arrow_sense:
    path: modules/arrow_sense
  # Tambahkan modul lain sesuai kebutuhan
  # crm:
  #   path: modules/crm
```

### 4️⃣ Konfigurasi External Modules (modules.yaml)

Aplikasi ini menggunakan **arsitektur modular** yang memungkinkan Anda menambah atau menghapus fitur tanpa mengubah kode utama. File `modules.yaml` digunakan untuk mendefinisikan modul eksternal dari repository Git terpisah.

**Keuntungan arsitektur modular:**
- 🔌 **Plug & Play** - Tambah/hapus fitur dengan mudah
- 🔒 **Separation of Concerns** - Setiap modul self-contained
- 👥 **Team Collaboration** - Tim berbeda dapat mengerjakan modul berbeda
- 🔄 **Reusability** - Modul dapat digunakan ulang di proyek lain

Contoh konfigurasi `modules.yaml`:

```yaml
modules:
  - name: arrow_sense
    url: git@github.com:ihasa-id/archery_intelligence.git
    branch: development
    enabled: true
```

Kemudian jalankan untuk sync modul:

```bash
dart run tool/sync_modules.dart
```

📚 **Dokumentasi lengkap arsitektur modular:** [Modular.md](Modular.md)

### 5️⃣ Konfigurasi Keystore (key.properties)

Edit `android/key.properties` untuk release build:

```properties
# Release keystore (WAJIB diisi untuk production build)
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=app_release_key
storeFile=keystores/release.keystore
```

Generate release keystore:

```bash
dart run tool/generate_release_keystore.dart
```

---

## 📋 Checklist Persiapan Build

| # | Task | Required | File |
|---|------|----------|------|
| 1 | Copy dan edit `.env` | ✅ Wajib | `.env` |
| 2 | Copy dan edit `pubspec.yaml` | ✅ Wajib | `pubspec.yaml` |
| 3 | Copy dan edit `modules.yaml` | ✅ Wajib untuk OSA | `modules.yaml` |
| 4 | Copy dan edit `key.properties` | ⚡ Optional* | `android/key.properties` |
| 5 | Install dependencies | ✅ Wajib | - |

> \* `key.properties` wajib untuk release/production build, opsional untuk debug build.

---

## ✅ Verifikasi Persiapan

Setelah semua file dikonfigurasi, jalankan:

```bash
# Install dependencies
flutter pub get

# Verifikasi tidak ada error
flutter analyze

# Jalankan aplikasi (debug mode)
flutter run
```

---

## 🚀 Build Commands

### Debug Build

```bash
# Jalankan di emulator/device
flutter run

# Build APK debug
flutter build apk --debug
```

### Release Build

```bash
# Build APK release
flutter build apk --release

# Build App Bundle untuk Play Store
flutter build appbundle

# Build iOS
flutter build ios --release
```

### Lewat Makefile (disarankan)

```bash
make analyze   # flutter analyze
make apk       # clean + pub get + build APK arm64 dengan --analyze-size
make build     # clean + pub get + naikkan build number + build appbundle --release
```

> `make build` menjalankan `dart run tool/add_version.dart` lebih dulu, sehingga build
> number di `pubspec.yaml` ikut naik. Gunakan target ini untuk rilis ke Play Store.

---

## 📱 Menjalankan di Emulator

### Android Emulator

```bash
# Cek emulator yang tersedia
flutter emulators

# Jalankan emulator
flutter emulators --launch <emulator_id>

# Contoh:
flutter emulators --launch Medium_Phone_API_36.0

# Cek device terdeteksi
flutter devices

# Jalankan aplikasi
flutter run
```

### iOS Simulator (macOS only)

```bash
# Buka simulator
open -a Simulator

# Jalankan aplikasi
flutter run
```

---

## ⌨️ Keyboard Shortcuts

Saat aplikasi berjalan di debug mode:

| Key | Action |
|-----|--------|
| `r` | Hot Reload |
| `R` | Hot Restart |
| `q` | Quit |
| `h` | Help |

---

## 🔧 Troubleshooting

### Error: "pubspec.yaml not found"

Pastikan Anda sudah meng-copy file:
```bash
copy pubspec.yaml.example pubspec.yaml
```

### Error: ".env file not found"

Pastikan Anda sudah meng-copy file:
```bash
copy .env.example .env
```

### Error: "Keystore file not found"

Untuk debug build, ini bisa diabaikan. Untuk release build:
```bash
copy android\key.properties.example android\key.properties
dart run tool/generate_release_keystore.dart
```

### Error: "Module not found"

Sync external modules:
```bash
dart run tool/sync_modules.dart
```

---

## 📚 Dokumentasi Terkait

- [Release.md](Release.md) - Panduan release & keystore
- [SubModule.md](SubModule.md) - External modules integration
- [API.md](API.md) - Network layer configuration
