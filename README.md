# Super App Boilerplate

## Deskripsi
Super App Boilerplate

Super App adalah aplikasi mobile (Android & iOS) yang dibangun dengan arsitektur Clean Architecture, menggunakan Material 3, dan mendukung multi-bahasa serta multi-template.

**Org:** id.carik.superapp

---

## 📁 Struktur Folder (Clean Architecture)

```
lib/
├── core/                           # Inti aplikasi
│   ├── auth/
│   │   ├── auth_interface.dart     # BaseAuthService (Abstract Class)
│   │   ├── firebase_provider.dart  # Implementasi Firebase Auth
│   │   └── custom_api_provider.dart # Implementasi Custom API Auth
│   ├── config/
│   │   └── app_config.dart         # Riverpod providers & config
│   ├── constants/
│   │   └── assets.dart             # Path assets
│   ├── routes/
│   │   └── app_router.dart         # GoRouter navigation
│   └── theme/
│       └── app_theme.dart          # Material 3 themes & templates
├── features/                       # Modul fitur
│   ├── auth/
│   │   ├── login_screen.dart       # Login dengan Email/Google
│   │   └── register_screen.dart    # Registrasi
│   ├── dashboard/
│   │   ├── main_dashboard.dart     # Halaman utama
│   │   └── widgets/
│   │       ├── banner_carousel.dart # Top banner (carousel)
│   │       ├── menu_grid.dart       # Grid ikon modul
│   │       └── article_list.dart    # Section artikel
│   ├── profile/
│   │   └── profile_screen.dart     # Detail profil
│   ├── settings/
│   │   └── setting_screen.dart     # Pengaturan bahasa & template
│   └── splash/
│       └── splash_screen.dart      # Splash screen full screen
├── shared/                         # Komponen global
│   ├── info/
│   │   ├── help_screen.dart        # Help & Report
│   │   ├── tos_screen.dart         # Terms of Service
│   │   └── privacy_screen.dart     # Privacy Policy
│   └── widgets/
│       ├── custom_header.dart      # Header dinamis (AppBar/SliverAppBar)
│       ├── custom_footer.dart      # Footer NavigationBar + center FAB
│       └── custom_sidebar.dart     # NavigationDrawer Material 3
└── main.dart                       # Entry point dengan Riverpod
```

---

## ✨ Fitur yang Diimplementasi

| Fitur | Status | Deskripsi |
|-------|--------|-----------|
| **Material 3** | ✅ | `useMaterial3: true` dengan ColorScheme.fromSeed |
| **Auth Abstraction** | ✅ | `BaseAuthService` + Firebase & Custom API providers |
| **Multi-Template** | ✅ | 6 tema: Blue, Purple, Green, Orange, Brown, Dark Mode |
| **Multi-Bahasa** | ✅ | Locale ID & EN dengan flutter_localizations |
| **Sidebar Configurable** | ✅ | Posisi kiri/kanan dapat dikonfigurasi |
| **Footer dengan FAB** | ✅ | 5 tombol dengan center button dominan |
| **Splash Screen** | ✅ | Full screen dengan animasi |
| **Dashboard** | ✅ | Banner Carousel + Menu Grid + Articles |
| **State Management** | ✅ | Flutter Riverpod |
| **Routing** | ✅ | GoRouter |
| **Edge-to-Edge** | ✅ | SystemUiMode.edgeToEdge |
| **Network Layer** | ✅ | Dio + Retrofit dengan Repository Pattern (lihat [docs/API.md](docs/API.md)) |
| **Push Notification** | ✅ | Multi-provider (FCM, OneSignal, Mock) dengan abstraction layer (lihat [docs/Notification.md](docs/Notification.md)) |

---

## 🛠️ Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.6.1      # State Management
  go_router: ^14.6.3            # Navigation
  google_fonts: ^6.2.1          # Typography
  carousel_slider: ^5.0.0       # Banner carousel
  cached_network_image: ^3.4.1  # Image caching
  flutter_localizations         # i18n support
  intl: ^0.20.2                 # Localization utilities
  shared_preferences: ^2.3.4    # Local storage
  cupertino_icons: ^1.0.8       # Icons
  dio: ^5.4.0                   # HTTP Client
  retrofit: ^4.1.0              # Type-safe API
  json_annotation: ^4.8.1       # JSON serialization
  connectivity_plus: ^6.1.1     # Network connectivity
  permission_handler: ^11.3.1   # Permission management
  image_picker: ^1.0.7          # Camera & Gallery
  geolocator: ^13.0.2           # GPS & Location
  firebase_core: ^3.8.1         # Firebase Core
  firebase_messaging: ^15.2.1   # Push Notifications (FCM)
  flutter_local_notifications: ^18.0.1  # Local notifications
  onesignal_flutter: ^5.2.7     # Push Notifications (OneSignal)
