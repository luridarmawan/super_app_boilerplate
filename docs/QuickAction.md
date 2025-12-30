# Quick Action

Quick Actions adalah fitur yang memungkinkan setiap modul menyediakan aksi cepat yang ditampilkan dalam grid menu di dashboard.

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

---

## Pendahuluan

Quick Actions adalah aksi cepat berupa ikon/tombol yang ditampilkan di dashboard dalam format grid. Fitur ini memungkinkan:

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
