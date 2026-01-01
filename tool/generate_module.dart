// ignore_for_file: avoid_print
// External Module Generator CLI Tool
//
// This script generates a new external module with the standard folder structure
// and boilerplate code for modular Super App architecture.
//
// Usage:
//   dart run tool/generate_module.dart
//
// The tool will interactively ask for:
//   1. Module name (converted to snake_case)
//   2. Module description
//   3. Number of workspaces (each with list and form screens)
//   4. Number of quick actions
//
// Output structure:
//   modules/[module_name]/
//   ├── lib/
//   │   ├── [module_name].dart
//   │   ├── [module_name]_module.dart
//   │   ├── l10n/
//   │   │   ├── l10n.dart
//   │   │   ├── [module_name]_localizations.dart
//   │   │   └── strings/
//   │   │       ├── id_strings.dart
//   │   │       └── en_strings.dart
//   │   └── screens/
//   │       └── [workspace]/
//   │           ├── [workspace]_list_screen.dart
//   │           └── [workspace]_form_screen.dart
//   ├── test/
//   │   └── [module_name]_test.dart
//   ├── pubspec.yaml
//   ├── LICENSE
//   └── README.md

import 'dart:io';

void main() async {
  print('');
  print('╔══════════════════════════════════════════════════════╗');
  print('║     EXTERNAL MODULE GENERATOR CLI TOOL               ║');
  print('║     Super App Boilerplate                            ║');
  print('╚══════════════════════════════════════════════════════╝');
  print('');

  // 1. Ask for module name
  final moduleName = _askModuleName();
  final moduleNameSnake = _toSnakeCase(moduleName);
  final moduleNamePascal = _toPascalCase(moduleNameSnake);
  final moduleNameDisplay = moduleName; // Keep original capitalization from user input

  print('');
  print('📦 Module name: $moduleNameDisplay ($moduleNameSnake)');

  // Check if module folder already exists
  final modulePath = 'modules/$moduleNameSnake';
  final moduleDir = Directory(modulePath);
  if (moduleDir.existsSync()) {
    print('');
    print('⚠️  Warning: Folder "$modulePath" already exists!');
    stdout.write('   Delete and recreate? (y/N): ');
    final response = stdin.readLineSync()?.toLowerCase().trim() ?? '';
    
    if (response == 'y' || response == 'yes') {
      print('   🗑️  Deleting existing folder...');
      try {
        moduleDir.deleteSync(recursive: true);
        print('   ✓ Deleted successfully');
      } catch (e) {
        print('   ❌ Failed to delete: $e');
        print('');
        print('❌ Module generation cancelled.');
        exit(1);
      }
    } else {
      print('');
      print('❌ Module generation cancelled.');
      exit(0);
    }
  }

  // 2. Ask for module description
  final description = _askDescription(moduleNameDisplay);
  print('📝 Description: $description');

  // 3. Ask for workspaces
  final workspaces = _askWorkspaces(moduleNameSnake, moduleNameDisplay);
  print('📂 Workspaces: ${workspaces.map((w) => w['display']).join(', ')}');

  // 4. Ask for quick actions
  final quickActions = _askQuickActions(moduleNameSnake, moduleNameDisplay);
  print('⚡ Quick Actions: ${quickActions.map((q) => q['label']).join(', ')}');

  print('');
  print('═══════════════════════════════════════════════════════');
  print('');

  // Generate module
  _generateModule(
    moduleNameSnake: moduleNameSnake,
    moduleNamePascal: moduleNamePascal,
    moduleNameDisplay: moduleNameDisplay,
    description: description,
    workspaces: workspaces,
    quickActions: quickActions,
  );

  // Register module in pubspec.yaml and all_modules.dart
  print('');
  print('📝 Registering module...');
  await _registerModuleToPubspec(moduleNameSnake);
  await _registerModuleToAllModules(moduleNameSnake, moduleNamePascal);

  // Run flutter pub get
  print('');
  print('� Running flutter pub get...');
  final pubResult = await Process.run('flutter', ['pub', 'get'], runInShell: true);
  if (pubResult.exitCode == 0) {
    print('   ✓ Dependencies updated');
  } else {
    print('   ⚠ flutter pub get failed: ${pubResult.stderr}');
  }

  print('');
  print('✅ Module "$moduleNameDisplay" generated and registered successfully!');
  print('');
  print('📋 Optional configuration:');
  print('   Add to .env for conditional enable/disable:');
  print('   ENABLE_MODULE_${moduleNameSnake.toUpperCase()}=true');
  print('');
  print('🚀 Your module is ready! Run your app to see it in action.');
  print('');
}