```

---

## 🔐 Permissions

Aplikasi ini membutuhkan beberapa permission untuk berfungsi dengan baik:

### Android Permissions (AndroidManifest.xml)

| Permission | Kategori | Deskripsi |
|------------|----------|-----------|
| `READ_EXTERNAL_STORAGE` | Storage | Membaca file dari penyimpanan |
| `WRITE_EXTERNAL_STORAGE` | Storage | Menulis file ke penyimpanan |
| `MANAGE_EXTERNAL_STORAGE` | Storage | Akses penuh storage (Android 11+) |
| `CAMERA` | Kamera | Mengambil foto menggunakan kamera |
| `READ_MEDIA_IMAGES` | Gallery | Akses gambar dari gallery (Android 13+) |
| `ACCESS_FINE_LOCATION` | GPS | Lokasi presisi tinggi (GPS) |
| `ACCESS_COARSE_LOCATION` | GPS | Lokasi perkiraan (Network) |

📚 **Panduan penggunaan Permission Helper:** [`docs/Permission Helper.md`](docs/Permission%20Helper.md)

---

## 📡 Network Layer (Dio + Retrofit)

Network layer yang reusable dengan **Repository Pattern**, menggunakan **Dio** dan **Retrofit**.

### Struktur

```
lib/core/network/
├── api_config.dart              # Konfigurasi base URL & environment
├── api_client.dart              # Dio instance terpusat + providers
├── network.dart                 # Barrel export
├── exceptions/
│   └── api_exception.dart       # Unified exception handling
├── interceptors/
│   ├── auth_interceptor.dart    # Auto token injection & refresh
│   ├── logging_interceptor.dart # Request/response logging
│   └── error_interceptor.dart   # Error handling & retry
├── models/
│   ├── base_request.dart        # Shared request fields
│   └── base_response.dart       # Standardized response wrapper
├── repository/
│   ├── base_repository.dart     # Base repository (GET, POST, PUT, DELETE)
│   └── user_repository.dart     # Contoh implementasi
└── services/
    └── api_service.dart         # Retrofit API definitions
```

### ✨ Fitur Unggulan

| Fitur | Deskripsi |
|-------|-----------|
| **Auto Auth Headers** | Token `Authorization: Bearer` ditambahkan otomatis |
| **Token Refresh** | Otomatis refresh token saat 401 |
| **Common Headers** | `X-Request-ID`, `X-Timestamp`, `X-Platform` selalu ditambahkan |
| **Retry Logic** | Auto-retry untuk timeout dan error 5xx dengan exponential backoff |
| **Unified Error** | Semua error dikonversi ke `ApiException` |
| **Structured Logging** | Log request/response di debug mode |
| **BaseRequest** | Field shared (deviceId, timestamp, locale) untuk semua request |
| **BaseResponse** | Wrapper standar dengan support pagination |

### 🚫 Anti-Pattern yang Dihindari

Arsitektur network layer ini dirancang untuk menghindari anti-pattern umum:

| ❌ Anti-Pattern | ✅ Solusi yang Diterapkan |
|-----------------|---------------------------|
| **Passing headers manual di setiap API call** | Interceptors otomatis menambahkan semua headers (Auth, Content-Type, dsb) |
| **UI/Screen Inheritance** | Tidak ada inheritance di layer UI; network layer terpisah sepenuhnya |
| **Duplikasi error handling** | `ApiException` + `ErrorInterceptor` menangani semua error secara terpusat |
| **Hardcoded base URL** | `ApiConfig` + `EnvironmentConfig` untuk konfigurasi per-environment |
| **Token management tersebar** | `TokenStorage` abstraction dengan satu source of truth |
| **Refactoring existing screens** | Layer network 100% additive, tidak mengubah UI existing |
| **Membuat Dio instance baru** | Singleton `ApiClient` via Riverpod provider |
| **Request boilerplate berulang** | `BaseRepository` menyediakan method standar (get, post, put, delete) |

### 📖 Quick Example

```dart
// 1. Import
import 'package:super_app/core/network/network.dart';

// 2. Buat repository
class ProductRepository extends BaseRepository {
  ProductRepository({required super.apiClient});

  Future<BaseResponse<Product>> getProduct(String id) async {
    return get<Product>('/products/$id', parser: Product.fromJson);
  }
}

// 3. Registrasi provider
final productRepoProvider = Provider((ref) =>
  ProductRepository(apiClient: ref.watch(apiClientProvider))
);

// 4. Gunakan di widget - TANPA passing headers manual!
final response = await ref.read(productRepoProvider).getProduct('123');
if (response.success) {
  print(response.data);
}
```

📚 **Dokumentasi lengkap:** [`docs/API.md`](docs/API.md)

## 🔔 Push Notification (Multi-Provider)

Push notification layer yang reusable dengan **Multi-Provider Abstraction**, memungkinkan pergantian provider tanpa mengubah kode UI.

### ✨ Keunggulan

| Fitur | Deskripsi |
|-------|-----------|
| **Clean Separation** | Tidak ada `if (isFcm)` logic di UI layer |
| **1-Line Switch** | Ganti provider cukup ubah 1 baris di `app_info.dart` |
| **A/B Testing Ready** | Bisa dikontrol via remote config |
| **Testable** | `MockNotificationService` untuk unit testing |
| **Clean Architecture** | Konsisten dengan arsitektur aplikasi |

### ⚡ Quick Configuration

Semua konfigurasi ada di `lib/core/constants/app_info.dart`:

```dart
// Enable/disable notification
static const bool enableNotification = true;

