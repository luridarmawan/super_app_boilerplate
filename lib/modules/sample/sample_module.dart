import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/workspace_icon.dart';
import 'package:module_interface/module_interface.dart';
import 'screens/sample_screen.dart';

/// Sample module demonstrating how to create a pluggable module.
/// 
/// This module serves as a template/reference for creating new modules.
/// 
/// To enable this module, add to your .env file:
/// ```
/// ENABLE_MODULE_SAMPLE=true
/// ```
class SampleModule extends BaseModule {
  @override
  String get name => 'sample';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'A sample module demonstrating the modular architecture';

  @override
  String get displayName => 'Sample Module';

  @override
  IconData get icon => Icons.widgets;

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: '/sample',
      name: 'sample',
      builder: (context, state) => const SampleScreen(),
    ),
    GoRoute(
      path: '/sample/detail/:id',
      name: 'sample-detail',
      builder: (context, state) => SampleDetailScreen(
        id: state.pathParameters['id'] ?? '',
      ),
    ),
  ];

  @override
  Widget? get dashboardWidget => const SampleDashboardCard();

  @override
  DashboardWidgetConfig get dashboardConfig => const DashboardWidgetConfig(
    columnSpan: 1,
    rowSpan: 1,
    order: 50, // Lower order = appears first
  );

  @override
  List<NavigationItem> get menuItems => [
    const NavigationItem(
      id: 'sample',
      label: 'Sample',
      icon: Icons.widgets_outlined,
      selectedIcon: Icons.widgets,
      route: '/sample',
      order: 50,
      requiresAuth: true,
    ),
  ];

  @override
  List<QuickActionItem> get quickActions => [
    // Example: Route-based quick action
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
    // Example: Custom callback quick action
    QuickActionItem(
      id: 'sample_action',
      moduleId: name,
      icon: Icons.flash_on_outlined,
      label: 'Quick',
      color: const Color(0xFFFF6D00),
      onTap: (context) {
        // Custom action - show a snackbar
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
    // Example: Another route-based action
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

  @override
  List<String> get dependencies => []; // No dependencies

  @override
  Future<void> initialize() async {
    debugPrint('SampleModule: Initializing...');
    // Add initialization logic here:
    // - Load cached data
    // - Initialize services
    // - Register listeners
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('SampleModule: Ready!');
  }

  @override
  Future<void> dispose() async {
    debugPrint('SampleModule: Disposing...');
    // Add cleanup logic here
  }

  @override
  Future<void> onUserLogin() async {
    debugPrint('SampleModule: User logged in');
    // Load user-specific data
  }

  @override
  Future<void> onUserLogout() async {
    debugPrint('SampleModule: User logged out');
    // Clear user-specific data
  }

  @override
  String? validate() {
    // Return error message if module is not properly configured
    // Return null if everything is OK
    return null;
  }
}

/// Dashboard card widget for the Sample module
class SampleDashboardCard extends StatelessWidget {
  const SampleDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkspaceIcon(
      pushUrl: '/sample',
      title: 'Sample Module',
      subTitle: 'Tap to explore',
      icon: Icons.widgets,
    );
  }
}