// ============================================================================
// INPUT HELPERS
// ============================================================================

String _askModuleName() {
  stdout.write('📦 Enter module name (e.g., "CRM", "Inventory System"): ');
  final input = stdin.readLineSync()?.trim() ?? '';
  
  if (input.isEmpty) {
    print('❌ Error: Module name is required');
    exit(1);
  }
  
  return input;
}

String _askDescription(String moduleNameDisplay) {
  stdout.write('📝 Enter module description (default: "$moduleNameDisplay module"): ');
  final input = stdin.readLineSync()?.trim() ?? '';
  
  return input.isEmpty ? '$moduleNameDisplay module' : input;
}

List<Map<String, String>> _askWorkspaces(String moduleNameSnake, String moduleNameDisplay) {
  stdout.write('📂 How many workspaces? (default: 1): ');
  final countInput = stdin.readLineSync()?.trim() ?? '';
  final count = int.tryParse(countInput) ?? 1;
  
  if (count < 1) {
    print('❌ Error: At least 1 workspace is required');
    exit(1);
  }
  
  final workspaces = <Map<String, String>>[];
  
  for (var i = 0; i < count; i++) {
    String workspaceInput;
    
    if (count == 1) {
      // Default to module display name for single workspace
      stdout.write('   Workspace name (default: "$moduleNameDisplay"): ');
      final input = stdin.readLineSync()?.trim() ?? '';
      workspaceInput = input.isEmpty ? moduleNameDisplay : input;
    } else {
      stdout.write('   Workspace ${i + 1} name: ');
      workspaceInput = stdin.readLineSync()?.trim() ?? '';
      
      if (workspaceInput.isEmpty) {
        print('❌ Error: Workspace name is required');
        exit(1);
      }
    }
    
    final snakeName = _toSnakeCase(workspaceInput);
    final pascalName = _toPascalCase(snakeName);
    final displayName = workspaceInput; // Keep original capitalization from user input
    
    workspaces.add({
      'snake': snakeName,
      'pascal': pascalName,
      'display': displayName,
    });
  }
  
  return workspaces;
}

List<Map<String, dynamic>> _askQuickActions(String moduleNameSnake, String moduleNameDisplay) {
  stdout.write('⚡ How many quick actions? (default: 1): ');
  final countInput = stdin.readLineSync()?.trim() ?? '';
  final count = int.tryParse(countInput) ?? 1;
  
  if (count < 0) {
    return [];
  }
  
  final quickActions = <Map<String, dynamic>>[];
  
  for (var i = 0; i < count; i++) {
    String actionLabel;
    
    if (count == 1 && i == 0) {
      // Default to module name for single quick action
      stdout.write('   Quick action label (default: "$moduleNameDisplay"): ');
      final input = stdin.readLineSync()?.trim() ?? '';
      actionLabel = input.isEmpty ? moduleNameDisplay : input;
    } else {
      stdout.write('   Quick action ${i + 1} label: ');
      actionLabel = stdin.readLineSync()?.trim() ?? '';
      
      if (actionLabel.isEmpty) {
        print('❌ Error: Quick action label is required');
        exit(1);
      }
    }
    
    final snakeName = _toSnakeCase(actionLabel);
    
    quickActions.add({
      'id': '${moduleNameSnake}_$snakeName',
      'label': actionLabel,
      'order': 50 + i,
    });
  }
  
  return quickActions;
}

// ============================================================================
// GENERATION
// ============================================================================

