import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/assets.dart';
import '../../core/constants/app_info.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/network/repository/article_repository.dart';
import '../../core/network/repository/banner_repository.dart';
import '../../shared/widgets/custom_header.dart';
import '../../shared/widgets/custom_sidebar.dart';
import '../../shared/widgets/custom_footer.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/menu_grid.dart';
import 'widgets/article_list.dart';

/// Current navigation index
final currentNavIndexProvider = StateProvider<int>((ref) => 0);

/// Main Dashboard - Main page of the application
class MainDashboard extends ConsumerStatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onLogoutTap;

  const MainDashboard({
    super.key,
    this.onSettingsTap,
    this.onProfileTap,
    this.onHelpTap,
    this.onLogoutTap,
  });

  @override
  ConsumerState<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends ConsumerState<MainDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Set system UI for edge-to-edge
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sidebarPosition = ref.watch(sidebarPositionProvider);
    final currentIndex = ref.watch(currentNavIndexProvider);
    final l10n = context.l10n;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomHeader(
        title: AppInfo.name,
        showLogo: true,
        logo: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            Assets.logo,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.apps_rounded,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
          ),
        ),
        onMenuTap: () => _openDrawer(sidebarPosition),
        onNotificationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noNewNotifications),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      // Sidebar with configurable position
      drawer: sidebarPosition == SidebarPosition.left
          ? CustomSidebar(
              onProfileTap: widget.onProfileTap,
              onSettingsTap: widget.onSettingsTap,
              onHelpTap: widget.onHelpTap,
              onLogoutTap: widget.onLogoutTap,
            )
          : null,
      endDrawer: sidebarPosition == SidebarPosition.right
          ? CustomSidebar(
              onProfileTap: widget.onProfileTap,
              onSettingsTap: widget.onSettingsTap,
              onHelpTap: widget.onHelpTap,
              onLogoutTap: widget.onLogoutTap,
            )
          : null,
      body: _buildBody(currentIndex),
      bottomNavigationBar: CustomFooter(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(currentNavIndexProvider.notifier).state = index;
        },
        items: CustomFooter.defaultItems,
        onCenterButtonTap: () => _showScanDialog(context),
      ),
      // Additional Floating Action Button
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.small(
              heroTag: 'fab_chat',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.chatSupport),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Icon(Icons.chat_outlined),
            )
          : null,
    );
  }

  void _openDrawer(SidebarPosition position) {
    if (position == SidebarPosition.left) {
      _scaffoldKey.currentState?.openDrawer();
    } else {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  Widget _buildBody(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildExploreContent();
      case 2:
        return _buildActivityContent();
      case 3:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh banners and articles from API
        await Future.wait([
          ref.read(bannersProvider.notifier).refresh(),
          ref.read(articlesProvider.notifier).refresh(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Banner Carousel from API
            // Using BannerCarouselFromApi that fetches from https://api.carik.id/dummy/banner.json
            BannerCarouselFromApi(
              onBannerTap: (banner) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Banner: ${banner.title}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.l10n.quickActions,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            MenuGrid(
              items: MenuGrid.sampleItems,
            ),

            const SizedBox(height: 24),

            // Articles from API (Horizontal)
            // Using ArticleListFromApi that fetches from https://api.carik.id/dummy/article.json
            ArticleListFromApi(
              title: context.l10n.latestNews,
              seeAllText: context.l10n.seeAll,
              isHorizontal: true,
              onSeeAllTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.seeAll),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onArticleTap: (article) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected: ${article.title}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Articles from API (Vertical)
            ArticleListFromApi(
              title: context.l10n.recommendedForYou,
              isHorizontal: false,
              onArticleTap: (article) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected: ${article.title}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildExploreContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.explore,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.discoverNewServices,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.activity,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.viewRecentTransactions,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    final user = ref.watch(currentUserProvider);
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? l10n.guestUser,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            user?.email ?? l10n.pleaseLoginToContinue,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          // Profile Actions
          _buildProfileAction(
            icon: Icons.person_outline,
            title: l10n.editProfile,
            onTap: widget.onProfileTap,
          ),
          _buildProfileAction(
            icon: Icons.settings_outlined,
            title: l10n.settings,
            onTap: widget.onSettingsTap,
          ),
          _buildProfileAction(
            icon: Icons.help_outline,
            title: l10n.helpAndSupport,
            onTap: widget.onHelpTap,
          ),
          _buildProfileAction(
            icon: Icons.logout,
            title: l10n.logout,
            isDestructive: true,
            onTap: widget.onLogoutTap,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAction({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? colorScheme.error : colorScheme.onSurface,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showScanDialog(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (dialogContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(dialogContext).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.scanAndPay,
              style: Theme.of(dialogContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScanOption(
                  dialogContext,
                  icon: Icons.qr_code_scanner,
                  label: l10n.scanQr,
                ),
                _buildScanOption(
                  dialogContext,
                  icon: Icons.camera_alt_outlined,
                  label: l10n.takePhoto,
                ),
                _buildScanOption(
                  dialogContext,
                  icon: Icons.file_upload_outlined,
                  label: l10n.upload,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOption(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label selected'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
