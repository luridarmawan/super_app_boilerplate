// ignore_for_file: avoid_print
import 'dart:io';

/// Add Submodule CLI Tool
///
/// Usage:
///   dart run tool/add_submodule.dart <repository_url> [module_name]
///
/// Example:
///   dart run tool/add_submodule.dart https://github.com/ihasa-id/archery_intelligence
void main(List<String> args) async {
  print('╔══════════════════════════════════════════╗');
  print('║       GIT SUBMODULE ADDER TOOL           ║');
  print('╚══════════════════════════════════════════╝');

  if (args.isEmpty) {
    print('❌ Error: Repository URL is required');
    print('Usage: dart run tool/add_submodule.dart <url> [name]');
    exit(1);
  }

  final repoUrl = args[0];
  String moduleName;
  
  if (args.length > 1) {
    moduleName = args[1];
  } else {
    // Extract name from URL: 
    // HTTPS: https://github.com/user/repo_name.git -> repo_name
    // SSH: git@github.com:user/repo-name.git -> repo-name
    moduleName = repoUrl.split('/').last.replaceAll('.git', '').split(':').last;
  }

  // Normalize module name (use underscores for folder and package names)
  moduleName = moduleName.replaceAll('-', '_').toLowerCase();

  print('📦 Adding submodule: $moduleName');
  print('🔗 URL: $repoUrl');

  // 1. Ask for template generation
  stdout.write('❓ Ingin dibuatkan template file/folder sub module? (y/N): ');
  final response = stdin.readLineSync()?.toLowerCase() ?? 'n';
  final shouldGenerateTemplate = response == 'y' || response == 'yes';

  // 2. Create modules directory if not exists
  final modulesDir = Directory('modules');
  if (!modulesDir.existsSync()) {
    modulesDir.createSync();
  }

  // 3. Run git submodule add
  print('🚀 Running git submodule add...');
  final targetPath = 'modules/$moduleName';
  final gitResult = await Process.run('git', [
    'submodule',
    'add',
    repoUrl,
    targetPath,
  ]);

  if (gitResult.exitCode != 0) {
    final stderr = gitResult.stderr.toString();
    print('❌ Git Error: $stderr');
    // If it already exists, we continue to registration
    if (!stderr.contains('already exists')) {
       exit(1);
    }
  }

  // 4. Generate Template if requested
  if (shouldGenerateTemplate) {
    _generateModuleTemplate(targetPath, moduleName);
  }

  // 5. Add to pubspec.yaml
  print('📝 Updating pubspec.yaml...');
  final pubspecFile = File('pubspec.yaml');
  String pubspecContent = pubspecFile.readAsStringSync();

  if (!pubspecContent.contains('$moduleName:')) {
    // Find dependencies section
    final depIndex = pubspecContent.indexOf('dependencies:');
    if (depIndex != -1) {
      // Find the end of dependencies or a good place to insert
      // We'll insert after the module_interface
      final interfaceIndex = pubspecContent.indexOf('module_interface:');
      if (interfaceIndex != -1) {
        final pathIndex = pubspecContent.indexOf('path: packages/module_interface', interfaceIndex);
        final nextLineIndex = pubspecContent.indexOf('\n', pathIndex) + 1;
        
        final insertion = '\n  $moduleName:\n    path: modules/$moduleName\n';
        pubspecContent = pubspecContent.substring(0, nextLineIndex) + insertion + pubspecContent.substring(nextLineIndex);
      } else {
        // Fallback: just after dependencies:
        final nextLineIndex = pubspecContent.indexOf('\n', depIndex) + 1;
        final insertion = '  $moduleName:\n    path: modules/$moduleName\n';
        pubspecContent = pubspecContent.substring(0, nextLineIndex) + insertion + pubspecContent.substring(nextLineIndex);
      }
      pubspecFile.writeAsStringSync(pubspecContent);
      print('   ✓ Added to pubspec.yaml');
    }
  } else {
    print('   ⚠ Already exists in pubspec.yaml');
  }

  // 6. Update all_modules.dart
  print('🔄 Updating module registration...');
  final manifestFile = File('lib/modules/all_modules.dart');
  String manifestContent = manifestFile.readAsStringSync();

  // Try to find the module class name from the submodule's pubspec.yaml
  String className = _toPascalCase(moduleName) + 'Module';
  
  final importStatement = "import 'package:$moduleName/${moduleName}_module.dart';";
  final registrationStatement = "    ModuleRegistry.register($className());";

  if (!manifestContent.contains(importStatement)) {
    // Insert import
    final lastImportIndex = manifestContent.lastIndexOf('import \'');
    final nextLineIndex = manifestContent.indexOf('\n', lastImportIndex) + 1;
    manifestContent = manifestContent.substring(0, nextLineIndex) + importStatement + '\n' + manifestContent.substring(nextLineIndex);
    
    // Insert registration
    final lastRegIndex = manifestContent.lastIndexOf('ModuleRegistry.register');
    final regNextLineIndex = manifestContent.indexOf('\n', lastRegIndex) + 1;
    manifestContent = manifestContent.substring(0, regNextLineIndex) + registrationStatement + '\n' + manifestContent.substring(regNextLineIndex);
    
    manifestFile.writeAsStringSync(manifestContent);
    print('   ✓ Added to all_modules.dart');
  }

  print('📦 Running flutter pub get...');
  await Process.run('flutter', ['pub', 'get']);

  print('');
  print('✅ Submodule "$moduleName" added and registered successfully!');
  print('   Path: $targetPath');
  print('');
  print('📋 Next steps:');
  print('   1. Ensure the module implements BaseModule from package:module_interface');
  print('   2. Enable the module in .env:');
  print('      ENABLE_MODULE_${moduleName.toUpperCase()}=true');
}

void _generateModuleTemplate(String targetPath, String moduleName) {
  print('🛠 Generating template for $moduleName...');
  final modulePascal = _toPascalCase(moduleName);

  // 1. Create pubspec.yaml
  final pubspecContent = '''name: $moduleName
description: $modulePascal module for Super App
version: 1.0.0

environment:
  sdk: ^3.0.0

dependencies:
  flutter:
    sdk: flutter
  module_interface:
    path: ../../packages/module_interface
''';
  _createFile('$targetPath/pubspec.yaml', pubspecContent);

  // 2. Create folder structure
  final libPath = '$targetPath/lib';
  _createDir('$libPath/screens');
  _createDir('$libPath/widgets');
  _createDir('$libPath/providers');
  _createDir('$libPath/services');

  // 3. Create module main file
  final moduleContent = '''import 'package:flutter/material.dart';
import 'package:module_interface/module_interface.dart';

class ${modulePascal}Module extends BaseModule {
  @override
  String get name => '$moduleName';

  @override
  String get version => '1.0.0';

  @override
  String get description => '$modulePascal module';

  @override
  Future<void> initialize() async {
    debugPrint('${modulePascal}Module: Initialized');
  }
}
''';
  _createFile('$libPath/${moduleName}_module.dart', moduleContent);
}

void _createDir(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
    print('   ✓ Folder created: $path');
  }
}

void _createFile(String path, String content) {
  final file = File(path);
  if (!file.existsSync()) {
    file.writeAsStringSync(content);
    print('   ✓ File created: $path');
  } else {
     print('   ⚠ File already exists: $path (skipped)');
  }
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

String _toPascalCase(String s) {
  return s.split(RegExp(r'[_-]')).map(_capitalize).join('');
}
