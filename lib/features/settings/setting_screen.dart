import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';

/// Setting Screen - Pengaturan bahasa, template, dan konfigurasi lainnya
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackTap ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
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
                  title: const Text('Theme Template'),
                  subtitle: Text(AppTheme.getTemplateName(config.currentTemplate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTemplateDialog(context, ref),
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
                  title: const Text('Dark Mode'),
                  subtitle: Text(config.isDarkMode ? 'On' : 'Off'),
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
          _buildSectionHeader(context, 'Language & Region'),
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
              title: const Text('Language'),
              subtitle: Text(_getLocaleName(config.selectedLocale)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, ref),
            ),
          ),

          const SizedBox(height: 24),

          // Layout Section
          _buildSectionHeader(context, 'Layout'),
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
              title: const Text('Sidebar Position'),
              subtitle: Text(
                config.sidebarPosition == SidebarPosition.left ? 'Left' : 'Right',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSidebarPositionDialog(context, ref),
            ),
          ),

          const SizedBox(height: 24),

          // Auth Section
          _buildSectionHeader(context, 'Authentication'),
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
                  Icons.security_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              title: const Text('Auth Provider'),
              subtitle: Text(
                config.authStrategy == AuthStrategy.firebase 
                    ? 'Firebase Auth' 
                    : 'Custom API',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAuthStrategyDialog(context, ref),
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
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
                  title: const Text('Build Number'),
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

  String _getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'id':
        return 'Bahasa Indonesia';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  void _showTemplateDialog(BuildContext context, WidgetRef ref) {
    final config = ref.read(appConfigProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTemplate.values.map((template) {
            return RadioListTile<AppTemplate>(
              title: Text(AppTheme.getTemplateName(template)),
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

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final config = ref.read(appConfigProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: const Text('Bahasa Indonesia'),
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
              title: const Text('English'),
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

  void _showSidebarPositionDialog(BuildContext context, WidgetRef ref) {
    final config = ref.read(appConfigProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sidebar Position'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<SidebarPosition>(
              title: const Text('Left'),
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
              title: const Text('Right'),
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

  void _showAuthStrategyDialog(BuildContext context, WidgetRef ref) {
    final config = ref.read(appConfigProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auth Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AuthStrategy>(
              title: const Text('Firebase Auth'),
              subtitle: const Text('Use Firebase Authentication'),
              value: AuthStrategy.firebase,
              groupValue: config.authStrategy,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setAuthStrategy(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<AuthStrategy>(
              title: const Text('Custom API'),
              subtitle: const Text('Use custom backend API'),
              value: AuthStrategy.customApi,
              groupValue: config.authStrategy,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setAuthStrategy(value);
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