void _generateModule({
  required String moduleNameSnake,
  required String moduleNamePascal,
  required String moduleNameDisplay,
  required String description,
  required List<Map<String, String>> workspaces,
  required List<Map<String, dynamic>> quickActions,
}) {
  final basePath = 'modules/$moduleNameSnake';
  final libPath = '$basePath/lib';
  final screensPath = '$libPath/screens';
  final l10nPath = '$libPath/l10n';
  final stringsPath = '$l10nPath/strings';
  final testPath = '$basePath/test';
  
  print('📁 Creating directories...');
  _createDirectory(basePath);
  _createDirectory(libPath);
  _createDirectory(screensPath);
  _createDirectory(l10nPath);
  _createDirectory(stringsPath);
  _createDirectory(testPath);
  
  // Create workspace directories and screens
  for (final workspace in workspaces) {
    final workspacePath = '$screensPath/${workspace['snake']}';
    _createDirectory(workspacePath);
    
    // Create list screen
    print('📝 Creating ${workspace['display']} list screen...');
    _createFile(
      '$workspacePath/${workspace['snake']}_list_screen.dart',
      _generateListScreenCode(
        moduleNameSnake: moduleNameSnake,
        moduleNamePascal: moduleNamePascal,
        workspaceSnake: workspace['snake']!,
        workspacePascal: workspace['pascal']!,
        workspaceDisplay: workspace['display']!,
      ),
    );
    
    // Create form screen
    print('📝 Creating ${workspace['display']} form screen...');
    _createFile(
      '$workspacePath/${workspace['snake']}_form_screen.dart',
      _generateFormScreenCode(
        moduleNameSnake: moduleNameSnake,
        moduleNamePascal: moduleNamePascal,
        workspaceSnake: workspace['snake']!,
        workspacePascal: workspace['pascal']!,
        workspaceDisplay: workspace['display']!,
      ),
    );
  }
  
  // Create l10n files
  print('📝 Creating l10n files...');
  _createFile(
    '$stringsPath/id_strings.dart',
    _generateIdStringsCode(
      moduleNameSnake: moduleNameSnake,
      moduleNameDisplay: moduleNameDisplay,
      description: description,
      workspaces: workspaces,
    ),
  );
  _createFile(
    '$stringsPath/en_strings.dart',
    _generateEnStringsCode(
      moduleNameSnake: moduleNameSnake,
      moduleNameDisplay: moduleNameDisplay,
      description: description,
      workspaces: workspaces,
    ),
  );
  _createFile(
    '$l10nPath/${moduleNameSnake}_localizations.dart',
    _generateLocalizationsCode(
      moduleNameSnake: moduleNameSnake,
      moduleNamePascal: moduleNamePascal,
      workspaces: workspaces,
    ),
  );
  _createFile(
    '$l10nPath/l10n.dart',
    _generateL10nBarrelCode(moduleNameSnake),
  );
  
  // Create module file
  print('📝 Creating module file...');
  _createFile(
    '$libPath/${moduleNameSnake}_module.dart',
    _generateModuleCode(
      moduleNameSnake: moduleNameSnake,
      moduleNamePascal: moduleNamePascal,
      moduleNameDisplay: moduleNameDisplay,
      description: description,
      workspaces: workspaces,
      quickActions: quickActions,
    ),
  );
  
  // Create library export file
  print('📝 Creating library export file...');
  _createFile(
    '$libPath/$moduleNameSnake.dart',
    _generateLibraryCode(moduleNameSnake, moduleNamePascal),
  );
  
  // Create pubspec.yaml
  print('📝 Creating pubspec.yaml...');
  _createFile(
    '$basePath/pubspec.yaml',
    _generatePubspecCode(moduleNameSnake, description),
  );
  
  // Create README.md
  print('📝 Creating README.md...');
  _createFile(
    '$basePath/README.md',
    _generateReadmeCode(moduleNameDisplay, description, workspaces),
  );
  
  // Create LICENSE
  print('📝 Creating LICENSE...');
  _createFile(
    '$basePath/LICENSE',
    _generateLicenseCode(),
  );
  
  // Create test file
  print('📝 Creating test file...');
  _createFile(
    '$testPath/${moduleNameSnake}_test.dart',
    _generateTestCode(moduleNameSnake, moduleNamePascal),
  );
  
  // Create .gitignore for module
  print('📝 Creating .gitignore...');
  _createFile(
    '$basePath/.gitignore',
    _generateGitignoreCode(),
  );
}

// ============================================================================
// FILE HELPERS
// ============================================================================

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

// ============================================================================
// STRING HELPERS
// ============================================================================

String _toSnakeCase(String input) {
  // Replace spaces, dashes, and camelCase with underscores
  return input
      .replaceAll(RegExp(r'[\s\-]+'), '_')
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)}_${match.group(2)}',
      )
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]'), '')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

String _toPascalCase(String snakeCase) {
  return snakeCase
      .split('_')
      .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
      .join('');
}

// ============================================================================
// CODE GENERATORS
// ============================================================================

