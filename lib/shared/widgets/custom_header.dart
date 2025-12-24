import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_app/core/network/connectivity/connectivity_provider.dart';

/// Custom Header yang dinamis menggunakan SliverAppBar atau AppBar Material 3
class CustomHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? logo;
  final bool showLogo;
  final bool showNotification;
  final bool showOfflineIndicator;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? elevation;
  final Color? backgroundColor;

  const CustomHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.logo,
    this.showLogo = false,
    this.showNotification = true,
    this.showOfflineIndicator = true,
    this.onNotificationTap,
    this.onMenuTap,
    this.actions,
    this.centerTitle = true,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.elevation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOffline = showOfflineIndicator ? ref.watch(isOfflineProvider) : false;
    
    return AppBar(
      elevation: elevation ?? 0,
      scrolledUnderElevation: 2,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading ?? (onMenuTap != null
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuTap,
            )
          : null),
      title: showLogo && logo != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                logo!,
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
      actions: [
        // Offline indicator icon
        if (isOffline)
          Tooltip(
            message: 'Offline Mode',
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 20,
                color: colorScheme.error,
              ),
            ),
          ),
        if (showNotification)
          IconButton(
            icon: Badge(
              smallSize: 8,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: onNotificationTap,
          ),
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Sliver version of CustomHeader untuk penggunaan dengan CustomScrollView
class CustomSliverHeader extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final Widget? logo;
  final bool showLogo;
  final bool showNotification;
  final bool showOfflineIndicator;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final List<Widget>? actions;
  final Widget? flexibleSpace;
  final double expandedHeight;
  final bool floating;
  final bool pinned;
  final bool snap;

  const CustomSliverHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.logo,
    this.showLogo = false,
    this.showNotification = true,
    this.showOfflineIndicator = true,
    this.onNotificationTap,
    this.onMenuTap,
    this.actions,
    this.flexibleSpace,
    this.expandedHeight = 200,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOffline = showOfflineIndicator ? ref.watch(isOfflineProvider) : false;
    
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      snap: snap,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      leading: onMenuTap != null
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuTap,
            )
          : null,
      flexibleSpace: flexibleSpace ??
          FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
      actions: [
        // Offline indicator icon
        if (isOffline)
          Tooltip(
            message: 'Offline Mode',
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 20,
                color: colorScheme.error,
              ),
            ),
          ),
        if (showNotification)
          IconButton(
            icon: Badge(
              smallSize: 8,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: onNotificationTap,
          ),
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
    );
  }
}
