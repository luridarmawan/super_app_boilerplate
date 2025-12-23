
# Master Prompt: Flutter Super App Development (Material 3 Edition)

## Role
Bertindaklah sebagai **Senior Flutter Architect** dan **Lead UI/UX Engineer** dengan keahlian dalam Clean Architecture dan sistem modular.

## Objective
Bangun struktur proyek Flutter untuk aplikasi mobile "Super App" yang mendukung multi-bahasa, multi-template, dan arsitektur backend-agnostic (pilihan Auth Provider) menggunakan standar desain **Material 3**.

---

## 1. Technical Stack & Architecture
* **Framework:** Flutter (Android & iOS) dengan dukungan layar full screen (edge-to-edge).
* **UI Style:** Gunakan **Material 3** secara konsisten di seluruh aplikasi (useMaterial3: true).
* **State Management:** Riverpod atau Provider untuk menangani perubahan tema, bahasa, dan auth state secara global.
* **Auth Abstraction (Core):**
    * Implementasikan `BaseAuthService` sebagai abstract class.
    * Aplikasi harus switchable melalui konfigurasi antara **Firebase Auth** atau **Custom API Auth**.
    * Mendukung Login/Registrasi via Email dan Google Auth (OAuth).

---

## 2. Feature Specifications

### Navigation & Layout (Material 3 Adaptive)
* **Header:** Dinamis menggunakan `SliverAppBar` atau `AppBar` Material 3. Menampilkan Logo & Nama di Dashboard, atau Judul Modul di halaman lain. Memiliki Icon Notifikasi.
* **Sidebar:** Material 3 `NavigationDrawer`. Menampilkan foto profil, nama, link View Profile, dan Activity List. Posisi (Kiri atau Kanan) harus dapat dikonfigurasi.
* **Footer:** Menggunakan `NavigationBar` Material 3 dengan 5 tombol menu. Tombol paling tengah harus dominan (Floating Action Button style untuk fitur Scan/Foto).
* **Floating Button:** 1 flying button tambahan (FAB) di sisi kanan bawah.

### Screens
* **Splash Screen:** Full screen dengan gambar utama yang bisa diatur dari URL atau lokal.
* **Main Dashboard:** Terdiri dari Top Banner (Carousel), Grid Ikon Modul (Material 3 Cards), dan Section Artikel.
* **Settings Screen:** Fitur ganti bahasa (ID & EN) dan ganti Template/Layout desain.
* **Others:** Profile, Help & Report, Term of Service, Privacy Policy, Rate App, dan App Version.

---

## 3. Configuration & Multi-Tenancy
Buat file `app_config.dart` yang mengontrol parameter berikut:
1.  `authStrategy`: (FIREBASE | CUSTOM_API).
2.  `sidebarPosition`: (LEFT | RIGHT).
3.  `currentTemplate`: Pengaturan tema/layout (mendukung Material 3 Color Schemes).
4.  `locale`: (ID | EN).

---

## 4. Expected Output Task
1.  Buat struktur folder berbasis **Clean Architecture** (core, features, shared).
2.  Tuliskan kode untuk `BaseAuthService` interface dan contoh implementasi salah satu provider.
3.  Berikan kode UI untuk `MainDashboard` yang menggunakan komponen **Material 3**, Header, Footer dominan, dan Sidebar sesuai spesifikasi.
4.  Pastikan `ThemeData` mendukung **Dynamic Color** atau skema warna Material 3 yang mudah diubah.

## Struktur Folder Proyek yang disarankan.

```
lib/
├── core/                        # Inti aplikasi (Shared, Config, Utils)
│   ├── config/
│   │   └── app_config.dart      # Pengaturan bahasa, template, & auth strategy
│   ├── auth/
│   │   ├── auth_interface.dart  # BaseAuthService (Abstract Class)
│   │   ├── firebase_provider.dart # Implementasi Firebase Auth
│   │   └── custom_api_provider.dart # Implementasi Custom API Auth
│   ├── constants/
│   │   └── assets.dart          # Path gambar lokal untuk Splash Screen
│   └── theme/
│       └── app_theme.dart       # Konfigurasi Material 3 & Multi-template
├── features/                    # Modul-modul fitur aplikasi
│   ├── splash/
│   │   └── splash_screen.dart   # Full screen splash dengan logo dinamis
│   ├── auth/
│   │   ├── login_screen.dart    # Login via Email/Auth
│   │   └── register_screen.dart # Registrasi via Email/Auth
│   ├── dashboard/
│   │   ├── widgets/
│   │   │   ├── banner_carousel.dart # Top banner dashboard
│   │   │   ├── menu_grid.dart       # Kumpulan ikon modul
│   │   │   └── article_list.dart    # Konten artikel
│   │   └── main_dashboard.dart      # Halaman utama
│   ├── profile/
│   │   └── profile_screen.dart  # Detail profil user
│   └── settings/
│       └── setting_screen.dart  # Pengaturan bahasa & template
├── shared/                      # Komponen global yang digunakan di banyak fitur
│   ├── widgets/
│   │   ├── custom_header.dart   # Header dinamis
│   │   ├── custom_footer.dart   # Footer 5 tombol (tengah dominan)
│   │   └── custom_sidebar.dart  # Sidebar NavigationDrawer
│   └── info/
│       ├── help_screen.dart     # Help & Report
│       ├── tos_screen.dart      # Term of Service
│       └── privacy_screen.dart  # Privacy Policy
└── main.dart                    # Entry point aplikasi
```