// Pilih provider: 'firebase', 'onesignal', atau 'mock'
static const String notificationProvider = 'firebase';
```

### Provider yang Tersedia

| Value | Provider | Keterangan |
|-------|----------|------------|
| `firebase` / `fcm` | Firebase Cloud Messaging | Default, dari Google |
| `onesignal` | OneSignal | Alternatif populer |
| `mock` / `test` | Mock Service | Untuk testing |

📚 **Dokumentasi lengkap:** [`docs/Notification.md`](docs/Notification.md)

## 📱 Screen List

### Authentication
- **Splash Screen** - Full screen dengan logo dan animasi loading
- **Login Screen** - Login dengan Email/Password dan Google OAuth
- **Register Screen** - Registrasi dengan form dan Terms Agreement

### Main App
- **Main Dashboard** - Komponen: Header, Banner Carousel, Menu Grid, Article List, Footer
- **Profile Screen** - Detail profil user dengan quick actions
- **Settings Screen** - Pengaturan bahasa, template, sidebar position, auth strategy

### Info Pages
- **Help Screen** - FAQ dan contact support
- **Terms of Service** - Halaman TOS
- **Privacy Policy** - Halaman privacy policy

---

## 🔧 Configuration (app_config.dart)

File `lib/core/config/app_config.dart` mengontrol:

1. **authStrategy**: `AuthStrategy.firebase` | `AuthStrategy.customApi`
2. **sidebarPosition**: `SidebarPosition.left` | `SidebarPosition.right`
3. **currentTemplate**: `AppTemplate.defaultBlue` | `modernPurple` | `elegantGreen` | `warmOrange` | `sweetBrown` | `darkMode`
4. **selectedLocale**: `Locale('id', 'ID')` | `Locale('en', 'US')`
5. **isDarkMode**: `true` | `false`

---

## 🎨 Theme Templates

| Template | Seed Color | Deskripsi |
|----------|------------|-----------|
| Default Blue | `#1565C0` | Tema biru profesional |
| Modern Purple | `#7B1FA2` | Tema ungu modern |
| Elegant Green | `#2E7D32` | Tema hijau elegan |
| Warm Orange | `#E65100` | Tema oranye hangat |
| Sweet Brown | `#8D6E63` | Tema coklat manis |
| Dark Mode | `#6750A4` | Mode gelap |

---

## 🚀 Cara Menjalankan

```bash
# Install dependencies
flutter pub get

# Jalankan di debug mode
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

---

## � Menjalankan di Android Emulator

### Langkah 1: Cek Emulator yang Tersedia
```bash
flutter emulators
```

### Langkah 2: Jalankan Emulator
```bash
# Ganti <emulator_id> dengan ID emulator yang tersedia
flutter emulators --launch <emulator_id>

# Contoh:
flutter emulators --launch Medium_Phone_API_36.0
```

### Langkah 3: Tunggu Emulator Booting
Tunggu sampai emulator Android selesai booting dan menampilkan home screen.

### Langkah 4: Cek Device Terdeteksi
```bash
flutter devices
```

### Langkah 5: Jalankan Aplikasi
```bash
# Jalankan di device yang terdeteksi
flutter run

# Atau spesifik ke device ID
flutter run -d emulator-5554
```

### Keyboard Shortcuts saat Running
| Key | Action |
|-----|--------|
| `r` | Hot Reload |
| `R` | Hot Restart |
| `q` | Quit |
| `h` | Help |

---

## �📝 File Penting

- `lib/main.dart` - Entry point aplikasi
- `lib/core/config/app_config.dart` - Konfigurasi & Riverpod providers
- `lib/core/auth/auth_interface.dart` - Abstract class untuk Auth
- `lib/core/theme/app_theme.dart` - Material 3 theme configuration
- `lib/core/routes/app_router.dart` - Routing dengan GoRouter
- `lib/core/network/network.dart` - Network layer barrel export
- `lib/core/network/api_client.dart` - Dio client dengan interceptors
- `lib/core/network/repository/base_repository.dart` - Base repository pattern
- `lib/features/dashboard/main_dashboard.dart` - Halaman utama

---

## 📋 TODO (Pengembangan Lanjut)

- [x] Implementasi Google Sign-In (tambah google_sign_in)
- [x] Tambahkan localization strings untuk multi-bahasa (lihat `docs/LOCALIZATION.md`)
- [x] Network Layer dengan Dio + Retrofit (lihat `docs/API.md`)
- [x] Implementasi persistent storage untuk settings (menggunakan SharedPreferences)
- [ ] Tambahkan unit tests dan widget tests
- [x] Implementasi push notifications (lihat `docs/Notification.md`)
- [ ] Implementai remote config
- [ ] Implementasi Firebase Auth (tambah firebase_core, firebase_auth)
- [ ] Tambahkan analytics

---

## 📅 Tanggal Dibuat
04 Mei 2025

## 👨‍💻 Generated by
[CARIK AI Assistant](https://carik.id)
