import 'package:flutter/material.dart';

/// Model untuk item navigasi footer
class FooterNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isCenter;

  const FooterNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.isCenter = false,
  });
}

/// Custom Footer menggunakan Material 3 NavigationBar dengan tombol tengah dominan
class CustomFooter extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<FooterNavItem> items;
  final VoidCallback? onCenterButtonTap;
  final Color? backgroundColor;
  final double? elevation;

  const CustomFooter({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
    this.onCenterButtonTap,
    this.backgroundColor,
    this.elevation,
  });

  /// Default navigation items dengan 5 tombol
  static List<FooterNavItem> get defaultItems => const [
        FooterNavItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
        ),
        FooterNavItem(
          icon: Icons.explore_outlined,
          selectedIcon: Icons.explore,
          label: 'Explore',
        ),
        FooterNavItem(
          icon: Icons.qr_code_scanner,
          label: 'Scan',
          isCenter: true,
        ),
        FooterNavItem(
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
          label: 'Activity',
        ),
        FooterNavItem(
          icon: Icons.person_outlined,
          selectedIcon: Icons.person,
          label: 'Profile',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final centerIndex = items.indexWhere((item) => item.isCenter);
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              
              if (item.isCenter) {
                return _buildCenterButton(context, colorScheme);
              }
              
              // Adjust index setelah center button untuk selection
              final actualIndex = index > centerIndex && centerIndex != -1 
                  ? index - 1 
                  : index;
              final adjustedSelectedIndex = selectedIndex >= centerIndex && centerIndex != -1
                  ? selectedIndex + 1
                  : selectedIndex;
              
              return _buildNavItem(
                context,
                item,
                index == adjustedSelectedIndex,
                () => onDestinationSelected(actualIndex),
                colorScheme,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    FooterNavItem item,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? colorScheme.primaryContainer 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected 
                  ? (item.selectedIcon ?? item.icon) 
                  : item.icon,
              color: isSelected 
                  ? colorScheme.onPrimaryContainer 
                  : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected 
                    ? colorScheme.onPrimaryContainer 
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: onCenterButtonTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.qr_code_scanner,
          color: colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }
}

/// Alternative simple NavigationBar without center FAB
class SimpleFooter extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination>? destinations;

  const SimpleFooter({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations ?? [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Explore',
        ),
        const NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Activity',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outlined),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