String _generateModuleCode({
  required String moduleNameSnake,
  required String moduleNamePascal,
  required String moduleNameDisplay,
  required String description,
  required List<Map<String, String>> workspaces,
  required List<Map<String, dynamic>> quickActions,
}) {
  // Generate imports for screens
  final screenImports = workspaces.map((w) {
    return "import 'screens/${w['snake']}/${w['snake']}_list_screen.dart';\n"
           "import 'screens/${w['snake']}/${w['snake']}_form_screen.dart';";
  }).join('\n');
  
  // Generate routes for each workspace
  final routesList = workspaces.map((w) {
    final snake = w['snake'];
    final pascal = w['pascal'];
    // ignore: unused_local_variable
    final display = w['display']; // Reserved for future use
    return '''
    GoRoute(
      path: '/$moduleNameSnake/$snake',
      name: '${moduleNameSnake}_$snake',
      builder: (context, state) => const ${pascal}ListScreen(),
      routes: [
        GoRoute(
          path: 'form',
          name: '${moduleNameSnake}_${snake}_add',
          builder: (context, state) => const ${pascal}FormScreen(),
        ),
        GoRoute(
          path: 'form/:id',
          name: '${moduleNameSnake}_${snake}_edit',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '0';
            return ${pascal}FormScreen(id: id);
          },
        ),
      ],
    ),''';
  }).join('\n');
  
  // Generate menu items for each workspace
  final menuItemsList = workspaces.asMap().entries.map((entry) {
    final i = entry.key;
    final w = entry.value;
    return '''
    NavigationItem(
      id: '${moduleNameSnake}_${w['snake']}',
      label: '${w['display']}',
      icon: Icons.folder_outlined,
      route: '/$moduleNameSnake/${w['snake']}',
      order: ${50 + i},
    ),''';
  }).join('\n');
  
  // Generate quick actions
  final quickActionsList = quickActions.asMap().entries.map((entry) {
    final i = entry.key;
    final q = entry.value;
    final route = i == 0 && workspaces.isNotEmpty 
        ? '/$moduleNameSnake/${workspaces.first['snake']}'
        : '/$moduleNameSnake';
    return '''
    QuickActionItem(
      id: '${q['id']}',
      moduleId: '$moduleNameSnake',
      label: '${q['label']}',
      icon: Icons.${i == 0 ? 'dashboard_outlined' : 'add_circle_outline'},
      route: '$route',
      order: ${q['order']},
      description: '${q['label']}',
    ),''';
  }).join('\n');
  
  // Generate dashboard card
  final firstWorkspace = workspaces.first;
  final dashboardRoute = '/$moduleNameSnake/${firstWorkspace['snake']}';
  final l10nExtName = _toCamelCase(moduleNameSnake);
  
  return '''import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_interface/module_interface.dart';

import 'l10n/${moduleNameSnake}_localizations.dart';
$screenImports

/// $moduleNameDisplay Module - $description
class ${moduleNamePascal}Module extends BaseModule {
  @override
  String get name => '$moduleNameSnake';

  @override
  String get displayName => '$moduleNameDisplay';

  @override
  String get version => '1.0.0';

  @override
  String get description => '$description';

  @override
  IconData get icon => Icons.business;

  @override
  List<RouteBase> get routes => [
$routesList
  ];

  @override
  Widget? get dashboardWidget => const ${moduleNamePascal}DashboardCard();

  @override
  DashboardWidgetConfig get dashboardConfig => const DashboardWidgetConfig(
    columnSpan: 1,
    rowSpan: 1,
    order: 50,
  );

  @override
  List<NavigationItem> get menuItems => [
$menuItemsList
  ];

  @override
  List<QuickActionItem> get quickActions => [
$quickActionsList
  ];

  @override
  Future<void> initialize() async {
    debugPrint('${moduleNamePascal}Module: Initialized');
  }

  @override
  Future<void> dispose() async {
    debugPrint('${moduleNamePascal}Module: Disposed');
  }
}

/// Dashboard card widget for the $moduleNameDisplay module
class ${moduleNamePascal}DashboardCard extends StatelessWidget {
  const ${moduleNamePascal}DashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.${l10nExtName}L10n;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('$dashboardRoute'),
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
                    Icons.business,
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
                    l10n.dashboardTitle,
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
                    l10n.dashboardSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

String _generateListScreenCode({
  required String moduleNameSnake,
  required String moduleNamePascal,
  required String workspaceSnake,
  required String workspacePascal,
  required String workspaceDisplay,
}) {
  final l10nExtName = _toCamelCase(moduleNameSnake);
  return '''import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/${moduleNameSnake}_localizations.dart';

/// List screen for $workspaceDisplay in $moduleNamePascal module
class ${workspacePascal}ListScreen extends StatelessWidget {
  const ${workspacePascal}ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.${l10nExtName}L10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.${workspaceSnake}Title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.searchComingSoon)),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.${workspaceSnake}WelcomeTitle,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.${workspaceSnake}WelcomeDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section Title
          Text(
            l10n.${workspaceSnake}Items,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // List Items
          ...List.generate(4, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text('\${index + 1}'),
                ),
                title: Text('\${l10n.${workspaceSnake}Item} \${index + 1}'),
                subtitle: Text(l10n.${workspaceSnake}TapToEdit),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  '/$moduleNameSnake/$workspaceSnake/form/\${index + 1}',
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/$moduleNameSnake/$workspaceSnake/form'),
        icon: const Icon(Icons.add),
        label: Text(l10n.${workspaceSnake}Add),
      ),
    );
  }
}
''';
}


String _generateFormScreenCode({
  required String moduleNameSnake,
  required String moduleNamePascal,
  required String workspaceSnake,
  required String workspacePascal,
  required String workspaceDisplay,
}) {
  final l10nExtName = _toCamelCase(moduleNameSnake);
  return '''import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/${moduleNameSnake}_localizations.dart';

