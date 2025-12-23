import 'package:flutter/material.dart';

/// Model untuk menu item
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
}

/// Grid menu untuk menampilkan ikon modul dengan Material 3 Cards
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
    this.childAspectRatio = 0.9,
    this.shrinkWrap = true,
    this.physics,
  });

  /// Sample menu items untuk demo
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

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemColor = item.color ?? colorScheme.primary;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: itemColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: itemColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
