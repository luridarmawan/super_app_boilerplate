import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/config/app_config.dart';
import '../../core/auth/auth_interface.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/constants/app_info.dart';
import '../../core/notification/notification_test_panel.dart';

/// Custom Sidebar menggunakan Material 3 NavigationDrawer
class CustomSidebar extends ConsumerWidget {
  final VoidCallback? onDashboardTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onLogoutTap;

  const CustomSidebar({
    super.key,
    this.onDashboardTap,
    this.onProfileTap,
    this.onSettingsTap,
    this.onHelpTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);
    final l10n = context.l10n;
    
    return NavigationDrawer(
      selectedIndex: null,
      onDestinationSelected: (index) => _handleNavigation(context, index, l10n),
      children: [
        // Header dengan profil user
        _buildDrawerHeader(context, user, colorScheme),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        
        // Menu items
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
          child: Text(
            l10n.menuLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(l10n.dashboard),
        ),
        
        // NavigationDrawerDestination(
        //   icon: const Icon(Icons.person_outline),
        //   selectedIcon: const Icon(Icons.person),
        //   label: Text(l10n.profile),
        // ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.notifications_outlined),
          selectedIcon: const Icon(Icons.notifications),
          label: Text(l10n.notifications),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
          child: Text(
            l10n.activityLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history),
          label: Text(l10n.history),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.favorite_outline),
          selectedIcon: const Icon(Icons.favorite),
          label: Text(l10n.favorites),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.bookmark_outline),
          selectedIcon: const Icon(Icons.bookmark),
          label: Text(l10n.saved),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
          child: Text(
            l10n.settingsLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(l10n.settings),
        ),
        
        NavigationDrawerDestination(
          icon: const Icon(Icons.help_outline),
          selectedIcon: const Icon(Icons.help),
          label: Text(l10n.helpAndSupport),
        ),
        
        // Notification Test (only when notification enabled AND mock provider)
        if (AppInfo.enableNotification &&
            (AppInfo.notificationProvider.toLowerCase() == 'mock' ||
             AppInfo.notificationProvider.toLowerCase() == 'test'))
          const NavigationDrawerDestination(
            icon: Icon(Icons.bug_report_outlined),
            selectedIcon: Icon(Icons.bug_report),
            label: Text('Notification Test'),
          ),
        
        const SizedBox(height: 16),
        
        // Logout button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.icon(
            onPressed: onLogoutTap,
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
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
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            user?.displayName ?? context.l10n.guestUser,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Email
          if (user?.email != null)
            Text(
              user!.email!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
          
          const SizedBox(height: 8),
          
          // View Profile button
          TextButton.icon(
            onPressed: onProfileTap,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: Text(context.l10n.viewProfile),
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

  void _handleNavigation(BuildContext context, int index, AppLocalizations l10n) {
    Navigator.of(context).pop(); // Close drawer
    
    switch (index) {
      case 0: // Dashboard
        onDashboardTap?.call();
        break;
      // case 1: // Profile
      //   onProfileTap?.call();
      //   break;
      case 1: // Notifications
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notifications)),
        );
        break;
      case 2: // History
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.history)),
        );
        break;
      case 3: // Favorites
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.favorites)),
        );
        break;
      case 4: // Saved
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.saved)),
        );
        break;
      case 5: // Settings
        onSettingsTap?.call();
        break;
      case 6: // Help
        onHelpTap?.call();
        break;
      case 7: // Notification Test (only if shown)
        if (AppInfo.enableNotification &&
            (AppInfo.notificationProvider.toLowerCase() == 'mock' ||
             AppInfo.notificationProvider.toLowerCase() == 'test')) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationTestPanel()),
          );
        }
        break;
    }
  }
}