/// Form screen for adding/editing $workspaceDisplay in $moduleNamePascal module
class ${workspacePascal}FormScreen extends StatefulWidget {
  final String? id;

  const ${workspacePascal}FormScreen({
    super.key,
    this.id,
  });

  @override
  State<${workspacePascal}FormScreen> createState() => _${workspacePascal}FormScreenState();
}

class _${workspacePascal}FormScreenState extends State<${workspacePascal}FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // TODO: Load data from API
    setState(() => _isLoading = true);
    
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      _nameController.text = '$workspaceDisplay Item \${widget.id}';
      _descriptionController.text = 'Description for item \${widget.id}';
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.${l10nExtName}L10n;
    setState(() => _isLoading = true);

    // TODO: Save data to API
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? l10n.${workspaceSnake}Updated : l10n.${workspaceSnake}Created,
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.${l10nExtName}L10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.${workspaceSnake}Edit : l10n.${workspaceSnake}Add),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                // TODO: Implement delete
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.${workspaceSnake}Delete),
                    content: Text(l10n.${workspaceSnake}DeleteConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.${workspaceSnake}Deleted)),
                          );
                        },
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading && isEditing
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      hintText: l10n.enterName,
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.nameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.descriptionLabel,
                      hintText: l10n.enterDescription,
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // Info card for editing
                  if (isEditing)
                    Card(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '\${l10n.editingItem} #\${widget.id}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _isLoading ? null : _saveData,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? l10n.update : l10n.save),
            ),
          ),
        ),
      ),
    );
  }
}
''';
}

String _generateLibraryCode(String moduleNameSnake, String moduleNamePascal) {
  return '''/// $moduleNamePascal Module Library
///
/// This library exports all public APIs of the $moduleNamePascal module.
library $moduleNameSnake;

// Module exports
export '${moduleNameSnake}_module.dart';

// Localization exports
export 'l10n/l10n.dart';
''';
}

String _generatePubspecCode(String moduleNameSnake, String description) {
  return '''name: $moduleNameSnake
description: $description
version: 1.0.0
publish_to: 'none' # This package is not intended for publishing

environment:
  sdk: ^3.0.0
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  go_router: ^17.0.0
  # REQUIRED: Depends on interface, not the main app
  module_interface:
    path: ../../packages/module_interface

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
''';
}

String _generateReadmeCode(
  String moduleNameDisplay,
  String description,
  List<Map<String, String>> workspaces,
) {
  final workspaceList = workspaces
      .map((w) => '- **${w['display']}**: List and form screens')
      .join('\n');
  
  return '''# $moduleNameDisplay Module

$description

## Features

$workspaceList

## Installation

1. Add to your main app's `pubspec.yaml`:

```yaml
dependencies:
  ${_toSnakeCase(moduleNameDisplay)}:
    path: modules/${_toSnakeCase(moduleNameDisplay)}
```

2. Register the module in `lib/modules/all_modules.dart`

3. Enable in `.env`:

```env
ENABLE_MODULE_${_toSnakeCase(moduleNameDisplay).toUpperCase()}=true
```

4. Run `flutter pub get`

## Structure

```
lib/
├── ${_toSnakeCase(moduleNameDisplay)}.dart          # Library exports
├── ${_toSnakeCase(moduleNameDisplay)}_module.dart   # Module definition
└── screens/
${workspaces.map((w) => '    └── ${w['snake']}/\n        ├── ${w['snake']}_list_screen.dart\n        └── ${w['snake']}_form_screen.dart').join('\n')}
```

## License

MIT License - See LICENSE file for details.
''';
}

String _generateLicenseCode() {
  final year = DateTime.now().year;
  return '''MIT License

Copyright (c) $year

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
''';
}

String _generateTestCode(String moduleNameSnake, String moduleNamePascal) {
  return '''import 'package:flutter_test/flutter_test.dart';
import 'package:$moduleNameSnake/$moduleNameSnake.dart';

