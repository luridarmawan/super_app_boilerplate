import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../module_base.dart';
import '../navigation_item.dart';
import '../quick_action_item.dart';
import 'screens/news_screen.dart';
import 'widgets/news_dashboard_card.dart';

/// News Module
///
/// To enable this module, add to your .env file:
/// ```
/// ENABLE_MODULE_NEWS=true
/// ```
class NewsModule extends BaseModule {
  @override
  String get name => 'news';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'News module';

  @override
  String get displayName => 'News';

  @override
  IconData get icon => Icons.widgets;

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: '/news',
      name: 'news',
      builder: (context, state) => const NewsScreen(),
    ),
  ];

  @override
  Widget? get dashboardWidget => const NewsDashboardCard();

  @override
  DashboardWidgetConfig get dashboardConfig => const DashboardWidgetConfig(
    columnSpan: 1,
    rowSpan: 1,
    order: 100,
  );

  @override
  List<NavigationItem> get menuItems => [
    NavigationItem(
      id: 'news',
      label: 'News',
      icon: Icons.widgets_outlined,
      selectedIcon: Icons.widgets,
      route: '/news',
      order: 100,
      requiresAuth: true,
    ),
  ];

  @override
  List<QuickActionItem> get quickActions => [
    // Example: Route-based quick action
    QuickActionItem(
      id: 'news_main',
      moduleId: name,
      icon: Icons.widgets_outlined,
      label: 'News',
      color: const Color(0xFF1565C0),
      route: '/news',
      order: 100,
      description: 'Open News module',
    ),
    // Example: Custom callback quick action (uncomment if needed)
    // QuickActionItem(
    //   id: 'news_action',
    //   moduleId: name,
    //   icon: Icons.flash_on_outlined,
    //   label: 'Quick Action',
    //   color: const Color(0xFFFF6D00),
    //   onTap: (context) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Quick action!')),
    //     );
    //   },
    //   order: 101,
    //   description: 'Execute quick action',
    // ),
  ];

  @override
  List<String> get dependencies => [];

  @override
  Future<void> initialize() async {
    debugPrint('NewsModule: Initializing...');
    // Add initialization logic here
  }

  @override
  Future<void> dispose() async {
    debugPrint('NewsModule: Disposing...');
    // Add cleanup logic here
  }

  @override
  Future<void> onUserLogin() async {
    debugPrint('NewsModule: User logged in');
    // Load user-specific data
  }

  @override
  Future<void> onUserLogout() async {
    debugPrint('NewsModule: User logged out');
    // Clear user-specific data
  }
}
