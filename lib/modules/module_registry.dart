import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'quick_action_item.dart';

/// Registry for managing pluggable modules.
/// 
/// Handles module registration, initialization, and provides
/// aggregated routes, widgets, and menu items from all active modules.
/// 
/// Usage:
/// ```dart
/// // In main.dart
/// void main() async {
///   // Register modules
///   ModuleRegistry.register(NewsModule());
///   ModuleRegistry.register(EcommerceModule());
///   
///   // Initialize active modules
///   await ModuleRegistry.initializeAll();
///   
///   runApp(MyApp());
/// }
/// ```
class ModuleRegistry {
  ModuleRegistry._();

  static final List<BaseModule> _modules = [];
  static bool _initialized = false;

  // ============================================
  // REGISTRATION
  // ============================================

  /// Register a module with the registry.
  /// Modules should be registered before calling initializeAll().
  static void register(BaseModule module) {
    if (_modules.any((m) => m.name == module.name)) {
      debugPrint('⚠️ Module "${module.name}" is already registered, skipping.');
      return;
    }
    _modules.add(module);
    debugPrint('📦 Registered module: ${module.name} v${module.version}');
  }

  /// Register multiple modules at once
  static void registerAll(List<BaseModule> modules) {
    for (final module in modules) {
      register(module);
    }
  }

  /// Unregister a module by name
  static void unregister(String moduleName) {
    _modules.removeWhere((m) => m.name == moduleName);
    debugPrint('📦 Unregistered module: $moduleName');
  }

  /// Clear all registered modules
  static void clear() {
    _modules.clear();
    _initialized = false;
    debugPrint('📦 Cleared all modules');
  }

  // ============================================
  // MODULE ACCESS
  // ============================================

  /// Get all registered modules (active and inactive)
  static List<BaseModule> get allModules => List.unmodifiable(_modules);

  /// Get only active modules (enabled via .env feature flags)
  static List<BaseModule> get activeModules {
    return _modules.where((m) => isModuleEnabled(m.name)).toList();
  }