void main() {
  group('${moduleNamePascal}Module', () {
    late ${moduleNamePascal}Module module;

    setUp(() {
      module = ${moduleNamePascal}Module();
    });

    test('should have correct name', () {
      expect(module.name, '$moduleNameSnake');
    });

    test('should have correct version', () {
      expect(module.version, '1.0.0');
    });

    test('should have routes', () {
      expect(module.routes, isNotEmpty);
    });

    test('should have menu items', () {
      expect(module.menuItems, isNotEmpty);
    });

    test('should have quick actions', () {
      expect(module.quickActions, isNotEmpty);
    });

    test('should have dashboard widget', () {
      expect(module.dashboardWidget, isNotNull);
    });
  });
}
''';
}

String _generateGitignoreCode() {
  return '''# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/

# Platform specific
*.lock
''';
}

// ============================================================================
// L10N CODE GENERATORS
// ============================================================================

String _generateIdStringsCode({
  required String moduleNameSnake,
  required String moduleNameDisplay,
  required String description,
  required List<Map<String, String>> workspaces,
}) {
  final workspaceStrings = workspaces.map((w) {
    final snake = w['snake']!;
    final display = w['display']!;
    return '''
  // $display
  '${snake}Title': '$display',
  '${snake}WelcomeTitle': 'Selamat Datang di $display',
  '${snake}WelcomeDescription': 'Kelola data $display Anda di sini. '
      'Ketuk item untuk mengedit atau gunakan tombol di bawah untuk menambah baru.',
  '${snake}Items': 'Item $display',
  '${snake}Item': 'Item $display',
  '${snake}TapToEdit': 'Ketuk untuk edit',
  '${snake}Add': 'Tambah $display',
  '${snake}Edit': 'Edit $display',
  '${snake}Created': '$display dibuat!',
  '${snake}Updated': '$display diperbarui!',
  '${snake}Delete': 'Hapus $display',
  '${snake}DeleteConfirm': 'Apakah Anda yakin ingin menghapus item ini?',
  '${snake}Deleted': 'Item dihapus',''';
  }).join('\n');

  return '''/// Bahasa Indonesia strings for $moduleNameDisplay Module
const Map<String, String> ${moduleNameSnake}IdStrings = {
  // Module Info
  'moduleName': '$moduleNameDisplay',
  'moduleDescription': '$description',

  // Dashboard
  'dashboardTitle': '$moduleNameDisplay',
  'dashboardSubtitle': '$description',

  // Common
  'searchComingSoon': 'Pencarian segera hadir',
  'name': 'Nama',
  'enterName': 'Masukkan nama',
  'nameRequired': 'Nama harus diisi',
  'descriptionLabel': 'Deskripsi',
  'enterDescription': 'Masukkan deskripsi',
  'editingItem': 'Mengedit item',
  'update': 'Perbarui',
  'save': 'Simpan',
  'cancel': 'Batal',
  'delete': 'Hapus',
$workspaceStrings
};
''';
}

String _generateEnStringsCode({
  required String moduleNameSnake,
  required String moduleNameDisplay,
  required String description,
  required List<Map<String, String>> workspaces,
}) {
  final workspaceStrings = workspaces.map((w) {
    final snake = w['snake']!;
    final display = w['display']!;
    return '''
  // $display
  '${snake}Title': '$display',
  '${snake}WelcomeTitle': 'Welcome to $display',
  '${snake}WelcomeDescription': 'Manage your $display data here. '
      'Tap on an item to edit or use the button below to add new.',
  '${snake}Items': '$display Items',
  '${snake}Item': '$display Item',
  '${snake}TapToEdit': 'Tap to edit',
  '${snake}Add': 'Add $display',
  '${snake}Edit': 'Edit $display',
  '${snake}Created': '$display created!',
  '${snake}Updated': '$display updated!',
  '${snake}Delete': 'Delete $display',
  '${snake}DeleteConfirm': 'Are you sure you want to delete this item?',
  '${snake}Deleted': 'Item deleted',''';
  }).join('\n');

  return '''/// English strings for $moduleNameDisplay Module
