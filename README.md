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
| **Multi-Template** | ✅ | 5 tema: Blue, Purple, Green, Orange, Dark Mode |
| **Multi-Bahasa** | ✅ | Locale ID & EN dengan flutter_localizations |
| **Sidebar Configurable** | ✅ | Posisi kiri/kanan dapat dikonfigurasi |
| **Footer dengan FAB** | ✅ | 5 tombol dengan center button dominan |
| **Splash Screen** | ✅ | Full screen dengan animasi |
| **Dashboard** | ✅ | Banner Carousel + Menu Grid + Articles |
| **State Management** | ✅ | Flutter Riverpod |
| **Routing** | ✅ | GoRouter |
| **Edge-to-Edge** | ✅ | SystemUiMode.edgeToEdge |

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
```

---

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
3. **currentTemplate**: `AppTemplate.defaultBlue` | `modernPurple` | `elegantGreen` | `warmOrange` | `darkMode`
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

## 📝 File Penting

- `lib/main.dart` - Entry point aplikasi
- `lib/core/config/app_config.dart` - Konfigurasi & Riverpod providers
- `lib/core/auth/auth_interface.dart` - Abstract class untuk Auth
- `lib/core/theme/app_theme.dart` - Material 3 theme configuration
- `lib/core/routes/app_router.dart` - Routing dengan GoRouter
- `lib/features/dashboard/main_dashboard.dart` - Halaman utama

---

## 📋 TODO (Pengembangan Lanjut)

- [ ] Implementasi Firebase Auth sebenarnya (tambah firebase_core, firebase_auth)
- [ ] Implementasi Google Sign-In (tambah google_sign_in)
- [ ] Tambahkan localization strings untuk multi-bahasa
- [ ] Implementasi persistent storage untuk settings
- [ ] Tambahkan unit tests dan widget tests
- [ ] Implementasi push notifications
- [ ] Tambahkan analytics

---

## 📅 Tanggal Dibuat
04 Mei 2025

## 👨‍💻 Generated by
CARIK AI Assistant
