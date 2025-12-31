import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'navigation_item.dart';
import 'quick_action_item.dart';

/// Base abstract class for all pluggable modules.
abstract class BaseModule {
  String get name;
  String get version;
  String get description;
  String get displayName => name.substring(0, 1).toUpperCase() + name.substring(1);
  IconData get icon => Icons.extension;
  List<RouteBase> get routes => [];
  List<Override> get providerOverrides => [];
  Widget? get dashboardWidget => null;
  DashboardWidgetConfig get dashboardConfig => const DashboardWidgetConfig();
  List<NavigationItem> get menuItems => [];
  List<QuickActionItem> get quickActions => [];
  List<String> get dependencies => [];
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<void> onUserLogin() async {}
  Future<void> onUserLogout() async {}
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

class DashboardWidgetConfig {
  final int columnSpan;
  final int rowSpan;
  final int order;
  final double? minHeight;
  final double? maxHeight;

  const DashboardWidgetConfig({
    this.columnSpan = 1,
    this.rowSpan = 1,
    this.order = 100,
    this.minHeight,
    this.maxHeight,
  });
}