const Map<String, String> ${moduleNameSnake}EnStrings = {
  // Module Info
  'moduleName': '$moduleNameDisplay',
  'moduleDescription': '$description',

  // Dashboard
  'dashboardTitle': '$moduleNameDisplay',
  'dashboardSubtitle': '$description',

  // Common
  'searchComingSoon': 'Search coming soon',
  'name': 'Name',
  'enterName': 'Enter name',
  'nameRequired': 'Name is required',
  'descriptionLabel': 'Description',
  'enterDescription': 'Enter description',
  'editingItem': 'Editing item',
  'update': 'Update',
  'save': 'Save',
  'cancel': 'Cancel',
  'delete': 'Delete',
$workspaceStrings
};
''';
}

String _generateLocalizationsCode({
  required String moduleNameSnake,
  required String moduleNamePascal,
  required List<Map<String, String>> workspaces,
}) {
  // Generate getters for each workspace
  final workspaceGetters = workspaces.map((w) {
    final snake = w['snake']!;
    return '''
  // ${w['display']} Getters
  String get ${snake}Title => translate('${snake}Title');
  String get ${snake}WelcomeTitle => translate('${snake}WelcomeTitle');
  String get ${snake}WelcomeDescription => translate('${snake}WelcomeDescription');
  String get ${snake}Items => translate('${snake}Items');
  String get ${snake}Item => translate('${snake}Item');
  String get ${snake}TapToEdit => translate('${snake}TapToEdit');
  String get ${snake}Add => translate('${snake}Add');
  String get ${snake}Edit => translate('${snake}Edit');
  String get ${snake}Created => translate('${snake}Created');
  String get ${snake}Updated => translate('${snake}Updated');
  String get ${snake}Delete => translate('${snake}Delete');
  String get ${snake}DeleteConfirm => translate('${snake}DeleteConfirm');
  String get ${snake}Deleted => translate('${snake}Deleted');''';
  }).join('\n');

  return '''import 'package:flutter/material.dart';

import 'strings/en_strings.dart';
import 'strings/id_strings.dart';

/// Delegate untuk ${moduleNamePascal}Localizations
class ${moduleNamePascal}LocalizationsDelegate
    extends LocalizationsDelegate<${moduleNamePascal}Localizations> {
  const ${moduleNamePascal}LocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['id', 'en'].contains(locale.languageCode);
  }

  @override
  Future<${moduleNamePascal}Localizations> load(Locale locale) async {
    return ${moduleNamePascal}Localizations(locale);
  }

  @override
  bool shouldReload(${moduleNamePascal}LocalizationsDelegate old) => false;
}

/// Class utama untuk lokalisasi $moduleNamePascal Module
/// Mendukung Bahasa Indonesia (id) dan English (en)
class ${moduleNamePascal}Localizations {
  final Locale locale;

  ${moduleNamePascal}Localizations(this.locale);

  /// Helper method untuk mendapatkan instance dari BuildContext
  static ${moduleNamePascal}Localizations of(BuildContext context) {
    // Pertama coba dari Localizations
    final localizations = Localizations.of<${moduleNamePascal}Localizations>(
      context,
      ${moduleNamePascal}Localizations,
    );

    if (localizations != null) {
      return localizations;
    }

    // Fallback: gunakan locale dari context
    final locale = Localizations.localeOf(context);
    return ${moduleNamePascal}Localizations(locale);
  }

  /// Delegate untuk digunakan di MaterialApp
  static const LocalizationsDelegate<${moduleNamePascal}Localizations> delegate =
      ${moduleNamePascal}LocalizationsDelegate();

  /// Map untuk menyimpan semua string terjemahan
  static final Map<String, Map<String, String>> _localizedStrings = {
    'id': ${moduleNameSnake}IdStrings,
    'en': ${moduleNameSnake}EnStrings,
  };

  /// Mendapatkan string berdasarkan key
  String translate(String key) {
    return _localizedStrings[locale.languageCode]?[key] ??
        _localizedStrings['en']?[key] ??
        key;
  }

  // ============================================
  // MODULE INFO
  // ============================================
  String get moduleName => translate('moduleName');
  String get moduleDescription => translate('moduleDescription');

  // ============================================
  // DASHBOARD
  // ============================================
  String get dashboardTitle => translate('dashboardTitle');
  String get dashboardSubtitle => translate('dashboardSubtitle');

  // ============================================
  // COMMON
  // ============================================
  String get searchComingSoon => translate('searchComingSoon');
  String get name => translate('name');
  String get enterName => translate('enterName');
  String get nameRequired => translate('nameRequired');
  String get descriptionLabel => translate('descriptionLabel');
  String get enterDescription => translate('enterDescription');
  String get editingItem => translate('editingItem');
  String get update => translate('update');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
$workspaceGetters
}

/// Extension untuk akses mudah dari BuildContext
extension ${moduleNamePascal}LocalizationsExtension on BuildContext {
  ${moduleNamePascal}Localizations get ${_toCamelCase(moduleNameSnake)}L10n =>
      ${moduleNamePascal}Localizations.of(this);
}
''';
}

String _generateL10nBarrelCode(String moduleNameSnake) {
  return '''/// Barrel file untuk lokalisasi $moduleNameSnake Module
library;

