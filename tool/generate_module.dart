// ignore_for_file: avoid_print
// Module Generator CLI Tool
//
// This script generates a new module with the standard folder structure
// and boilerplate code.
//
// Usage:
//   dart run tool/generate_module.dart [module_name]
//
// Example:
//   dart run tool/generate_module.dart news
//   dart run tool/generate_module.dart ecommerce
//
// This will create:
//   lib/modules/[module_name]/
//   ├── [module_name]_module.dart
//   ├── screens/
//   │   └── [module_name]_screen.dart
//   └── widgets/
//       └── [module_name]_dashboard_card.dart

import 'dart:io';

void main(List<String> args) {
  print('');
  print('╔══════════════════════════════════════════╗');
  print('║       MODULE GENERATOR CLI TOOL          ║');
  print('╚══════════════════════════════════════════╝');
  print('');

  if (args.isEmpty) {
    print('❌ Error: Module name is required');
    print('');
    print('Usage: dart run tool/generate_module.dart <module_name>');
    print('');
    print('Example:');
    print('  dart run tool/generate_module.dart news');
    print('  dart run tool/generate_module.dart ecommerce');
    exit(1);
  }

  final moduleName = args[0].toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  final moduleNameCapitalized = _capitalize(moduleName);
  final moduleNamePascal = _toPascalCase(moduleName);

  print('📦 Generating module: $moduleName');
  print('');

  // Define paths
  final basePath = 'lib/modules/$moduleName';
  final screensPath = '$basePath/screens';
  final widgetsPath = '$basePath/widgets';

  // Create directories
  print('📁 Creating directories...');
  _createDirectory(basePath);
  _createDirectory(screensPath);
  _createDirectory(widgetsPath);

  // Create module file
  print('📝 Creating module file...');
  _createFile(
    '$basePath/${moduleName}_module.dart',
    _generateModuleCode(moduleName, moduleNamePascal),
  );

  // Create screen file
  print('📝 Creating screen file...');
  _createFile(
    '$screensPath/${moduleName}_screen.dart',
    _generateScreenCode(moduleName, moduleNamePascal, moduleNameCapitalized),
  );

  // Create dashboard card widget
  print('📝 Creating dashboard card widget...');
  _createFile(
    '$widgetsPath/${moduleName}_dashboard_card.dart',
    _generateDashboardCardCode(moduleName, moduleNamePascal, moduleNameCapitalized),
  );

  print('');
  print('✅ Module "$moduleName" generated successfully!');
  print('');
  print('📁 Created files:');
  print('   $basePath/${moduleName}_module.dart');
  print('   $screensPath/${moduleName}_screen.dart');
  print('   $widgetsPath/${moduleName}_dashboard_card.dart');
  print('');
  print('📋 Next steps:');
  print('   1. Register the module in lib/main.dart:');
  print('      ModuleRegistry.register(${moduleNamePascal}Module());');
  print('');
  print('   2. Enable the module in .env:');
  print('      ENABLE_MODULE_${moduleName.toUpperCase()}=true');
  print('');
  print('   3. Run flutter analyze to check for errors:');
  print('      flutter analyze lib/modules/$moduleName');
  print('');
}

void _createDirectory(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
    print('   ✓ Created: $path/');
  } else {
    print('   ⚠ Already exists: $path/');
  }
}

void _createFile(String path, String content) {
  final file = File(path);
  if (!file.existsSync()) {
    file.writeAsStringSync(content);
    print('   ✓ Created: $path');
  } else {
    print('   ⚠ Already exists: $path (skipped)');
  }
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

String _toPascalCase(String s) {
  return s.split('_').map(_capitalize).join('');
}

String _generateModuleCode(String moduleName, String moduleNamePascal) {
  return '''import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../module_base.dart';
import '../navigation_item.dart';
import 'screens/${moduleName}_screen.dart';
import 'widgets/${moduleName}_dashboard_card.dart';

/// $moduleNamePascal Module
///
/// To enable this module, add to your .env file:
/// ```
/// ENABLE_MODULE_${moduleName.toUpperCase()}=true
/// ```
class ${moduleNamePascal}Module extends BaseModule {
  @override
  String get name => '$moduleName';

  @override
  String get version => '1.0.0';

  @override
  String get description => '$moduleNamePascal module';

  @override
  String get displayName => '$moduleNamePascal';

  @override
  IconData get icon => Icons.widgets;

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: '/$moduleName',
      name: '$moduleName',
      builder: (context, state) => const ${moduleNamePascal}Screen(),
    ),
  ];

  @override
  Widget? get dashboardWidget => const ${moduleNamePascal}DashboardCard();

  @override
  DashboardWidgetConfig get dashboardConfig => const DashboardWidgetConfig(
    columnSpan: 1,
    rowSpan: 1,
    order: 100,
  );

  @override
  List<NavigationItem> get menuItems => [
    NavigationItem(
      id: '$moduleName',
      label: '$moduleNamePascal',
      icon: Icons.widgets_outlined,
      selectedIcon: Icons.widgets,
      route: '/$moduleName',
      order: 100,
      requiresAuth: true,
    ),
  ];

  @override
  List<String> get dependencies => [];

  @override
  Future<void> initialize() async {
    debugPrint('${moduleNamePascal}Module: Initializing...');
    // Add initialization logic here
  }

  @override
  Future<void> dispose() async {
    debugPrint('${moduleNamePascal}Module: Disposing...');
    // Add cleanup logic here
  }

  @override
  Future<void> onUserLogin() async {
    debugPrint('${moduleNamePascal}Module: User logged in');
    // Load user-specific data
  }

  @override
  Future<void> onUserLogout() async {
    debugPrint('${moduleNamePascal}Module: User logged out');
    // Clear user-specific data
  }
}
''';
}

String _generateScreenCode(String moduleName, String moduleNamePascal, String moduleNameCapitalized) {
  return '''import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main screen for the $moduleNamePascal module
class ${moduleNamePascal}Screen extends StatelessWidget {
  const ${moduleNamePascal}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('$moduleNameCapitalized'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.widgets,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                '$moduleNameCapitalized Module',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This is the $moduleNameCapitalized module screen. '
                'Customize this screen for your specific needs.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''';
}

String _generateDashboardCardCode(String moduleName, String moduleNamePascal, String moduleNameCapitalized) {
  return '''import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dashboard card widget for the $moduleNamePascal module
class ${moduleNamePascal}DashboardCard extends StatelessWidget {
  const ${moduleNamePascal}DashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/$moduleName'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(
                    Icons.widgets,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$moduleNameCapitalized',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Tap to explore',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''';
}
