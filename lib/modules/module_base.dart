import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'navigation_item.dart';
import 'quick_action_item.dart';

/// Base abstract class for all pluggable modules.
/// 
/// Each module must extend this class and implement required methods.
/// Modules are self-contained units that can provide:
/// - Routes for navigation
/// - Providers for state management
/// - Widgets for dashboard
/// - Menu items for navigation
/// 
/// Example implementation:
/// ```dart
/// class NewsModule extends BaseModule {
///   @override
///   String get name => 'news';
///   
///   @override
///   String get version => '1.0.0';
///   
///   @override
///   List<RouteBase> get routes => [
///     GoRoute(path: '/news', builder: (_, __) => NewsScreen()),
///   ];
/// }
/// ```
abstract class BaseModule {
  /// Unique identifier for the module (lowercase, no spaces)
  /// Used for feature flags: ENABLE_MODULE_{NAME.toUpperCase()}
  String get name;

  /// Module version (semantic versioning recommended)
  String get version;

  /// Brief description of what the module does
  String get description;

  /// Display name shown in UI (can be localized)
  String get displayName => name.substring(0, 1).toUpperCase() + name.substring(1);

  /// Icon representing this module
  IconData get icon => Icons.extension;

  /// Routes provided by this module
  /// These will be automatically registered with GoRouter
  List<RouteBase> get routes => [];

  /// Provider overrides for dependency injection
  /// Use this to provide module-specific implementations
  List<Override> get providerOverrides => [];

  /// Widget to display on the main dashboard
  /// Return null if this module doesn't have a dashboard widget
  Widget? get dashboardWidget => null;

  /// Dashboard widget configuration
  /// Override to customize size and position
  DashboardWidgetConfig get dashboardConfig => const DashboardWidgetConfig();

  /// Navigation menu items provided by this module
  /// These will appear in sidebar, bottom nav, etc.
  List<NavigationItem> get menuItems => [];

  /// Quick action items provided by this module
  /// These will appear in the dashboard menu grid
  /// Each module can provide multiple quick actions
  List<QuickActionItem> get quickActions => [];

  /// List of module names this module depends on
  /// Registry will ensure dependencies are initialized first
  List<String> get dependencies => [];

  /// Called when the module is being initialized
  /// Use for setup: loading cache, initializing services, etc.
  Future<void> initialize() async {}

  /// Called when the module is being disposed
  /// Use for cleanup: clearing cache, closing connections, etc.
  Future<void> dispose() async {}

  /// Called when user logs in
  /// Override to perform module-specific login actions
  Future<void> onUserLogin() async {}

  /// Called when user logs out
  /// Override to clear module-specific user data
  Future<void> onUserLogout() async {}

  /// Check if this module is properly configured
  /// Return error message if not, null if OK
  String? validate() => null;

  @override
  String toString() => 'Module($name v$version)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseModule &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// Configuration for dashboard widget appearance
class DashboardWidgetConfig {
  /// Number of columns this widget spans (1-4)
  final int columnSpan;

  /// Number of rows this widget spans (1-4)
  final int rowSpan;

  /// Order/priority for sorting (lower = appears first)
  final int order;

  /// Minimum height in pixels
  final double? minHeight;

  /// Maximum height in pixels
  final double? maxHeight;

  const DashboardWidgetConfig({
    this.columnSpan = 1,
    this.rowSpan = 1,
    this.order = 100,
    this.minHeight,
    this.maxHeight,
  });
}
