import 'package:flutter/material.dart';

class NavigationItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String route;
  final int order;
  final bool requiresAuth;
  final int? badgeCount;
  final bool enabled;

  const NavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.selectedIcon,
    this.order = 100,
    this.requiresAuth = false,
    this.badgeCount,
    this.enabled = true,
  });

  NavigationItem copyWithBadge(int? count) {
    return NavigationItem(
      id: id,
      label: label,
      icon: icon,
      route: route,
      selectedIcon: selectedIcon,
      order: order,
      requiresAuth: requiresAuth,
      badgeCount: count,
      enabled: enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
