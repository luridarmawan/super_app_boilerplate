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

  // 1. Create modules directory if not exists
  final modulesDir = Directory('modules');
  if (!modulesDir.existsSync()) {
    modulesDir.createSync();
  }

  // 2. Run git submodule add
  print('🚀 Running git submodule add...');
  final targetPath = 'modules/$moduleName';
  final gitResult = await Process.run('git', [
    'submodule',
    'add',
    repoUrl,
    targetPath,
  ]);

  if (gitResult.exitCode != 0) {
    print('❌ Git Error: ${gitResult.stderr}');
    // If it already exists, we continue to registration
    if (!gitResult.stderr.toString().contains('already exists')) {
       exit(1);
    }
  }

  // 3. Add to pubspec.yaml
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

  // 4. Update all_modules.dart
  print('🔄 Updating module registration...');
  final manifestFile = File('lib/modules/all_modules.dart');
  String manifestContent = manifestFile.readAsStringSync();

  // Try to find the module class name from the submodule's pubspec.yaml
  String className = _toPascalCase(moduleName) + 'Module';
  final subPubspecFile = File('$targetPath/pubspec.yaml');
  if (subPubspecFile.existsSync()) {
    final subName = subPubspecFile.readAsStringSync().split('\n').firstWhere((l) => l.startsWith('name:'), orElse: () => '').split(':').last.trim();
    if (subName.isNotEmpty) {
      // If the package name is different from folder name
      // but usually they match
    }
  }

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

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

String _toPascalCase(String s) {
  return s.split(RegExp(r'[_-]')).map(_capitalize).join('');
}
