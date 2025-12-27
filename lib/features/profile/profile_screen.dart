import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_info.dart';
import '../../core/l10n/app_localizations.dart';

/// Profile Screen - User profile details
class ProfileScreen extends ConsumerWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onEditTap;

  const ProfileScreen({
    super.key,
    this.onBackTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    // Check if user logged in with Google (from property or detect from photoUrl)
    final isGoogleUser = user?.isGoogleLogin == true || 
        (user?.photoUrl?.contains('googleusercontent.com') ?? false);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackTap ?? () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEditTap,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: user?.photoUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: user!.photoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      _buildDefaultAvatar(colorScheme),
                                  errorWidget: (context, url, error) =>
                                      _buildDefaultAvatar(colorScheme),
                                )
                              : _buildDefaultAvatar(colorScheme),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.displayName ?? l10n.guestUser,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? l10n.notLoggedIn,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Info Section
                  _buildSectionHeader(context, l10n.accountInformation),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        _buildInfoTile(
                          context,
                          icon: Icons.person_outline,
                          title: l10n.fullName,
                          value: user?.displayName ?? l10n.notSet,
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          context,
                          icon: Icons.email_outlined,
                          title: l10n.email,
                          value: user?.email ?? l10n.notSet,
                        ),
                        // Email Verified - hidden
                        // const Divider(height: 1),
                        // _buildInfoTile(
                        //   context,
                        //   icon: Icons.verified_outlined,
                        //   title: l10n.emailVerified,
                        //   value: user?.isEmailVerified == true ? l10n.yes : l10n.no,
                        //   valueColor: user?.isEmailVerified == true
                        //       ? Colors.green
                        //       : colorScheme.error,
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildSectionHeader(context, l10n.quickActions),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        // Hide Change Password menu if logged in with Google
                        if (!isGoogleUser) ...[
                          ListTile(
                            leading: const Icon(Icons.lock_outline),
                            title: Text(l10n.changePassword),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.changePassword),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                        ],
                        ListTile(
                          leading: const Icon(Icons.notifications_outlined),
                          title: Text(l10n.notificationSettings),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.notificationSettings),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.security_outlined),
                          title: Text(l10n.privacyAndSecurity),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.privacyAndSecurity),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Danger Zone - only show if enabled
                  if (AppInfo.enableDangerZone) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, l10n.dangerZone),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                        ),
                        title: Text(
                          l10n.deleteAccount,
                          style: TextStyle(color: colorScheme.error),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.error,
                        ),
                        onTap: () => _showDeleteAccountDialog(context, l10n),
                      ),
                    ),
                  ],

                  SizedBox(height: AppInfo.bottomMargin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        size: 50,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: colorScheme.error,
          size: 48,
        ),
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.accountDeletionRequested),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

/// Embedded Profile Content - for use within bottom navigation
/// Without Scaffold and AppBar, suitable for display within tab/page
class EmbeddedProfileContent extends ConsumerWidget {
  final VoidCallback? onEditProfileTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onLogoutTap;

  const EmbeddedProfileContent({
    super.key,
    this.onEditProfileTap,
    this.onSettingsTap,
    this.onHelpTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header with gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primaryContainer,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: user?.photoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: user!.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                _buildDefaultAvatar(colorScheme),
                            errorWidget: (context, url, error) =>
                                _buildDefaultAvatar(colorScheme),
                          )
                        : _buildDefaultAvatar(colorScheme),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? l10n.guestUser,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? l10n.notLoggedIn,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),

          // Profile Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Info Section
                _buildSectionHeader(context, l10n.accountInformation),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _buildInfoTile(
                        context,
                        icon: Icons.person_outline,
                        title: l10n.fullName,
                        value: user?.displayName ?? l10n.notSet,
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        context,
                        icon: Icons.email_outlined,
                        title: l10n.email,
                        value: user?.email ?? l10n.notSet,
                      ),
                      // Email Verified - hidden
                      // const Divider(height: 1),
                      // _buildInfoTile(
                      //   context,
                      //   icon: Icons.verified_outlined,
                      //   title: l10n.emailVerified,
                      //   value: user?.isEmailVerified == true ? l10n.yes : l10n.no,
                      //   valueColor: user?.isEmailVerified == true
                      //       ? Colors.green
                      //       : colorScheme.error,
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Profile Actions Section
                _buildSectionHeader(context, l10n.quickActions),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(l10n.editProfile),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: onEditProfileTap,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: Text(l10n.settings),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: onSettingsTap,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: Text(l10n.helpAndSupport),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: onHelpTap,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: colorScheme.error,
                        ),
                        title: Text(
                          l10n.logout,
                          style: TextStyle(color: colorScheme.error),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.error,
                        ),
                        onTap: onLogoutTap,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppInfo.bottomMargin),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        size: 50,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

