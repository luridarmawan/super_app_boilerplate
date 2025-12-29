import 'package:flutter/material.dart';

/// Callback type for quick action tap events
/// Receives BuildContext to allow navigation, dialogs, etc.
typedef QuickActionCallback = void Function(BuildContext context);

/// Represents a quick action item that modules can provide
/// for display in the dashboard menu grid.
///
/// Quick actions can either navigate to a route or execute
/// a custom callback function.
///
/// Example:
/// ```dart
/// QuickActionItem(
///   id: 'payment_pay',
///   moduleId: 'payment',
///   icon: Icons.payments,
///   label: 'Pay',
///   color: Color(0xFF1565C0),
///   route: '/payment/pay',
///   order: 10,
/// )
/// ```
class QuickActionItem {
  /// Unique identifier for this quick action
  /// Format recommendation: {moduleId}_{actionName}
  final String id;

  /// Module ID that provides this quick action
  /// Used for grouping and filtering
  final String moduleId;

  /// Icon to display
  final IconData icon;

  /// Display label for the action
  final String label;

  /// Optional color for the icon
  /// If null, uses theme primary color
  final Color? color;

  /// Route path to navigate to when tapped
  /// Either route or onTap should be provided
  final String? route;

  /// Custom callback function when tapped
  /// Takes precedence over route if both are provided
  final QuickActionCallback? onTap;

  /// Order/priority for sorting (lower = appears first)
  final int order;

  /// Whether this action is enabled by default
  /// User can toggle visibility in Quick Actions Manager
  final bool enabledByDefault;

  /// Optional description for the Quick Actions Manager
  final String? description;

  const QuickActionItem({
    required this.id,
    required this.moduleId,
    required this.icon,
    required this.label,
    this.color,
    this.route,
    this.onTap,
    this.order = 100,
    this.enabledByDefault = true,
    this.description,
  }) : assert(
          route != null || onTap != null,
          'Either route or onTap must be provided',
        );

  /// Creates a copy with updated properties
  QuickActionItem copyWith({
    String? id,
    String? moduleId,
    IconData? icon,
    String? label,
    Color? color,
    String? route,
    QuickActionCallback? onTap,
    int? order,
    bool? enabledByDefault,
    String? description,
  }) {
    return QuickActionItem(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      icon: icon ?? this.icon,
      label: label ?? this.label,
      color: color ?? this.color,
      route: route ?? this.route,
      onTap: onTap ?? this.onTap,
      order: order ?? this.order,
      enabledByDefault: enabledByDefault ?? this.enabledByDefault,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickActionItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'QuickActionItem($id, $label)';
}

/// Static quick actions that are always available
/// These are the default actions shown in the menu grid
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
          description: 'Make payments',
        ),
        QuickActionItem(
          id: 'static_bills',
          moduleId: moduleId,
          icon: Icons.receipt_long_outlined,
          label: 'Bills',
          color: Color(0xFF2E7D32),
          route: '/bills',
          order: 2,
          description: 'Pay your bills',
        ),
        QuickActionItem(
          id: 'static_pulsa',
          moduleId: moduleId,
          icon: Icons.phone_android_outlined,
          label: 'Pulsa',
          color: Color(0xFFE65100),
          route: '/pulsa',
          order: 3,
          description: 'Buy mobile credit',
        ),
        // QuickActionItem(
        //   id: 'static_pln',
        //   moduleId: moduleId,
        //   icon: Icons.electrical_services_outlined,
        //   label: 'PLN',
        //   color: Color(0xFFC62828),
        //   route: '/pln',
        //   order: 4,
        //   description: 'Pay electricity bills',
        // ),
        // QuickActionItem(
        //   id: 'static_pdam',
        //   moduleId: moduleId,
        //   icon: Icons.water_drop_outlined,
        //   label: 'PDAM',
        //   color: Color(0xFF00838F),
        //   route: '/pdam',
        //   order: 5,
        //   description: 'Pay water bills',
        // ),
        // QuickActionItem(
        //   id: 'static_gas',
        //   moduleId: moduleId,
        //   icon: Icons.local_gas_station_outlined,
        //   label: 'Gas',
        //   color: Color(0xFF6A1B9A),
        //   route: '/gas',
        //   order: 6,
        //   description: 'Pay gas bills',
        // ),
        // QuickActionItem(
        //   id: 'static_internet',
        //   moduleId: moduleId,
        //   icon: Icons.wifi_outlined,
        //   label: 'Internet',
        //   color: Color(0xFF283593),
        //   route: '/internet',
        //   order: 7,
        //   description: 'Pay internet bills',
        // ),
      ];
}
