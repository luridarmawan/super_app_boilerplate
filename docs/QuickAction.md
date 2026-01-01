# Quick Action

Quick Actions is a feature that allows each module to provide quick actions displayed in a menu grid on the dashboard.

> **📚 Related Documents:**
> - **[Modular.md](./Modular.md)** - Modular architecture (BaseModule, registry)
> - **[SubModule.md](./SubModule.md)** - External modules guide

---

## Table of Contents

1. [Introduction](#introduction)
2. [Main Features](#main-features)
3. [How to Use](#how-to-use)
   - [Adding Quick Actions to a Module](#adding-quick-actions-to-a-module)
   - [Displaying Quick Actions on Dashboard](#displaying-quick-actions-on-dashboard)
4. [QuickActionItem Model](#quickactionitem-model)
5. [Visibility Configuration](#visibility-configuration)
6. [Static Quick Actions](#static-quick-actions)
7. [Quick Actions Manager](#quick-actions-manager)
8. [Implementation Examples](#implementation-examples)
9. [**Quick Actions in External Module (SubModule)**](#quick-actions-in-external-module-submodule) ⭐ NEW

---

## Introduction

Quick Actions are icons/buttons displayed on the dashboard in a grid format. This feature allows:

- **Each module** can provide **more than one quick action**
- Users can **enable/disable** individual quick actions
- Supports **route navigation** or **custom callbacks**
- Automatically shows a **"More"** button if quick actions exceed the limit

---

## Main Features

| Feature | Description |
|---------|-------------|
| **Multi-action per module** | Each module can have more than one quick action |
| **Route Navigation** | Quick action can navigate to a specific page |
| **Custom Callback** | Quick action can execute custom functions (dialog, snackbar, etc.) |
| **Visibility Control** | Users can show/hide individual quick actions |
| **Persistence** | Visibility settings are saved in SharedPreferences |
| **Auto "More"** | "More" button automatically appears when actions exceed the limit |
| **Backward Compatible** | Legacy `MenuItem` is still supported |

---

## How to Use

### Adding Quick Actions to a Module

Override the `quickActions` getter in your module:

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

### Displaying Quick Actions on Dashboard

Use the `QuickActionGrid` or `QuickActionSection` widget:

```dart
// In dashboard widget

// Option 1: Grid only (More always visible)
QuickActionGrid(
  maxItems: 8,           // Maximum items before auto-truncation
  crossAxisCount: 4,     // Number of columns
  alwaysShowMore: true,  // "More" button always visible (default: true)
)

// Option 2: More only appears if items > maxItems
QuickActionGrid(
  maxItems: 8,
  alwaysShowMore: false,
)

// Option 3: With section header
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

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | String | ✅ | - | Unique identifier. Format: `{moduleId}_{actionName}` |
| `moduleId` | String | ✅ | - | ID of the module providing this action |
| `icon` | IconData | ✅ | - | Icon to display |
| `label` | String | ✅ | - | Label text |
| `color` | Color? | ❌ | Primary | Icon color |
| `route` | String? | ⚠️ | - | Navigation route (required if no onTap) |
| `onTap` | Function? | ⚠️ | - | Custom callback (required if no route) |
| `order` | int | ❌ | 100 | Sorting order (lower = appears first) |
| `enabledByDefault` | bool | ❌ | true | Default visibility |
| `description` | String? | ❌ | - | Description for manager screen |

---

## Visibility Configuration

### Providers

```dart
// Get all quick actions (static + modules)
final allActions = ref.watch(allQuickActionsProvider);

// Get visibility state
final visibility = ref.watch(quickActionVisibilityProvider);

// Get only visible quick actions
final visibleActions = ref.watch(visibleQuickActionsProvider);

// Get quick actions for grid (with limit)
final gridActions = ref.watch(menuGridQuickActionsProvider(8));

// Check if "More" button needs to be displayed
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

Default quick actions that are always available, defined in `lib/modules/quick_action_item.dart`:

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

Static actions can be customized by editing that file.

---

## Quick Actions Manager

A page to manage quick action visibility is available at route `/quick-actions`.

### Manager Features

- View all quick actions (grouped by module)
- Toggle individual visibility
- Show/Hide all
- Reset to default

### Navigate to Manager

```dart
// Via route
context.push('/quick-actions');

// Or via constant
context.push(AppRoutes.quickActions);
```

---

## Implementation Examples

### Sample Module with Quick Actions

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

## Related Files

| File | Description |
|------|-------------|
| `lib/modules/quick_action_item.dart` | QuickActionItem model and StaticQuickActions |
| `lib/modules/module_base.dart` | BaseModule with quickActions getter |
| `lib/modules/module_registry.dart` | Providers for collecting quick actions |
| `lib/features/dashboard/widgets/menu_grid.dart` | QuickActionGrid and QuickActionSection widgets |
| `lib/features/dashboard/providers/quick_action_visibility_provider.dart` | State management for visibility |
| `lib/features/dashboard/screens/quick_actions_manager_screen.dart` | Manager page |
| `lib/core/routes/app_router.dart` | Route for quick-actions manager |

---

## FAQ

### Q: How do I add a new quick action to a module?

**A:** Override the `quickActions` getter in your module class and add a new `QuickActionItem` to the list.

### Q: Can I use custom callback and route at the same time?

**A:** Yes, but `onTap` will be prioritized. If `onTap` exists, route will be ignored.

### Q: How is the order of quick actions determined?

**A:** Based on the `order` field. Lower value = appears first. Static actions have order 1-7, so use order >= 100 for module actions.

### Q: Are visibility settings persistent?

**A:** Yes, saved in SharedPreferences with key `quick_action_visibility`.

### Q: What happens if a module is disabled?

**A:** Quick actions from inactive modules won't appear, since only `activeModules` are processed.

---

## Quick Actions in External Module (SubModule)

External modules (separate repositories) can also provide quick actions. The process is the same as internal modules, but there are some things to note.

### Example: super_module

Repository: [https://github.com/luridarmawan/super_app_module](https://github.com/luridarmawan/super_app_module)

Location after clone: `modules/super_module/`

#### File Structure

```
modules/super_module/
├── lib/
│   ├── super_module.dart           # Export file
│   ├── super_module_module.dart    # Module definition + Quick Actions
│   └── screens/
│       └── super_module_screen.dart
└── pubspec.yaml
```

#### Quick Actions Implementation

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

### Steps to Add Quick Actions to External Module

1. **Make sure to import `module_interface`**

```dart
import 'package:module_interface/module_interface.dart';
```

2. **Override the `quickActions` getter**

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

3. **Make sure the route is registered**

Quick actions with `route` require a matching route in the `routes` getter:

```dart
@override
List<RouteBase> get routes => [
  GoRoute(
    path: '/my-module/action',  // Must match route in QuickActionItem
    builder: (context, state) => const MyActionScreen(),
  ),
];
```

4. **Register the module in main app**

After cloning the external module, register it in `lib/modules/all_modules.dart`:

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

### Quick Actions with Custom Callback

External modules can also use custom callbacks:

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

### Differences: Internal vs External Module

| Aspect | Internal Module | External Module |
|--------|-----------------|-----------------|
| Location | `lib/modules/` | `modules/` (root) |
| Import | `import '../quick_action_item.dart'` | `import 'package:module_interface/module_interface.dart'` |
| Repository | Same as main app | Separate |
| Example | `lib/modules/sample/` | `modules/super_module/` |

---

## See Also

- **[Modular.md](./Modular.md)** - Complete modular architecture
- **[SubModule.md](./SubModule.md)** - External modules guide
- **[README.md](../README.md)** - Main project documentation

---

*Updated: January 1, 2026*
*Version: 1.2.0*