  /// Get a specific module by name
  static BaseModule? getModule(String name) {
    try {
      return _modules.firstWhere((m) => m.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Check if a module is registered
  static bool isRegistered(String moduleName) {
    return _modules.any((m) => m.name == moduleName);
  }

  /// Check if a module is enabled via .env feature flag
  /// Looks for: ENABLE_MODULE_{NAME} = true
  static bool isModuleEnabled(String moduleName) {
    final envKey = 'ENABLE_MODULE_${moduleName.toUpperCase()}';
    final value = dotenv.env[envKey]?.toLowerCase();
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Check if a module is both registered AND enabled
  static bool isModuleActive(String moduleName) {
    return isRegistered(moduleName) && isModuleEnabled(moduleName);
  }

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Initialize all active modules.
  /// Respects dependency order - modules with dependencies are initialized after their dependencies.
  static Future<void> initializeAll() async {
    if (_initialized) {
      debugPrint('⚠️ ModuleRegistry already initialized');
      return;
    }

    final active = activeModules;
    debugPrint('🚀 Initializing ${active.length} active modules...');

    // Sort by dependencies (topological sort)
    final sorted = _sortByDependencies(active);

    // Validate all modules first
    for (final module in sorted) {
      final error = module.validate();
      if (error != null) {
        debugPrint('❌ Module "${module.name}" validation failed: $error');
        continue;
      }
    }

    // Initialize in order
    for (final module in sorted) {
      try {
        await module.initialize();
        debugPrint('✅ Initialized: ${module.name}');
      } catch (e) {
        debugPrint('❌ Failed to initialize ${module.name}: $e');
      }
    }

    _initialized = true;
    debugPrint('🎉 Module initialization complete');
  }

  /// Dispose all active modules
  static Future<void> disposeAll() async {
    debugPrint('🧹 Disposing all modules...');
    for (final module in activeModules.reversed) {
      try {
        await module.dispose();
        debugPrint('✅ Disposed: ${module.name}');
      } catch (e) {
        debugPrint('❌ Failed to dispose ${module.name}: $e');
      }
    }
    _initialized = false;
  }

  /// Notify all modules that user has logged in
  static Future<void> notifyUserLogin() async {
    for (final module in activeModules) {
      try {
        await module.onUserLogin();
      } catch (e) {
        debugPrint('❌ ${module.name}.onUserLogin failed: $e');
      }
    }
  }

  /// Notify all modules that user has logged out
  static Future<void> notifyUserLogout() async {
    for (final module in activeModules) {
      try {
        await module.onUserLogout();
      } catch (e) {
        debugPrint('❌ ${module.name}.onUserLogout failed: $e');
      }
    }
  }

  // ============================================
  // ROUTES
  // ============================================

  /// Get all routes from active modules
  static List<RouteBase> get allRoutes {
    final routes = <RouteBase>[];
    for (final module in activeModules) {
      routes.addAll(module.routes);
    }
    return routes;
  }

  // ============================================
  // PROVIDERS
  // ============================================

  /// Get all provider overrides from active modules
  static List<Override> get allProviderOverrides {
    final overrides = <Override>[];
    for (final module in activeModules) {
      overrides.addAll(module.providerOverrides);
    }
    return overrides;
  }

  // ============================================
  // DASHBOARD WIDGETS
  // ============================================

  /// Get dashboard widgets from active modules
  /// Sorted by order (lower order = appears first)
  /// Now supports multiple widgets per module via [dashboardWidgets] property.
  static List<Widget> get dashboardWidgets {
    final widgets = <_OrderedWidget>[];

    for (final module in activeModules) {
      final moduleWidgets = module.dashboardWidgets;
      final moduleConfigs = module.dashboardConfigs;

      for (var i = 0; i < moduleWidgets.length; i++) {
        final config = i < moduleConfigs.length
            ? moduleConfigs[i]
            : const DashboardWidgetConfig();
        widgets.add(_OrderedWidget(
          widget: moduleWidgets[i],
          order: config.order,
        ));
      }
    }
    
    // Sort by order
    widgets.sort((a, b) => a.order.compareTo(b.order));
    
    return widgets.map((w) => w.widget).toList();
  }

  /// Get dashboard widget configs from active modules
  static List<DashboardWidgetConfig> get dashboardConfigs {
    final configs = <DashboardWidgetConfig>[];
    for (final module in activeModules) {
      configs.addAll(module.dashboardConfigs);
    }
    return configs;
  }

  // ============================================
  // NAVIGATION ITEMS
  // ============================================

  /// Get all menu items from active modules
  /// Sorted by order (lower order = appears first)
  static List<NavigationItem> get menuItems {
    final items = <NavigationItem>[];
    
    for (final module in activeModules) {
      items.addAll(module.menuItems);
    }
    
    // Sort by order
    items.sort((a, b) => a.order.compareTo(b.order));
    
    return items;
  }

  /// Get menu items that don't require authentication
  static List<NavigationItem> get publicMenuItems {
    return menuItems.where((item) => !item.requiresAuth).toList();
  }

  /// Get menu items that require authentication
  static List<NavigationItem> get protectedMenuItems {
    return menuItems.where((item) => item.requiresAuth).toList();
  }

  // ============================================
  // QUICK ACTIONS
  // ============================================

  /// Get all quick actions from active modules
  /// Sorted by order (lower order = appears first)
  static List<QuickActionItem> get allQuickActions {
    final actions = <QuickActionItem>[];
    
    // Add static quick actions first
    actions.addAll(StaticQuickActions.items);
    
    // Add quick actions from active modules
    for (final module in activeModules) {
      actions.addAll(module.quickActions);
    }
    
    // Sort by order
    actions.sort((a, b) => a.order.compareTo(b.order));
    
    return actions;
  }

  /// Get quick actions from modules only (without static actions)
  static List<QuickActionItem> get moduleQuickActions {
    final actions = <QuickActionItem>[];
    
    for (final module in activeModules) {
      actions.addAll(module.quickActions);
    }
    
    // Sort by order
    actions.sort((a, b) => a.order.compareTo(b.order));
    
    return actions;
  }

  /// Get quick actions by module ID
  static List<QuickActionItem> getQuickActionsByModule(String moduleId) {
    if (moduleId == StaticQuickActions.moduleId) {
      return StaticQuickActions.items;
    }
    
    final module = getModule(moduleId);
    return module?.quickActions ?? [];
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Sort modules by their dependencies (topological sort)
  static List<BaseModule> _sortByDependencies(List<BaseModule> modules) {
    final sorted = <BaseModule>[];
    final visited = <String>{};
    final visiting = <String>{};

    void visit(BaseModule module) {
      if (visited.contains(module.name)) return;
      if (visiting.contains(module.name)) {
        debugPrint('⚠️ Circular dependency detected for ${module.name}');
        return;
      }

      visiting.add(module.name);

      for (final depName in module.dependencies) {
        final dep = modules.firstWhere(
          (m) => m.name == depName,
          orElse: () => throw Exception('Missing dependency: $depName'),
        );
        visit(dep);
      }

      visiting.remove(module.name);
      visited.add(module.name);
      sorted.add(module);
    }

    for (final module in modules) {
      visit(module);
    }

    return sorted;
  }

  /// Print debug info about registered modules
  static void printDebugInfo() {
    debugPrint('╔══════════════════════════════════════════╗');
    debugPrint('║         MODULE REGISTRY STATUS           ║');
    debugPrint('╠══════════════════════════════════════════╣');
    debugPrint('║ Total Registered: ${_modules.length.toString().padLeft(2)}                     ║');
    debugPrint('║ Active Modules:   ${activeModules.length.toString().padLeft(2)}                     ║');
    debugPrint('║ Initialized:      ${_initialized ? 'Yes' : 'No '}                    ║');
    debugPrint('╠══════════════════════════════════════════╣');
    
    for (final module in _modules) {
      final status = isModuleEnabled(module.name) ? '✅' : '❌';
      final name = module.name.padRight(20);
      debugPrint('║ $status $name v${module.version.padRight(8)} ║');
    }
    
    debugPrint('╚══════════════════════════════════════════╝');
  }
}

/// Helper class for sorting widgets by order
class _OrderedWidget {
  final Widget widget;
  final int order;
  
  _OrderedWidget({required this.widget, required this.order});
}

// ============================================
// RIVERPOD PROVIDERS
// ============================================

/// Provider for accessing the module registry
final moduleRegistryProvider = Provider<ModuleRegistry>((ref) {
  return ModuleRegistry._();
});

/// Provider for getting active modules
final activeModulesProvider = Provider<List<BaseModule>>((ref) {
  return ModuleRegistry.activeModules;
});

/// Provider for getting all module routes
final moduleRoutesProvider = Provider<List<RouteBase>>((ref) {
  return ModuleRegistry.allRoutes;
});

/// Provider for getting dashboard widgets from modules
final moduleDashboardWidgetsProvider = Provider<List<Widget>>((ref) {
  return ModuleRegistry.dashboardWidgets;
});

/// Provider for getting menu items from modules
final moduleMenuItemsProvider = Provider<List<NavigationItem>>((ref) {
  return ModuleRegistry.menuItems;
});

/// Provider for getting all quick actions (static + modules)
final allQuickActionsProvider = Provider<List<QuickActionItem>>((ref) {
  return ModuleRegistry.allQuickActions;
});

/// Provider for getting quick actions from modules only
final moduleQuickActionsProvider = Provider<List<QuickActionItem>>((ref) {
  return ModuleRegistry.moduleQuickActions;
});