export '${moduleNameSnake}_localizations.dart';
export 'strings/id_strings.dart';
export 'strings/en_strings.dart';
''';
}

String _toCamelCase(String snakeCase) {
  final parts = snakeCase.split('_');
  return parts.first + 
      parts.skip(1).map((word) => 
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
      ).join('');
}

// ============================================================================
// REGISTRATION HELPERS
// ============================================================================

/// Register module in pubspec.yaml
Future<void> _registerModuleToPubspec(String moduleName) async {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('   ⚠ pubspec.yaml: Not found');
    return;
  }

  String pubspecContent = pubspecFile.readAsStringSync();

  if (!pubspecContent.contains('$moduleName:')) {
    final depIndex = pubspecContent.indexOf('dependencies:');
    if (depIndex != -1) {
      // Find a good insertion point (after module_interface or at end of dependencies)
      final interfaceIndex = pubspecContent.indexOf('module_interface:');
      if (interfaceIndex != -1) {
        // Find the end of module_interface block
        final pathIndex = pubspecContent.indexOf('path:', interfaceIndex);
        if (pathIndex != -1) {
          final nextLineIndex = pubspecContent.indexOf('\n', pathIndex) + 1;
          
          // Check if there's already an "External Modules" section
          if (!pubspecContent.contains('# External Modules')) {
            final insertion = '\n  # External Modules (from modules/ folder)\n  $moduleName:\n    path: modules/$moduleName\n';
            pubspecContent = pubspecContent.substring(0, nextLineIndex) + insertion + pubspecContent.substring(nextLineIndex);
          } else {
            // Find the External Modules section and add there
            final externalIndex = pubspecContent.indexOf('# External Modules');
            final externalNextLine = pubspecContent.indexOf('\n', externalIndex) + 1;
            
            // Find the last module in External Modules section
            var insertionPoint = externalNextLine;
            var searchStart = externalNextLine;
            while (true) {
              final nextModuleIndex = pubspecContent.indexOf('\n  ', searchStart);
              if (nextModuleIndex == -1 || nextModuleIndex > pubspecContent.indexOf('\ndev_dependencies:')) {
                break;
              }
              // Check if this is still a dependency line (has path: or version)
              final lineEnd = pubspecContent.indexOf('\n', nextModuleIndex + 1);
              final nextLine = pubspecContent.substring(nextModuleIndex, lineEnd);
              if (nextLine.trim().isEmpty || nextLine.contains('dev_dependencies:')) {
                break;
              }
              insertionPoint = lineEnd + 1;
              searchStart = lineEnd + 1;
            }
            
            final insertion = '  $moduleName:\n    path: modules/$moduleName\n';
            pubspecContent = pubspecContent.substring(0, insertionPoint) + insertion + pubspecContent.substring(insertionPoint);
          }
        }
      } else {
        final nextLineIndex = pubspecContent.indexOf('\n', depIndex) + 1;
        final insertion = '  $moduleName:\n    path: modules/$moduleName\n';
        pubspecContent = pubspecContent.substring(0, nextLineIndex) + insertion + pubspecContent.substring(nextLineIndex);
      }
      pubspecFile.writeAsStringSync(pubspecContent);
      print('   📝 pubspec.yaml: Added');
    }
  } else {
    print('   ✓ pubspec.yaml: OK');
  }
}

/// Register module in all_modules.dart
Future<void> _registerModuleToAllModules(String moduleName, String moduleNamePascal) async {
  final manifestFile = File('lib/modules/all_modules.dart');
  if (!manifestFile.existsSync()) {
    print('   ⚠ all_modules.dart: Not found');
    return;
  }

  String manifestContent = manifestFile.readAsStringSync();
  
  final className = '${moduleNamePascal}Module';
  final importStatement = "import 'package:$moduleName/${moduleName}_module.dart';";
  final registrationStatement = "    ModuleRegistry.register($className());";

  if (!manifestContent.contains(importStatement)) {
    // Insert import after the last import
    final lastImportIndex = manifestContent.lastIndexOf("import '");
    final nextLineIndex = manifestContent.indexOf('\n', lastImportIndex) + 1;
    manifestContent = '${manifestContent.substring(0, nextLineIndex)}$importStatement\n${manifestContent.substring(nextLineIndex)}';
    
    // Insert registration after the last ModuleRegistry.register
    final lastRegIndex = manifestContent.lastIndexOf('ModuleRegistry.register');
    if (lastRegIndex != -1) {
      final regNextLineIndex = manifestContent.indexOf('\n', lastRegIndex) + 1;
      manifestContent = '${manifestContent.substring(0, regNextLineIndex)}$registrationStatement\n${manifestContent.substring(regNextLineIndex)}';
    }
    
    manifestFile.writeAsStringSync(manifestContent);
    print('   📝 all_modules.dart: Added');
  } else {
    print('   ✓ all_modules.dart: OK');
  }
}

