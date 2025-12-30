import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/workspace_icon.dart';
import '../module_base.dart';
import '../navigation_item.dart';
import '../quick_action_item.dart';
import 'screens/demo_screen.dart';

/// Demo module/workspace located in the same directory as Sample module.
/// This demonstrates that a module (logical grouping) can have multiple 
/// workspaces (visible entries in the dashboard).
class DemoModule extends BaseModule {
  @override
  String get name => 'demo';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'A demo workspace showing multiple workspaces per module';

  @override
  String get displayName => 'Demo Workspace';

  @override
  IconData get icon => Icons.science;

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: '/demo',
      name: 'demo',
      builder: (context, state) => const DemoScreen(),
    ),
  ];

  @override
  Widget? get dashboardWidget => const DemoDashboardCard();

  @override
  DashboardWidgetConfig get dashboardConfig => const DashboardWidgetConfig(
    columnSpan: 1,
    rowSpan: 1,
    order: 51, // Appears after Sample (order 50)
  );

  @override
  List<NavigationItem> get menuItems => [
    const NavigationItem(
      id: 'demo',
      label: 'Demo',
      icon: Icons.science_outlined,
      selectedIcon: Icons.science,
      route: '/demo',
      order: 51,
      requiresAuth: true,
    ),
  ];

  @override
  List<QuickActionItem> get quickActions => [
    QuickActionItem(
      id: 'demo_start',
      moduleId: name,
      icon: Icons.play_circle_outline,
      label: 'Demo Start',
      color: const Color(0xFFE91E63),
      route: '/demo',
      order: 200,
      description: 'Start demo features',
    ),
  ];

  @override
  Future<void> initialize() async {
    debugPrint('DemoModule: Initializing...');
  }
}

/// Dashboard card widget for the Demo workspace
class DemoDashboardCard extends StatelessWidget {
  const DemoDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkspaceIcon(
      pushUrl: '/demo',
      title: 'Demo Workspace',
      subTitle: 'Experimental features',
      icon: Icons.science,
    );
  }
}
