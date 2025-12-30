import 'package:flutter/material.dart';

typedef QuickActionCallback = void Function(BuildContext context);

class QuickActionItem {
  final String id;
  final String moduleId;
  final IconData icon;
  final String label;
  final Color? color;
  final String? route;
  final QuickActionCallback? onTap;
  final int order;
  final bool enabledByDefault;
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
