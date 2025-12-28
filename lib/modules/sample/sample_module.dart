import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../module_base.dart';
import '../navigation_item.dart';
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
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/sample'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.widgets,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Sample Module',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to explore',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
