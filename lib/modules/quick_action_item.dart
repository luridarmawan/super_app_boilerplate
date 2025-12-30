export 'package:module_interface/module_interface.dart';
import 'package:module_interface/module_interface.dart';
import 'package:flutter/material.dart';

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
      ];
}
