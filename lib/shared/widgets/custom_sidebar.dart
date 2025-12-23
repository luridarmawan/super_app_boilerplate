import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/config/app_config.dart';
import '../../core/auth/auth_interface.dart';

/// Custom Sidebar menggunakan Material 3 NavigationDrawer
class CustomSidebar extends ConsumerWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onLogoutTap;

  const CustomSidebar({
    super.key,
    this.onProfileTap,
    this.onSettingsTap,
    this.onHelpTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);
    
    return NavigationDrawer(
      selectedIndex: null,
      onDestinationSelected: (index) => _handleNavigation(context, index),
      children: [
        // Header dengan profil user
        _buildDrawerHeader(context, user, colorScheme),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        
        // Menu items
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 16, 8),
          child: Text(
            'Menu',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: const Text('Dashboard'),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: const Text('Profile'),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.notifications_outlined),
          selectedIcon: const Icon(Icons.notifications),
          label: const Text('Notifications'),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 16, 8),
          child: Text(
            'Activity',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history),
          label: const Text('History'),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.favorite_outline),
          selectedIcon: const Icon(Icons.favorite),
          label: const Text('Favorites'),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.bookmark_outline),
          selectedIcon: const Icon(Icons.bookmark),
          label: const Text('Saved'),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 16, 8),
          child: Text(
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: const Text('Settings'),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.help_outline),
          selectedIcon: const Icon(Icons.help),
          label: const Text('Help & Support'),
        ),
        
        const SizedBox(height: 16),
        
        // Logout button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.icon(
            onPressed: onLogoutTap,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    AuthUser? user,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primary,
              child: user?.photoUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user!.photoUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Icon(
                          Icons.person,
                          size: 36,
                          color: colorScheme.onPrimary,
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          size: 36,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 36,
                      color: colorScheme.onPrimary,
                    ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Name
          Text(
            user?.displayName ?? 'Guest User',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Email
          if (user?.email != null)
            Text(
              user!.email!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
          
          const SizedBox(height: 8),
          
          // View Profile button
          TextButton.icon(
            onPressed: onProfileTap,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('View Profile'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    Navigator.of(context).pop(); // Close drawer
    
    switch (index) {
      case 0: // Dashboard
        // Already on dashboard
        break;
      case 1: // Profile
        onProfileTap?.call();
        break;
      case 2: // Notifications
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications')),
        );
        break;
      case 3: // History
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History')),
        );
        break;
      case 4: // Favorites
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorites')),
        );
        break;
      case 5: // Saved
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved')),
        );
        break;
      case 6: // Settings
        onSettingsTap?.call();
        break;
      case 7: // Help
        onHelpTap?.call();
        break;
    }
  }
}
