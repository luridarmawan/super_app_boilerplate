import 'package:flutter/material.dart';

/// Represents a navigation menu item that modules can provide
/// for sidebar, bottom navigation, or other navigation components.
class NavigationItem {
  /// Unique identifier for this navigation item
  final String id;

  /// Display label for the menu item
  final String label;

  /// Icon to display
  final IconData icon;

  /// Optional: Filled/selected icon variant
  final IconData? selectedIcon;

  /// Route path to navigate to when tapped
  final String route;

  /// Order/priority for sorting (lower = appears first)
  final int order;

  /// Whether this item requires authentication
  final bool requiresAuth;

  /// Optional badge count (for notifications, cart items, etc.)
  final int? badgeCount;

  /// Whether this item is currently enabled
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

  /// Creates a copy with updated badge count
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
