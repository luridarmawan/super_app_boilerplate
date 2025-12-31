export 'package:module_interface/module_interface.dart';
import 'package:module_interface/module_interface.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_info.dart';


/// Static quick actions that are always available
/// These are the default actions shown in the menu grid
class StaticQuickActions {
  static const String moduleId = 'static';

  /// Returns quick action items based on ENABLE_QUICK_ACTION_DEMO env variable
  /// If ENABLE_QUICK_ACTION_DEMO=true, returns Pay, Bills, Pulsa items
  /// Otherwise returns an empty list
  static List<QuickActionItem> get items {
    if (!AppInfo.enableQuickActionDemo) {
      return const [];
    }

    return const [
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
}
