# Splash Screen 

Dokumentasi lengkap untuk konfigurasi dan penggunaan Splash Screen.

> **📚 Dokumen Terkait:**
> - **[README.md](../README.md)** - Dokumentasi utama project

---

## Daftar Isi

1. [Pendahuluan](#pendahuluan)
2. [Fitur Utama](#fitur-utama)
3. [Konfigurasi .env](#konfigurasi-env)
4. [Kustomisasi Visual](#kustomisasi-visual)
5. [Flow Logic](#flow-logic)
6. [Technical Implementation](#technical-implementation)
7. [Troubleshooting](#troubleshooting)

---

## Pendahuluan

Splash Screen adalah layar pembuka yang ditampilkan saat aplikasi pertama kali dibuka. Super App Boilerplate menyediakan splash screen yang dapat dikustomisasi sepenuhnya melalui file `.env`.

### Bagaimana Splash Screen Bekerja

1. **Jika belum login**: Splash screen **selalu ditampilkan**.
2. **Jika sudah login**:
   - Splash screen ditampilkan pada N kali pembukaan pertama (default: 5).
   - Setelah itu, splash screen hanya muncul jika user tidak membuka app lebih dari X jam (default: 24 jam).

---

## Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| **Smooth Transition** | Transisi mulus dari native splash ke Flutter splash |
| **Custom Background** | Background image dari URL (dengan fallback gradient) |
| **Custom Gradient** | Konfigurasi warna gradient 3 titik (start, middle, end) |
| **Configurable Duration** | Durasi splash dapat dikonfigurasi |
| **Tap to Dismiss** | User dapat tap layar untuk skip splash |
| **Loading Indicator** | Animasi loading di bagian bawah |
| **Version Display** | Menampilkan versi app di bagian bawah |
| **Conditional Display** | Logic cerdas untuk menentukan kapan splash ditampilkan |

---

## Konfigurasi .env

### Semua Variable yang Tersedia

```env
# ============================================
# SPLASH SCREEN CONFIGURATION
# ============================================

# Enable/disable splash screen
ENABLE_SPLASH_SCREEN=true

# Duration splash screen ditampilkan (dalam detik)
SPLASH_DURATION=5

# Jumlah pembukaan app pertama yang menampilkan splash (untuk user login)
SPLASH_SHOW_COUNT=5

# Jam tidak aktif sebelum splash ditampilkan lagi (untuk user login)
SPLASH_DELAY=24

# Background image URL (opsional, jika kosong gunakan gradient saja)
SPLASH_BACKGROUND=https://example.com/splash-bg.jpg

# Gradient colors (format hex: #RRGGBB)
SPLASH_GRADIENT_START=#1E88E5
SPLASH_GRADIENT_MIDDLE=#42A5F5
SPLASH_GRADIENT_END=#90CAF9

# Custom logo untuk splash (opsional)
SPLASH_LOGO=assets/images/logo/my_logo.png
```

### Penjelasan Detail

| Variable | Type | Default | Deskripsi |
|----------|------|---------|-----------|
| `ENABLE_SPLASH_SCREEN` | bool | `false` | Aktifkan/nonaktifkan splash screen |
| `SPLASH_DURATION` | int | `5` | Durasi splash dalam detik |
| `SPLASH_SHOW_COUNT` | int | `5` | Jumlah pembukaan awal yang tampilkan splash |
| `SPLASH_DELAY` | int | `24` | Jam tidak aktif sebelum splash muncul lagi |
| `SPLASH_BACKGROUND` | string | `picsum` | URL gambar background |
| `SPLASH_GRADIENT_START` | hex | theme | Warna gradient atas |
| `SPLASH_GRADIENT_MIDDLE` | hex | theme | Warna gradient tengah (opsional) |
| `SPLASH_GRADIENT_END` | hex | theme | Warna gradient bawah |
| `SPLASH_LOGO` | string | default | Path ke logo splash |

---

## Kustomisasi Visual

### Background Image

Background image akan di-load dari URL dan ditampilkan dengan overlay gelap untuk memastikan text tetap terbaca.

```env
# Gunakan gambar sendiri
SPLASH_BACKGROUND=https://your-cdn.com/splash-background.jpg

# Atau kosongkan untuk gradient saja
SPLASH_BACKGROUND=
```

**Catatan:**
- Image akan di-cache menggunakan `CachedNetworkImage`
- Timeout 3 detik untuk loading image
- Jika gagal load, akan fallback ke gradient

### Custom Gradient

Konfigurasi gradient 3 warna dari atas ke bawah:

```env
# Contoh: Blue gradient
SPLASH_GRADIENT_START=#1565C0
SPLASH_GRADIENT_MIDDLE=#42A5F5
SPLASH_GRADIENT_END=#BBDEFB

# Contoh: Purple gradient
SPLASH_GRADIENT_START=#7B1FA2
SPLASH_GRADIENT_MIDDLE=#AB47BC
SPLASH_GRADIENT_END=#E1BEE7

# Contoh: Green gradient
SPLASH_GRADIENT_START=#2E7D32
SPLASH_GRADIENT_MIDDLE=#66BB6A
SPLASH_GRADIENT_END=#C8E6C9
```

**Jika tidak di-set**, gradient akan menggunakan warna dari theme:
- `colorScheme.primary`
- `colorScheme.primaryContainer`
- `colorScheme.secondaryContainer`

### Struktur Visual Splash Screen

```
┌────────────────────────────────────┐
│                                    │
│                                    │
│         ┌─────────────┐            │
│         │             │            │
│         │    LOGO     │            │
│         │             │            │
│         └─────────────┘            │
│                                    │
│           App Name                 │
│           Tagline                  │
│                                    │
│                                    │
│                                    │
│            ◐ Loading...            │
│                                    │
│         v1.0.0 build 1             │
└────────────────────────────────────┘
```

---

## Flow Logic

### Diagram Alur Splash Screen

```
┌─────────────────────────────────────┐
│        App Launched                 │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│    ENABLE_SPLASH_SCREEN = true?     │
└─────────────────┬───────────────────┘
                  │
        ┌─────────┴─────────┐
        │ No                │ Yes
        ▼                   ▼
┌───────────────┐  ┌───────────────────────────┐
│ Skip Splash   │  │      User Logged In?      │
│ → Login/Dash  │  └─────────────┬─────────────┘
└───────────────┘                │
                       ┌─────────┴─────────┐
                       │ No                │ Yes
                       ▼                   ▼
              ┌──────────────┐   ┌───────────────────────────┐
              │ Show Splash  │   │ openCount < SPLASH_COUNT? │
              │ → Login      │   └─────────────┬─────────────┘
              └──────────────┘                 │
                                     ┌─────────┴─────────┐
                                     │ Yes               │ No
                                     ▼                   ▼
                            ┌──────────────┐   ┌──────────────────────────┐
                            │ Show Splash  │   │ lastOpen > DELAY hours?  │
                            │ → Dashboard  │   └────────────┬─────────────┘
                            └──────────────┘                │
                                                  ┌─────────┴─────────┐
                                                  │ Yes               │ No
                                                  ▼                   ▼
                                         ┌──────────────┐    ┌───────────────┐
                                         │ Show Splash  │    │ Skip Splash   │
                                         │ → Dashboard  │    │ → Dashboard   │
                                         └──────────────┘    └───────────────┘
```

### Smooth Transition Flow

```
1. Native splash (solid color) tampil instan saat app launch
                    │
                    ▼
2. Flutter splash muncul di atas native splash
                    │
                    ▼
3. Background image di-preload (async)
                    │
                    ▼
4. Setelah image ready, crossfade dari solid ke image
                    │
                    ▼
5. Animasi logo dan content fade-in + scale
                    │
                    ▼
6. Setelah SPLASH_DURATION atau user tap → Navigate
```

---

## Technical Implementation

### Files Involved

| File | Deskripsi |
|------|-----------|
| `lib/core/constants/app_info.dart` | Konfigurasi splash dari .env |
| `lib/core/services/prefs_service.dart` | Tracking open count dan last opened time |
| `lib/core/routes/app_router.dart` | Logic routing berdasarkan kondisi splash |
| `lib/features/splash/splash_screen.dart` | Widget splash screen |
| `pubspec.yaml` (flutter_native_splash) | Native splash configuration |

### AppInfo Properties

```dart
// lib/core/constants/app_info.dart

// Enable/disable
static bool get enableSplashScreen => ...;

// Durasi
static Duration get splashScreenDuration => ...;

// Visibility logic
static int get splashShowCount => ...;
static int get splashDelayHours => ...;

// Visual customization
static String get splashBackground => ...;
static String? get splashGradientStart => ...;
static String? get splashGradientMiddle => ...;
static String? get splashGradientEnd => ...;
static List<Color>? get splashGradientColors => ...;
static String get flutterSplashLogo => ...;
```

### PrefsService Methods

```dart
// lib/core/services/prefs_service.dart

// Tracking
int get splashOpenCount;
DateTime? get lastOpenedTime;

// Logic
Future<bool> shouldShowSplash();
Future<void> recordAppOpen();
```

### Splash Screen Widget

```dart
// lib/features/splash/splash_screen.dart

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;      // Callback setelah splash selesai
  final Duration? splashDuration;       // Override durasi (opsional)
  
  // Features:
  // - Smooth transition dari native splash
  // - Background image dengan preload
  // - Gradient fallback
  // - Animasi logo fade + scale
  // - Tap to dismiss
  // - Loading indicator
  // - Version display
}
```

---

## Troubleshooting

### Splash tidak muncul

1. Pastikan `ENABLE_SPLASH_SCREEN=true` di `.env`
2. Restart app sepenuhnya (bukan hot reload)
3. Cek apakah sudah melebihi `SPLASH_SHOW_COUNT`

### Background image tidak muncul

1. Cek URL valid dan accessible
2. Pastikan device memiliki koneksi internet
3. Image akan timeout setelah 3 detik

### Gradient tidak sesuai

1. Pastikan format hex benar: `#RRGGBB`
2. Jika hanya set 1-2 warna, colors lain akan menggunakan theme default

### Native splash berbeda dengan Flutter splash

Edit `pubspec.yaml` bagian `flutter_native_splash`:

```yaml
flutter_native_splash:
  color: "#1565C0"  # Harus sama dengan SPLASH_GRADIENT_START
```

Lalu jalankan:
```bash
dart run flutter_native_splash:create
```

---

## Contoh Konfigurasi

### Minimal (Default)

```env
ENABLE_SPLASH_SCREEN=true
```

### Dengan Custom Duration

```env
ENABLE_SPLASH_SCREEN=true
SPLASH_DURATION=3
SPLASH_SHOW_COUNT=3
SPLASH_DELAY=12
```

### Full Customization

```env
ENABLE_SPLASH_SCREEN=true
SPLASH_DURATION=5
SPLASH_SHOW_COUNT=5
SPLASH_DELAY=24
SPLASH_BACKGROUND=https://cdn.example.com/splash.jpg
SPLASH_GRADIENT_START=#1565C0
SPLASH_GRADIENT_MIDDLE=#42A5F5
SPLASH_GRADIENT_END=#BBDEFB
SPLASH_LOGO=assets/images/logo/custom_logo.png
```

---

## Lihat Juga

- **[README.md](../README.md)** - Dokumentasi utama project
- **[Modular.md](./Modular.md)** - Arsitektur modular

---

*Dibuat: 30 Desember 2025*
*Diperbarui: 1 Januari 2026*
*Versi: 2.0.0*
