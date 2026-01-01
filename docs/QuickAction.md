# Quick Action

Quick Actions adalah fitur yang memungkinkan setiap modul menyediakan aksi cepat yang ditampilkan dalam grid menu di dashboard.

> **📚 Dokumen Terkait:**
> - **[Modular.md](./Modular.md)** - Arsitektur modular (BaseModule, registry)
> - **[SubModule.md](./SubModule.md)** - Panduan external modules

---

## Daftar Isi

1. [Pendahuluan](#pendahuluan)
2. [Fitur Utama](#fitur-utama)
3. [Cara Menggunakan](#cara-menggunakan)
   - [Menambahkan Quick Actions ke Modul](#menambahkan-quick-actions-ke-modul)
   - [Menampilkan Quick Actions di Dashboard](#menampilkan-quick-actions-di-dashboard)
4. [Model QuickActionItem](#model-quickactionitem)
5. [Konfigurasi Visibility](#konfigurasi-visibility)
6. [Static Quick Actions](#static-quick-actions)
7. [Quick Actions Manager](#quick-actions-manager)
8. [Contoh Implementasi](#contoh-implementasi)
9. [**Quick Actions di External Module (SubModule)**](#quick-actions-di-external-module-submodule) ⭐ NEW

---

## Pendahuluan

Quick Actions adalah ikon/tombol yang ditampilkan di dashboard dalam format grid. Fitur ini memungkinkan:

- **Setiap modul** dapat menyediakan **lebih dari satu quick action**
- User dapat **mengaktifkan/menonaktifkan** quick action individual
- Mendukung **navigasi route** atau **custom callback**
- Otomatis menampilkan tombol **"More"** jika jumlah quick action melebihi batas

---

## Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| **Multi-action per module** | Setiap modul bisa memiliki lebih dari satu quick action |
| **Route Navigation** | Quick action dapat navigasi ke halaman tertentu |
| **Custom Callback** | Quick action dapat menjalankan fungsi custom (dialog, snackbar, dll) |
| **Visibility Control** | User dapat show/hide individual quick action |
| **Persistence** | Setting visibility tersimpan di SharedPreferences |
| **Auto "More"** | Tombol "More" otomatis muncul jika jumlah action melebihi limit |
| **Backward Compatible** | Legacy `MenuItem` tetap didukung |

---

## Cara Menggunakan

### Menambahkan Quick Actions ke Modul

Override getter `quickActions` di modul Anda:

```dart
import '../quick_action_item.dart';

class MyModule extends BaseModule {
  @override
  String get name => 'mymodule';
  
  // ... other overrides ...

  @override
  List<QuickActionItem> get quickActions => [
    // Quick action dengan navigasi route
    QuickActionItem(
      id: 'mymodule_action1',
      moduleId: name,
      icon: Icons.payments,
      label: 'Pay',
      color: const Color(0xFF1565C0),
      route: '/mymodule/pay',
      order: 100,
      description: 'Make a payment',
    ),
    
    // Quick action dengan custom callback
    QuickActionItem(
      id: 'mymodule_action2',
      moduleId: name,
      icon: Icons.qr_code_scanner,
      label: 'Scan',
      color: const Color(0xFF2E7D32),
      onTap: (context) {
        // Custom action
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Scan QR'),
            content: Text('Opening scanner...'),
          ),
        );
      },
      order: 101,
      description: 'Scan QR code',
    ),
  ];
}
```

### Menampilkan Quick Actions di Dashboard

Gunakan widget `QuickActionGrid` atau `QuickActionSection`:

```dart
// Di dashboard widget

// Option 1: Hanya grid (More selalu tampil)
QuickActionGrid(
  maxItems: 8,           // Maksimal item sebelum otomatis dipotong
  crossAxisCount: 4,     // Jumlah kolom
  alwaysShowMore: true,  // Tombol "More" selalu tampil (default: true)
)

// Option 2: More hanya muncul jika items > maxItems
QuickActionGrid(
  maxItems: 8,
  alwaysShowMore: false,
)

// Option 3: Dengan section header
QuickActionSection(
  title: 'Quick Actions',
  seeAllText: 'See All',
  maxItems: 8,
)
```

---

## Model QuickActionItem

```dart
class QuickActionItem {
  final String id;              // Unique identifier (required)
  final String moduleId;        // Module ID (required)
  final IconData icon;          // Icon (required)
  final String label;           // Display label (required)
  final Color? color;           // Icon color (optional)
  final String? route;          // Navigation route (required if no onTap)
  final QuickActionCallback? onTap;  // Custom callback (required if no route)
  final int order;              // Sort order (default: 100)
  final bool enabledByDefault;  // Default visibility (default: true)
  final String? description;    // Description for manager screen (optional)
}
```

### Field Details

| Field | Type | Required | Default | Deskripsi |
|-------|------|----------|---------|-----------|
| `id` | String | ✅ | - | Unique identifier. Format: `{moduleId}_{actionName}` |
| `moduleId` | String | ✅ | - | ID modul yang menyediakan action ini |
| `icon` | IconData | ✅ | - | Icon untuk ditampilkan |
| `label` | String | ✅ | - | Label text |
| `color` | Color? | ❌ | Primary | Warna icon |
| `route` | String? | ⚠️ | - | Route navigasi (wajib jika tidak ada onTap) |
| `onTap` | Function? | ⚠️ | - | Custom callback (wajib jika tidak ada route) |
| `order` | int | ❌ | 100 | Urutan sorting (rendah = tampil duluan) |
| `enabledByDefault` | bool | ❌ | true | Visibility default |
| `description` | String? | ❌ | - | Deskripsi di manager screen |

---

## Konfigurasi Visibility

### Providers

```dart
// Mendapatkan semua quick actions (static + modules)
final allActions = ref.watch(allQuickActionsProvider);

// Mendapatkan visibility state
final visibility = ref.watch(quickActionVisibilityProvider);

// Mendapatkan quick actions yang visible saja
final visibleActions = ref.watch(visibleQuickActionsProvider);

// Mendapatkan quick actions untuk grid (dengan limit)
final gridActions = ref.watch(menuGridQuickActionsProvider(8));

// Cek apakah tombol "More" perlu ditampilkan
final showMore = ref.watch(showMoreButtonProvider(8));
```

### Toggle Visibility

```dart
// Toggle individual action
ref.read(quickActionVisibilityProvider.notifier).toggle('action_id');

// Set visibility
ref.read(quickActionVisibilityProvider.notifier).setVisibility('action_id', true);

// Show all
ref.read(quickActionVisibilityProvider.notifier).showAll(actionIds);

// Hide all
ref.read(quickActionVisibilityProvider.notifier).hideAll(actionIds);

// Reset to default
ref.read(quickActionVisibilityProvider.notifier).resetToDefault();
```

---

## Static Quick Actions

Quick actions default yang selalu tersedia, didefinisikan di `lib/modules/quick_action_item.dart`:

```dart
class StaticQuickActions {
  static const String moduleId = 'static';

  static List<QuickActionItem> get items => const [
    QuickActionItem(
      id: 'static_pay',
      moduleId: moduleId,
      icon: Icons.payments_outlined,
      label: 'Pay',
      color: Color(0xFF1565C0),
      route: '/pay',
      order: 1,
    ),
    // ... more static actions
  ];
}
```

Static actions dapat dikustomisasi dengan mengedit file tersebut.

---

## Quick Actions Manager

Halaman untuk mengelola visibility quick actions tersedia di route `/quick-actions`.

### Fitur Manager

- Melihat semua quick actions (grouped by module)
- Toggle visibility individual
- Show/Hide all
- Reset to default

### Navigasi ke Manager

```dart
// Via route
context.push('/quick-actions');

// Atau via constant
context.push(AppRoutes.quickActions);
```

---

## Contoh Implementasi

### Sample Module dengan Quick Actions

```dart
// lib/modules/sample/sample_module.dart

class SampleModule extends BaseModule {
  @override
  String get name => 'sample';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'A sample module';

  @override
  List<QuickActionItem> get quickActions => [
    // Route-based action
    QuickActionItem(
      id: 'sample_explore',
      moduleId: name,
      icon: Icons.explore_outlined,
      label: 'Explore',
      color: const Color(0xFF7C4DFF),
      route: '/sample',
      order: 100,
      description: 'Explore sample features',
    ),
    
    // Custom callback action
    QuickActionItem(
      id: 'sample_action',
      moduleId: name,
      icon: Icons.flash_on_outlined,
      label: 'Quick',
      color: const Color(0xFFFF6D00),
      onTap: (context) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample quick action executed!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      order: 101,
      description: 'Execute a quick action',
    ),
    
    // Another route-based action
    QuickActionItem(
      id: 'sample_detail',
      moduleId: name,
      icon: Icons.info_outline,
      label: 'Details',
      color: const Color(0xFF00BFA5),
      route: '/sample/detail/1',
      order: 102,
      description: 'View sample details',
    ),
  ];

  // ... other overrides
}
```

### Dashboard dengan QuickActionGrid

```dart
// lib/features/dashboard/main_dashboard.dart

class MainDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header, carousel, etc.
            
            // Quick Actions Section
            const SizedBox(height: 16),
            QuickActionSection(
              title: 'Quick Actions',
              seeAllText: 'Manage',
              maxItems: 8,
            ),
            
            // Or just the grid
            // QuickActionGrid(maxItems: 8),
            
            // Other content
          ],
        ),
      ),
    );
  }
}
```

---

## File Terkait

| File | Deskripsi |
|------|-----------|
| `lib/modules/quick_action_item.dart` | Model QuickActionItem dan StaticQuickActions |
| `lib/modules/module_base.dart` | BaseModule dengan getter quickActions |
| `lib/modules/module_registry.dart` | Providers untuk mengumpulkan quick actions |
| `lib/features/dashboard/widgets/menu_grid.dart` | QuickActionGrid dan QuickActionSection widgets |
| `lib/features/dashboard/providers/quick_action_visibility_provider.dart` | State management untuk visibility |
| `lib/features/dashboard/screens/quick_actions_manager_screen.dart` | Halaman manager |
| `lib/core/routes/app_router.dart` | Route untuk quick-actions manager |

---

## FAQ

### Q: Bagaimana cara menambahkan quick action baru ke modul?

**A:** Override getter `quickActions` di class modul Anda dan tambahkan `QuickActionItem` baru ke list.

### Q: Apakah bisa menggunakan custom callback dan route sekaligus?

**A:** Bisa, tapi `onTap` akan diprioritaskan. Jika `onTap` ada, route akan diabaikan.

### Q: Bagaimana urutan quick actions ditentukan?

**A:** Berdasarkan field `order`. Nilai lebih kecil = muncul lebih dulu. Static actions memiliki order 1-7, jadi gunakan order >= 100 untuk module actions.

### Q: Apakah visibility setting tersimpan secara persistent?

**A:** Ya, tersimpan di SharedPreferences dengan key `quick_action_visibility`.

### Q: Bagaimana jika modul dinonaktifkan?

**A:** Quick actions dari modul yang tidak aktif tidak akan muncul, karena hanya `activeModules` yang diproses.

---

## Quick Actions di External Module (SubModule)

External module (repository terpisah) juga dapat menyediakan quick actions. Prosesnya sama dengan internal module, namun ada beberapa hal yang perlu diperhatikan.

### Contoh: super_module

Repository: [https://github.com/luridarmawan/super_app_module](https://github.com/luridarmawan/super_app_module)

Lokasi setelah clone: `modules/super_module/`

#### Struktur File

```
modules/super_module/
├── lib/
│   ├── super_module.dart           # Export file
│   ├── super_module_module.dart    # Module definition + Quick Actions
│   └── screens/
│       └── super_module_screen.dart
└── pubspec.yaml
```

#### Implementasi Quick Actions

```dart
// modules/super_module/lib/super_module_module.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_interface/module_interface.dart';

class SuperModuleModule extends BaseModule {
  @override
  String get name => 'super_module';

  @override
  String get displayName => 'Super Module';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Super Module for Super App';

  @override
  IconData get icon => Icons.science;

  // Quick Actions definition
  @override
  List<QuickActionItem> get quickActions => [
    // Quick action 1: Navigate to main screen
    QuickActionItem(
      id: 'super_module_quick',        // Unique ID
      moduleId: 'super_module',         // Module ID (must match `name`)
      label: 'Super Module',
      icon: Icons.science,
      route: '/super-module',           // Route path (defined in `routes`)
      order: 50,                        // Sorting order
      description: 'Explore Super Module',
    ),
    
    // Quick action 2: Navigate to detail screen
    QuickActionItem(
      id: 'super_module_detail',
      moduleId: 'super_module',
      label: 'Detail Super',
      icon: Icons.info_outline,
      color: const Color(0xFF00BFA5),   // Custom color
      route: '/super-module/detail/2',  // Route with parameter
      order: 51,
      description: 'View super item 2',
    ),
  ];

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: '/super-module',
      name: 'super_module',
      builder: (context, state) => const DemoScreen(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          name: 'super_module_detail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '0';
            return DemoDetailScreen(id: id);
          },
        ),
      ],
    ),
  ];

  // ... other overrides
}
```

### Langkah Menambahkan Quick Actions ke External Module

1. **Pastikan import `module_interface`**

```dart
import 'package:module_interface/module_interface.dart';
```

2. **Override getter `quickActions`**

```dart
@override
List<QuickActionItem> get quickActions => [
  QuickActionItem(
    id: '${name}_action1',  // Format: {moduleId}_{actionName}
    moduleId: name,
    label: 'My Action',
    icon: Icons.star,
    route: '/my-module/action',
    order: 100,
    description: 'Description for manager screen',
  ),
];
```

3. **Pastikan route sudah terdaftar**

Quick action dengan `route` memerlukan route yang sesuai di getter `routes`:

```dart
@override
List<RouteBase> get routes => [
  GoRoute(
    path: '/my-module/action',  // Harus match dengan route di QuickActionItem
    builder: (context, state) => const MyActionScreen(),
  ),
];
```

4. **Daftarkan module di main app**

Setelah clone external module, daftarkan di `lib/modules/all_modules.dart`:

```dart
import 'package:super_module/super_module_module.dart';

class ModuleManifest {
  static void register() {
    // Internal modules
    ModuleRegistry.register(SampleModule());
    
    // External modules
    ModuleRegistry.register(SuperModuleModule());
  }
}
```

### Quick Actions dengan Custom Callback

External module juga dapat menggunakan custom callback:

```dart
QuickActionItem(
  id: 'super_module_scan',
  moduleId: 'super_module',
  label: 'Scan',
  icon: Icons.qr_code_scanner,
  color: const Color(0xFF2E7D32),
  onTap: (context) {
    // Custom action - dialog, snackbar, etc.
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Scanner'),
        content: const Text('Opening scanner...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  },
  order: 52,
  description: 'Scan QR code',
),
```

### Perbedaan Internal vs External Module

| Aspek | Internal Module | External Module |
|-------|-----------------|-----------------|
| Lokasi | `lib/modules/` | `modules/` (root) |
| Import | `import '../quick_action_item.dart'` | `import 'package:module_interface/module_interface.dart'` |
| Repository | Sama dengan main app | Terpisah |
| Contoh | `lib/modules/sample/` | `modules/super_module/` |

---

## Lihat Juga

- **[Modular.md](./Modular.md)** - Arsitektur modular lengkap
- **[SubModule.md](./SubModule.md)** - Panduan external modules
- **[README.md](../README.md)** - Dokumentasi utama project

---

*Dibuat: 30 Desember 2025*
*Diperbarui: 1 Januari 2026*
*Versi: 1.2.0*
