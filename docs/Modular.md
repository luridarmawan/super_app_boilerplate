# Arsitektur Modular Super App Boilerplate

Dokumentasi ini menjelaskan strategi arsitektur modular untuk membuat base code yang dapat digunakan sebagai template aplikasi untuk berbagai client tanpa melakukan perubahan besar pada core code.

> **📚 Dokumen Terkait:**
> - **[SubModule.md](./SubModule.md)** - Panduan khusus untuk modul eksternal (repository terpisah)
> - **[API.md](./API.md)** - Network layer documentation

---

## Daftar Isi

1. [Pendahuluan](#pendahuluan)
2. [Analisis Struktur Saat Ini](#analisis-struktur-saat-ini)
3. [Strategi Utama](#strategi-utama)
   - [Plugin-Based Module System](#1-plugin-based-module-system)
   - [Feature Flags via Environment Variables](#2-feature-flags-via-environment-variables)
   - [Dynamic Route Registration](#3-dynamic-route-registration)
   - [Dashboard Widget Slots](#4-dashboard-widget-slots)
   - [Shared Service Layer dengan Dependency Injection](#5-shared-service-layer-dengan-dependency-injection)
   - [Theming & Branding Configuration](#6-theming--branding-configuration)
   - [Localization Module Structure](#7-localization-module-structure)
4. [Struktur Folder yang Direkomendasikan](#struktur-folder-yang-direkomendasikan)
5. [Langkah Implementasi](#langkah-implementasi)
6. [Cara Membuat Modul Baru](#cara-membuat-modul-baru)
7. [Contoh Implementasi](#contoh-implementasi)

---

## Pendahuluan

### Tujuan
Membuat arsitektur yang memungkinkan:
- **Penambahan modul baru** tanpa mengubah base code
- **Kustomisasi per client** dengan mudah
- **Maintenance** yang lebih sederhana
- **Testing** yang independen per modul

### Prinsip Dasar
| Prinsip | Deskripsi |
|---------|-----------|
| **Separation of Concerns** | Setiap modul menangani satu domain bisnis |
| **Loose Coupling** | Modul tidak bergantung langsung satu sama lain |
| **High Cohesion** | Kode terkait dikumpulkan dalam satu modul |
| **Open/Closed Principle** | Terbuka untuk ekstensi, tertutup untuk modifikasi |

---

## Analisis Struktur Saat Ini

Struktur proyek saat ini:

```
lib/
├── core/          # Infrastructure layer (auth, network, theme, dll)
├── features/      # Feature modules (auth, dashboard, profile, dll)
├── shared/        # Shared components (widgets, info screens)
└── main.dart
```

### Kelebihan
- Pemisahan yang jelas antara core, features, dan shared
- Menggunakan Riverpod untuk state management
- Konfigurasi via `.env` file

### Area Peningkatan
- Belum ada sistem untuk modul pluggable
- Routes masih hardcoded di `app_router.dart`
- Dashboard belum mendukung widget dinamis dari modul

---

## Strategi Utama

### 1. Plugin-Based Module System

Sistem dimana modul-modul bisa "menempel" ke base app tanpa mengubah core code.

#### Konsep Base Module

```dart
// lib/modules/module_base.dart
abstract class BaseModule {
  /// Nama unik modul
  String get name;
  
  /// Versi modul
  String get version;
  
  /// Deskripsi modul
  String get description;
  
  /// Routes yang disediakan modul
  List<GoRoute> get routes;
  
  /// Riverpod providers yang disediakan modul
  List<Override> get providerOverrides;
  
  /// Widget untuk ditampilkan di dashboard
  Widget? get dashboardWidget;
  
  /// Item menu untuk sidebar/navbar
  List<NavigationItem> get menuItems;
  
  /// Dependencies ke modul lain (opsional)
  List<String> get dependencies;
  
  /// Inisialisasi modul (dipanggil saat app startup)
  Future<void> initialize();
  
  /// Cleanup modul (dipanggil saat app shutdown)
  Future<void> dispose();
}
```

#### Konsep Module Registry

```dart
// lib/modules/module_registry.dart
class ModuleRegistry {
  static final List<BaseModule> _modules = [];
  
  /// Mendaftarkan modul
  static void register(BaseModule module) {
    if (!_modules.any((m) => m.name == module.name)) {
      _modules.add(module);
    }
  }
  
  /// Mendapatkan semua modul yang terdaftar
  static List<BaseModule> get modules => List.unmodifiable(_modules);
  
  /// Mendapatkan modul aktif berdasarkan feature flags
  static List<BaseModule> get activeModules {
    return _modules.where((m) => _isModuleEnabled(m.name)).toList();
  }
  
  /// Cek apakah modul diaktifkan via .env
  static bool _isModuleEnabled(String moduleName) {
    final envKey = 'ENABLE_MODULE_${moduleName.toUpperCase()}';
    return dotenv.env[envKey]?.toLowerCase() == 'true';
  }
  
  /// Inisialisasi semua modul aktif
  static Future<void> initializeAll() async {
    for (final module in activeModules) {
      await module.initialize();
    }
  }
  
  /// Mendapatkan semua routes dari modul aktif
  static List<GoRoute> get allRoutes {
    return activeModules.expand((m) => m.routes).toList();
  }
  
  /// Mendapatkan semua dashboard widgets dari modul aktif
  static List<Widget> get dashboardWidgets {
    return activeModules
        .where((m) => m.dashboardWidget != null)
        .map((m) => m.dashboardWidget!)
        .toList();
  }
}
```

---

### 2. Feature Flags via Environment Variables

Manfaatkan sistem `.env` yang sudah ada untuk toggle fitur.

#### Konfigurasi di .env

```env
# Core Features
ENABLE_NOTIFICATION=true
ENABLE_GPS=true

# Module Flags
ENABLE_MODULE_ECOMMERCE=true
ENABLE_MODULE_NEWS=true
ENABLE_MODULE_CHAT=false
ENABLE_MODULE_PAYMENT=true
ENABLE_MODULE_BOOKING=false
```

#### Akses di Kode

```dart
// lib/core/constants/app_info.dart
class AppInfo {
  // ... existing code ...
  
  /// Cek apakah modul tertentu diaktifkan
  static bool isModuleEnabled(String moduleName) {
    final envKey = 'ENABLE_MODULE_${moduleName.toUpperCase()}';
    return dotenv.env[envKey]?.toLowerCase() == 'true';
  }
}
```

#### Keuntungan
- Toggle fitur tanpa ubah kode
- Build berbeda untuk client berbeda
- Mudah testing A/B
- Dokumentasi fitur yang tersedia jelas di `.env.example`

---

### 3. Dynamic Route Registration

Modifikasi `app_router.dart` untuk mendukung route dinamis dari modul.

#### Modifikasi Router Provider

```dart
// lib/core/routes/app_router.dart
final routerProvider = Provider<GoRouter>((ref) {
  final prefsService = ref.watch(prefsServiceProvider);
  
  // Base routes (core features)
  final baseRoutes = <GoRoute>[
    GoRoute(path: AppRoutes.splash, ...),
    GoRoute(path: AppRoutes.login, ...),
    GoRoute(path: AppRoutes.dashboard, ...),
    // ... other core routes
  ];
  
  // Tambahkan routes dari modul yang aktif
  final moduleRoutes = ModuleRegistry.allRoutes;
  
  // Gabungkan semua routes
  final allRoutes = [...baseRoutes, ...moduleRoutes];
  
  return GoRouter(
    routes: allRoutes,
    // ... other config
  );
});
```

#### Menambahkan Route dari Modul

Setiap modul mendefinisikan route-nya sendiri:

```dart
// lib/modules/news/news_module.dart
class NewsModule extends BaseModule {
  @override
  List<GoRoute> get routes => [
    GoRoute(
      path: '/news',
      builder: (context, state) => const NewsListScreen(),
    ),
    GoRoute(
      path: '/news/:id',
      builder: (context, state) => NewsDetailScreen(
        id: state.pathParameters['id']!,
      ),
    ),
  ];
}
```

---

### 4. Dashboard Widget Slots

Sistem "slot" di dashboard untuk modul menambahkan widget.

#### Dashboard dengan Slots

```dart
// lib/features/dashboard/main_dashboard.dart
class ModularDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dapatkan dashboard widgets dari modul aktif
    final moduleWidgets = ModuleRegistry.dashboardWidgets;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header section (tetap)
          SliverToBoxAdapter(child: _buildHeader()),
          
          // Carousel section (tetap)
          SliverToBoxAdapter(child: _buildCarousel()),
          
          // Module widgets (dinamis)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildListDelegate(moduleWidgets),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Widget yang Disediakan Modul

```dart
// lib/modules/news/news_module.dart
class NewsModule extends BaseModule {
  @override
  Widget? get dashboardWidget => const NewsDashboardCard();
}

// lib/modules/news/widgets/news_dashboard_card.dart
class NewsDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/news'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper, size: 48),
            Text('Berita Terbaru'),
            Text('5 artikel baru'),
          ],
        ),
      ),
    );
  }
}
```

---

### 5. Shared Service Layer dengan Dependency Injection

Service layer yang bisa di-override per client.

#### Konsep Overridable Services

```dart
// lib/core/network/api_service_provider.dart
final apiServiceProvider = Provider<ApiService>((ref) {
  // Default implementation
  return DefaultApiService(
    baseUrl: AppInfo.activeApiBaseUrl,
  );
});
```

#### Override di Main untuk Client Tertentu

```dart
// lib/main.dart
void main() async {
  // ... initialization code ...
  
  runApp(
    ProviderScope(
      overrides: [
        // Override untuk client tertentu
        apiServiceProvider.overrideWithValue(CustomClientApiService()),
        
        // Override authentication provider
        authServiceProvider.overrideWithValue(CustomAuthProvider()),
      ],
      child: const SuperApp(),
    ),
  );
}
```

#### Keuntungan
- Ganti implementasi tanpa ubah kode yang menggunakan
- Mudah testing dengan mock services
- Fleksibel untuk kebutuhan client berbeda

---

### 6. Theming & Branding Configuration

Pisahkan konfigurasi branding ke file terpisah untuk kustomisasi per client.

#### Struktur Branding

```
lib/
├── branding/
│   ├── branding_config.dart     # Konfigurasi branding default
│   ├── assets_config.dart       # Path asset (logo, gambar, dll)
│   └── themes/
│       ├── default_theme.dart   # Theme default
│       └── client_themes/       # Theme per client (opsional)
```

#### Konsep Branding Config

```dart
// lib/branding/branding_config.dart
class BrandingConfig {
  // App Identity
  static const String appName = 'Super App';
  static const String companyName = 'PT. Super Tech';
  static const String tagline = 'Your All-in-One Solution';
  
  // Colors (bisa di-override via .env atau per client)
  static Color get primaryColor => 
      _parseColor(dotenv.env['PRIMARY_COLOR']) ?? 
      const Color(0xFF1565C0);
  
  static Color get accentColor => 
      _parseColor(dotenv.env['ACCENT_COLOR']) ?? 
      const Color(0xFF00BCD4);
  
  // Assets
  static const String logoPath = 'assets/images/logo/app_logo.png';
  static const String splashLogoPath = 'assets/images/logo/splash_logo.png';
  
  // Social Links
  static const String websiteUrl = 'https://example.com';
  static const String supportEmail = 'support@example.com';
  
  static Color? _parseColor(String? hexColor) {
    if (hexColor == null) return null;
    return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
  }
}
```

---

### 7. Localization Module Structure

Pisahkan localization per modul untuk skalabilitas.

#### Struktur

```
lib/
├── core/l10n/
│   ├── app_localizations.dart       # Core strings
│   └── strings/
│       ├── common_strings.dart      # String umum
│       └── error_strings.dart       # String error
│
├── modules/
│   └── [module_name]/
│       └── l10n/
│           └── [module]_strings.dart  # Modul-specific strings
```

#### Konsep Localization per Modul

```dart
// lib/modules/news/l10n/news_strings.dart
class NewsStrings {
  static const Map<String, Map<String, String>> _strings = {
    'id': {
      'news_title': 'Berita',
      'news_empty': 'Tidak ada berita',
      'news_loading': 'Memuat berita...',
      'news_error': 'Gagal memuat berita',
    },
    'en': {
      'news_title': 'News',
      'news_empty': 'No news available',
      'news_loading': 'Loading news...',
      'news_error': 'Failed to load news',
    },
  };
  
  static String get(String key, String locale) {
    return _strings[locale]?[key] ?? _strings['en']?[key] ?? key;
  }
}
```

---

## Struktur Folder yang Direkomendasikan

```
super_app_boilerplate/
├── packages/                     # Shared contracts
│   └── module_interface/         # Package dasar untuk semua modul (BaseModule, NavItem, dll)
│
├── modules/                      # External Modules (GITIGNORED)
│   ├── .gitkeep                  # Placeholder agar folder tetap ada
│   └── [external_module]/        # Clone dari repository terpisah via modules.yaml
│
├── lib/
│   ├── core/                     # TIDAK DIUBAH - Base infrastructure
│   │   ├── auth/                 # Authentication services
│   │   ├── config/               # App configuration
│   │   ├── constants/            # Constants & app info
│   │   ├── gps/                  # GPS services
│   │   ├── l10n/                 # Core localization
│   │   ├── network/              # Network layer (Dio, Retrofit)
│   │   ├── notification/         # Push notification
│   │   ├── routes/               # Routing (GoRouter)
│   │   ├── services/             # Core services
│   │   ├── theme/                # Theme configuration
│   │   └── utils/                # Utility functions
│   │
│   ├── modules/                  # Internal Modules (tracked by git)
│   │   ├── all_modules.dart      # Module manifest (auto-generated)
│   │   ├── module_base.dart      # Re-export dari module_interface
│   │   ├── module_registry.dart  # Registry untuk registrasi modul
│   │   ├── modules.dart          # Module exports
│   │   └── sample/               # Contoh modul internal
│   │
│   ├── features/                 # Built-in core features (auth, dashboard, dll)
│   ├── shared/                   # Shared components (widgets, info screens)
│   └── main.dart                 # App entry point
│
├── tool/                         # CLI tools
│   ├── generate_module_internal.dart  # Generate modul internal
│   ├── manage_external_modules.dart  # Kelola modul eksternal
│   └── sync_modules.dart         # Sync pendaftaran modul
│
├── modules.yaml.example          # Template manifest modul eksternal
└── modules.yaml                  # Manifest lokal (GITIGNORED)
```

### Perbedaan Internal vs External Modules

| Aspek | Internal Module | External Module |
|-------|-----------------|------------------|
| **Lokasi** | `lib/modules/` | `modules/` (root) |
| **Git tracking** | ✅ Di-track | ❌ Gitignored |
| **Repository** | Sama dengan app | Terpisah |
| **Cocok untuk** | Fitur spesifik app ini | Fitur yang di-reuse antar project |
| **CLI Tool** | `generate_module_internal.dart` | `manage_external_modules.dart` |
| **Dokumentasi** | Dokumen ini | [SubModule.md](./SubModule.md) |

---

## Langkah Implementasi

| Prioritas | Langkah | Deskripsi | Status |
|-----------|---------|-----------|--------|
| 1️⃣ | **Module Base Class** | Buat `BaseModule` abstract class sebagai kontrak untuk semua modul | ✅ Selesai |
| 2️⃣ | **Module Registry** | Sistem untuk mendaftarkan dan mengelola modul aktif | ✅ Selesai |
| 3️⃣ | **Dynamic Routes** | Modifikasi router untuk menerima routes dari modul | ✅ Selesai |
| 4️⃣ | **Dashboard Slots** | Sistem slot widget di dashboard | ✅ Selesai |
| 5️⃣ | **Branding Config** | Konfigurasi branding terintegrasi di `AppInfo` | ✅ Selesai |
| 6️⃣ | **Sample Module** | Buat contoh modul (misal: "News Module") | ✅ Selesai |
| 7️⃣ | **CLI Tool** | Script untuk generate modul baru | ✅ Selesai |
| 8️⃣ | **Module Manifest** | Registrasi otomatis via `ModuleManifest` & `sync_modules.dart` | ✅ Selesai |

### File yang Sudah Dibuat

| File | Deskripsi |
|------|-----------|
| `packages/module_interface/` | **Kontrak Utama**: Shared package berisi `BaseModule` |
| `lib/modules/module_registry.dart` | Registry untuk registrasi dan manajemen modul |
| `lib/modules/all_modules.dart` | Manifest pendaftaran modul (Auto-generated) |
| `lib/modules/sample/sample_module.dart` | Contoh implementasi modul internal |
| `tool/generate_module_internal.dart` | CLI tool untuk module internal (local folder) |
| `tool/generate_module.dart` | CLI tool interaktif untuk membuat modul eksternal baru |
| `tool/manage_external_modules.dart` | CLI tool untuk module eksternal (tanpa git submodule) |
| `tool/sync_modules.dart` | Script sinkronisasi pendaftaran modul internal |
| `modules.yaml.example` | Template manifest untuk modul eksternal |

---

## Cara Membuat Modul Baru

Terdapat dua cara untuk membuat modul tergantung pada kebutuhan skalabilitas:

### Opsi 1: Modul Internal (Satu Repository)

Cocok untuk fitur yang spesifik hanya untuk aplikasi ini. Menggunakan CLI tool:

```bash
dart run tool/generate_module_internal.dart <nama_modul>
```

### Opsi 2: Modul Eksternal (Repository Terpisah)

Cocok jika modul ingin dipisah repository-nya (misal: dikerjakan tim berbeda).
Strategi ini **tidak menggunakan git submodule** sehingga tidak ada perubahan di `.gitmodules`.
Lihat panduan lengkapnya di [SubModule.md](./SubModule.md).

#### Membuat Modul Eksternal Baru (Interaktif)

Gunakan CLI tool interaktif untuk membuat modul eksternal baru:

```bash
dart run tool/generate_module.dart
```

Tool akan menanyakan:
1. **Nama module** - Akan dikonversi ke snake_case (contoh: "CRM System" → `crm_system`)
2. **Deskripsi module** - Deskripsi singkat tentang modul
3. **Jumlah workspace** - Setiap workspace memiliki fitur list dan add/update
   - Jika hanya 1, nama default = nama modul
   - Contoh: Modul CRM bisa punya workspace `Customer`, `Sales`, `Vendor`
4. **Jumlah Quick Action** - Default 1, sesuai nama modul

Struktur yang akan dibuat:
```
modules/[nama_modul]/
├── lib/
│   ├── [nama_modul].dart           # Library exports
│   ├── [nama_modul]_module.dart    # Main module class
│   └── screens/
│       └── [workspace]/
│           ├── [workspace]_list_screen.dart
│           └── [workspace]_form_screen.dart
├── test/
│   └── [nama_modul]_test.dart
├── pubspec.yaml
├── LICENSE
├── README.md
└── .gitignore
```

#### Clone Modul Eksternal dari Repository

Untuk clone modul yang sudah ada dari repository terpisah:

```bash
# 1. Copy template manifest
copy modules.yaml.example modules.yaml

# 2. Edit modules.yaml - tambahkan modul eksternal

# 3. Clone semua modul
dart run tool/manage_external_modules.dart
```

#### Contoh Modul Internal (generate_module_internal.dart)

Untuk modul internal yang lebih sederhana:
```bash
dart run tool/generate_module_internal.dart news
dart run tool/generate_module_internal.dart ecommerce
dart run tool/generate_module_internal.dart booking
```

CLI tool akan otomatis membuat:
- File modul utama (`<nama>_module.dart`)
- Screen utama (`screens/<nama>_screen.dart`)
- Dashboard card widget (`widgets/<nama>_dashboard_card.dart`)

Setelah di-generate, Anda hanya perlu:
1. **Cek Pendaftaran**: Modul akan otomatis terdaftar di `lib/modules/all_modules.dart` oleh CLI tool.
2. **Enable modul** di `.env`

### Opsi 2: Membuat Manual

Jika ingin membuat secara manual, ikuti langkah berikut:

#### Langkah 1: Buat Folder Modul

```
lib/modules/[nama_modul]/
├── module.dart
├── routes/
├── providers/
├── screens/
├── widgets/
├── services/
├── models/
└── l10n/
```

### Langkah 2: Implementasikan BaseModule

```dart
// lib/modules/news/module.dart
import '../../modules/module_base.dart';

class NewsModule extends BaseModule {
  @override
  String get name => 'news';
  
  @override
  String get version => '1.0.0';
  
  @override
  String get description => 'Modul berita dan artikel';
  
  @override
  List<GoRoute> get routes => [
    GoRoute(
      path: '/news',
      builder: (_, __) => const NewsListScreen(),
    ),
    GoRoute(
      path: '/news/:id',
      builder: (_, state) => NewsDetailScreen(
        id: state.pathParameters['id']!,
      ),
    ),
  ];
  
  @override
  List<Override> get providerOverrides => [];
  
  @override
  Widget? get dashboardWidget => const NewsDashboardCard();
  
  @override
  List<NavigationItem> get menuItems => [
    NavigationItem(
      icon: Icons.newspaper,
      label: 'Berita',
      route: '/news',
    ),
  ];
  
  @override
  List<String> get dependencies => []; // Tidak ada dependency
  
  @override
  Future<void> initialize() async {
    // Inisialisasi modul (load cache, dll)
    debugPrint('NewsModule initialized');
  }
  
  @override
  Future<void> dispose() async {
    // Cleanup
  }
}
```

### Langkah 3: Daftarkan Modul

```dart
// lib/main.dart
import 'modules/all_modules.dart';

void main() async {
  // ... existing initialization ...
  
  // Daftarkan semua modul via Manifest (Otomatis)
  ModuleManifest.register();
  
  // Inisialisasi modul aktif
  await ModuleRegistry.initializeAll();
  
  runApp(...);
}

// Catatan: Jika pendaftaran tidak otomatis, jalankan:
// dart run tool/sync_modules.dart
```

### Langkah 4: Aktifkan di .env

```env
ENABLE_MODULE_NEWS=true
```

---

## Contoh Implementasi

### Contoh 1: News Module

```
lib/modules/news/
├── module.dart                   # Entry point
├── routes/
│   └── news_routes.dart          # Route definitions
├── providers/
│   └── news_provider.dart        # State management
├── screens/
│   ├── news_list_screen.dart     # Daftar berita
│   └── news_detail_screen.dart   # Detail berita
├── widgets/
│   ├── news_card.dart            # Card berita
│   └── news_dashboard_card.dart  # Widget untuk dashboard
├── services/
│   └── news_service.dart         # API calls
├── models/
│   └── news_model.dart           # Data model
└── l10n/
    └── news_strings.dart         # Localization
```

### Contoh 2: E-Commerce Module

```
lib/modules/ecommerce/
├── module.dart
├── routes/
│   └── ecommerce_routes.dart
├── providers/
│   ├── cart_provider.dart
│   ├── product_provider.dart
│   └── order_provider.dart
├── screens/
│   ├── product_list_screen.dart
│   ├── product_detail_screen.dart
│   ├── cart_screen.dart
│   └── checkout_screen.dart
├── widgets/
│   ├── product_card.dart
│   ├── cart_item.dart
│   └── ecommerce_dashboard_card.dart
├── services/
│   ├── product_service.dart
│   └── order_service.dart
├── models/
│   ├── product_model.dart
│   ├── cart_model.dart
│   └── order_model.dart
└── l10n/
    └── ecommerce_strings.dart
```

---

## Keuntungan Arsitektur Ini

| Aspek | Keuntungan |
|-------|------------|
| **Untuk Developer** | Cukup copy folder modul, daftarkan di registry |
| **Untuk Client** | Pilih modul sesuai kebutuhan, toggle via .env |
| **Untuk Maintenance** | Update modul tidak mempengaruhi core |
| **Untuk Testing** | Setiap modul bisa di-test independen |
| **Untuk Build** | Build berbeda untuk client berbeda |
| **Untuk Tim** | Anggota tim bisa fokus pada modul masing-masing |

---

## FAQ

### Q: Bagaimana jika modul A butuh data dari modul B?

**A:** Gunakan Riverpod providers yang di-expose oleh modul B. Pastikan modul A mendaftarkan modul B sebagai dependency:

```dart
class ModuleA extends BaseModule {
  @override
  List<String> get dependencies => ['module_b'];
}
```

### Q: Bagaimana cara share widget antar modul?

**A:** Letakkan widget yang reusable di `lib/shared/widgets/`. Modul-modul bisa mengimport dari sana.

### Q: Bagaimana jika client ingin custom behavior di modul?

**A:** Gunakan pattern dependency injection. Override provider yang relevan di `main.dart`:

```dart
ProviderScope(
  overrides: [
    newsServiceProvider.overrideWithValue(CustomNewsService()),
  ],
  child: SuperApp(),
)
```

### Q: Bagaimana versioning modul?

**A:** Setiap modul memiliki property `version`. Ini berguna untuk tracking kompatibilitas dan update.

---

## Referensi

- [Flutter Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Clean Architecture Flutter](https://resocoder.com/flutter-clean-architecture-tdd)
- [Modular Design Patterns](https://martinfowler.com/eaaCatalog/plugin.html)

---

*Dibuat: 20 Desember 2025*
*Diperbarui: 1 Januari 2026*
*Versi: 1.2.0*
