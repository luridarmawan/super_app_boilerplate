import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../modules/quick_action_item.dart';
import '../providers/quick_action_visibility_provider.dart';

/// Model untuk menu item (legacy support)
class MenuItem {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const MenuItem({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  /// Convert to QuickActionItem
  QuickActionItem toQuickActionItem({
    required String id,
    String moduleId = 'legacy',
  }) {
    return QuickActionItem(
      id: id,
      moduleId: moduleId,
      icon: icon,
      label: label,
      color: color,
      onTap: onTap != null ? (_) => onTap!() : null,
      route: '/placeholder', // Will be overridden by onTap
    );
  }
}

/// Grid menu untuk menampilkan quick actions dengan Material 3 Cards
/// 
/// This widget displays quick actions from modules in a grid layout.
/// It automatically handles the "More" button when there are too many actions.
/// 
/// Usage:
/// ```dart
/// // Using with provider (recommended)
/// QuickActionGrid(
///   maxItems: 8,
///   onMoreTap: () => context.push('/quick-actions'),
/// )
/// 
/// // Using with custom items (legacy)
/// MenuGrid(
///   items: [MenuItem(icon: Icons.home, label: 'Home')],
/// )
/// ```
class QuickActionGrid extends ConsumerWidget {
  final int maxItems;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final VoidCallback? onMoreTap;
  /// If true, always show the "More" button even if items < maxItems
  /// This allows users to access Quick Actions Manager
  final bool alwaysShowMore;

  const QuickActionGrid({
    super.key,
    this.maxItems = 8,
    this.crossAxisCount = 4,
    this.spacing = 12,
    this.childAspectRatio = 0.8,
    this.shrinkWrap = true,
    this.physics,
    this.onMoreTap,
    this.alwaysShowMore = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleActions = ref.watch(menuGridQuickActionsProvider(maxItems));
    final showMore = ref.watch(showMoreButtonProvider(maxItems));

    // Show "More" if: items exceed maxItems OR alwaysShowMore is true
    final shouldShowMore = showMore || alwaysShowMore;

    // Build the items list
    final items = <Widget>[
      ...visibleActions.map((action) => _QuickActionCard(action: action)),
      if (shouldShowMore)
        _MoreCard(
          onTap: onMoreTap ?? () => context.push('/quick-actions'),
        ),
    ];

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}

/// Legacy MenuGrid untuk backward compatibility
class MenuGrid extends StatelessWidget {
  final List<MenuItem> items;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const MenuGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 4,
    this.spacing = 12,
    this.childAspectRatio = 0.8,
    this.shrinkWrap = true,
    this.physics,
  });

  /// Sample menu items untuk demo (legacy)
  static List<MenuItem> get sampleItems => const [
        MenuItem(
          icon: Icons.payments_outlined,
          label: 'Pay',
          color: Color(0xFF1565C0),
        ),
        MenuItem(
          icon: Icons.receipt_long_outlined,
          label: 'Bills',
          color: Color(0xFF2E7D32),
        ),
        MenuItem(
          icon: Icons.phone_android_outlined,
          label: 'Pulsa',
          color: Color(0xFFE65100),
        ),
        MenuItem(
          icon: Icons.electrical_services_outlined,
          label: 'PLN',
          color: Color(0xFFC62828),
        ),
        MenuItem(
          icon: Icons.water_drop_outlined,
          label: 'PDAM',
          color: Color(0xFF00838F),
        ),
        MenuItem(
          icon: Icons.local_gas_station_outlined,
          label: 'Gas',
          color: Color(0xFF6A1B9A),
        ),
        MenuItem(
          icon: Icons.wifi_outlined,
          label: 'Internet',
          color: Color(0xFF283593),
        ),
        MenuItem(
          icon: Icons.more_horiz,
          label: 'More',
          color: Color(0xFF455A64),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _MenuItemCard(item: items[index]);
      },
    );
  }
}

/// Card for displaying a QuickActionItem
class _QuickActionCard extends StatelessWidget {
  final QuickActionItem action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemColor = action.color ?? colorScheme.primary;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: itemColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: itemColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  action.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    // Custom callback takes precedence
    if (action.onTap != null) {
      action.onTap!(context);
      return;
    }
    
    // Otherwise navigate to route
    if (action.route != null) {
      context.push(action.route!);
    }
  }
}

/// Card for displaying a legacy MenuItem
class _MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemColor = item.color ?? colorScheme.primary;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: item.onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.label} tapped'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: itemColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: itemColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card for "More" button
class _MoreCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MoreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const itemColor = Color(0xFF455A64);

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: itemColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.more_horiz,
                  color: itemColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  'More',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header untuk menu grid
class MenuGridSection extends StatelessWidget {
  final String title;
  final String? seeAllText;
  final VoidCallback? onSeeAllTap;
  final List<MenuItem> items;
  final int crossAxisCount;

  const MenuGridSection({
    super.key,
    required this.title,
    this.seeAllText,
    this.onSeeAllTap,
    required this.items,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (seeAllText != null)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: Text(seeAllText!),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        MenuGrid(
          items: items,
          crossAxisCount: crossAxisCount,
        ),
      ],
    );
  }
}

/// Section for Quick Actions from modules
class QuickActionSection extends ConsumerWidget {
  final String title;
  final String? seeAllText;
  final VoidCallback? onSeeAllTap;
  final int maxItems;
  final int crossAxisCount;

  const QuickActionSection({
    super.key,
    this.title = 'Quick Actions',
    this.seeAllText,
    this.onSeeAllTap,
    this.maxItems = 8,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (seeAllText != null)
                TextButton(
                  onPressed: onSeeAllTap ?? () => context.push('/quick-actions'),
                  child: Text(seeAllText!),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        QuickActionGrid(
          maxItems: maxItems,
          crossAxisCount: crossAxisCount,
          onMoreTap: onSeeAllTap,
        ),
      ],
    );
  }
}
