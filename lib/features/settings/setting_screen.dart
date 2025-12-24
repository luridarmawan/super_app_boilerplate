import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';

/// Setting Screen - Pengaturan bahasa, template, dan konfigurasi lainnya
/// Menggunakan lokalisasi multi-bahasa
class SettingScreen extends ConsumerWidget {
  final VoidCallback? onBackTap;

  const SettingScreen({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackTap ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader(context, l10n.appearance),
          const SizedBox(height: 8),
          
          // Theme Template
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(l10n.themeTemplate),
                  subtitle: Text(_getLocalizedTemplateName(l10n, config.currentTemplate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTemplateDialog(context, ref, l10n),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.dark_mode_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(l10n.darkMode),
                  subtitle: Text(config.isDarkMode ? l10n.on : l10n.off),
                  value: config.isDarkMode,
                  onChanged: (value) {
                    ref.read(appConfigProvider.notifier).setDarkMode(value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Language Section
          _buildSectionHeader(context, l10n.languageAndRegion),
          const SizedBox(height: 8),
          
          Card(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.language_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(l10n.language),
              subtitle: Text(_getLocaleName(l10n, config.selectedLocale)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, ref, l10n),
            ),
          ),

          const SizedBox(height: 24),

          // Layout Section
          _buildSectionHeader(context, l10n.layout),
          const SizedBox(height: 8),
          
          Card(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.view_sidebar_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(l10n.sidebarPosition),
              subtitle: Text(
                config.sidebarPosition == SidebarPosition.left ? l10n.left : l10n.right,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSidebarPositionDialog(context, ref, l10n),
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, l10n.about),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.appVersion),
                  trailing: Text(
                    '1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: Text(l10n.buildNumber),
                  trailing: Text(
                    '1',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  String _getLocaleName(AppLocalizations l10n, Locale locale) {
    switch (locale.languageCode) {
      case 'id':
        return l10n.bahasaIndonesia;
      case 'en':
        return l10n.english;
      default:
        return locale.languageCode;
    }
  }

  String _getLocalizedTemplateName(AppLocalizations l10n, AppTemplate template) {
    switch (template) {
      case AppTemplate.defaultBlue:
        return l10n.defaultBlue;
      case AppTemplate.modernPurple:
        return l10n.modernPurple;
      case AppTemplate.elegantGreen:
        return l10n.elegantGreen;
      case AppTemplate.warmOrange:
        return l10n.warmOrange;
      case AppTemplate.darkMode:
        return l10n.darkModeTheme;
    }
  }

  void _showTemplateDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final config = ref.read(appConfigProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTemplate.values.map((template) {
            return RadioListTile<AppTemplate>(
              title: Text(_getLocalizedTemplateName(l10n, template)),
              value: template,
              groupValue: config.currentTemplate,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setTemplate(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final config = ref.read(appConfigProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: Text(l10n.bahasaIndonesia),
              value: const Locale('id', 'ID'),
              groupValue: config.selectedLocale,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setLocale(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<Locale>(
              title: Text(l10n.english),
              value: const Locale('en', 'US'),
              groupValue: config.selectedLocale,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setLocale(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSidebarPositionDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final config = ref.read(appConfigProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sidebarPosition),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<SidebarPosition>(
              title: Text(l10n.left),
              value: SidebarPosition.left,
              groupValue: config.sidebarPosition,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setSidebarPosition(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<SidebarPosition>(
              title: Text(l10n.right),
              value: SidebarPosition.right,
              groupValue: config.sidebarPosition,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setSidebarPosition(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
