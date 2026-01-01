// ignore_for_file: avoid_print
import 'dart:io';
import 'package:yaml/yaml.dart';

/// External Module Manager CLI Tool
///
/// Manages external modules based on configuration in modules.yaml
/// This strategy avoids using git submodule to prevent changes
/// to the .gitmodules file in the main repository.
///
/// Usage:
///   dart run tool/manage_external_modules.dart           # Clone modules that don't exist
///   dart run tool/manage_external_modules.dart --pull    # Update all modules
///   dart run tool/manage_external_modules.dart --status  # Check status of all modules
///   dart run tool/manage_external_modules.dart --clean   # Delete all modules
void main(List<String> args) async {
  print('╔══════════════════════════════════════════╗');
  print('║     EXTERNAL MODULE MANAGER              ║');
  print('╚══════════════════════════════════════════╝');

  // Parse arguments early so --help works without modules.yaml
  final isHelp = args.contains('--help') || args.contains('-h');
  if (isHelp) {
    _printHelp();
    exit(0);
  }

  final manifestFile = File('modules.yaml');
  
  if (!manifestFile.existsSync()) {
    print('');
    print('⚠️  File modules.yaml not found!');
    print('');
    print('📋 Setup instructions:');
    print('   1. Copy modules.yaml.example to modules.yaml');
    print('   2. Edit modules.yaml according to your needs');
    print('   3. Run again: dart run tool/manage_external_modules.dart');
    print('');
    exit(1);
  }

  final manifestContent = manifestFile.readAsStringSync();
  final yaml = loadYaml(manifestContent);
  
  if (yaml == null || yaml['modules'] == null) {
    print('⚠️  No modules configured in modules.yaml');
    exit(0);
  }

  final modules = yaml['modules'] as YamlList;
  
  if (modules.isEmpty) {
    print('⚠️  Module list is empty in modules.yaml');
    exit(0);
  }

  // Parse arguments
  final isPull = args.contains('--pull') || args.contains('-p');
  final isStatus = args.contains('--status') || args.contains('-s');
  final isClean = args.contains('--clean') || args.contains('-c');

  // Ensure modules directory exists
  final modulesDir = Directory('modules');
  if (!modulesDir.existsSync()) {
    modulesDir.createSync();
  }

  print('');
  print('📦 Found ${modules.length} modules in manifest');
  print('');

  if (isStatus) {
    await _checkStatus(modules);
  } else if (isClean) {
    await _cleanModules(modules);
  } else {
    await _syncModules(modules, pullUpdates: isPull);
  }

  // Run flutter pub get if any modules were synced
  if (!isStatus && !isClean) {
    print('');
    print('📦 Running flutter pub get...');
    final pubResult = await Process.run('flutter', ['pub', 'get'], runInShell: true);
    if (pubResult.exitCode == 0) {
      print('   ✓ Dependencies updated');
    } else {
      print('   ⚠ flutter pub get failed: ${pubResult.stderr}');
    }
  }

  print('');
  print('✅ Done!');
}

Future<void> _syncModules(YamlList modules, {bool pullUpdates = false}) async {
  for (final module in modules) {
    final name = module['name'] as String;
    final url = module['url'] as String;
    final branch = module['branch'] as String? ?? 'main';
    final enabled = module['enabled'] as bool? ?? true;

    if (!enabled) {
      print('⏭️  $name: Skipped (enabled: false)');
      continue;
    }

    final targetPath = 'modules/$name';
    final targetDir = Directory(targetPath);

    if (targetDir.existsSync()) {
      if (pullUpdates) {
        print('🔄 $name: Updating from $branch...');
        
        // Fetch and pull
        final fetchResult = await Process.run(
          'git', ['fetch', 'origin', branch],
          workingDirectory: targetPath,
          runInShell: true,
        );
        
        if (fetchResult.exitCode != 0) {
          print('   ❌ Fetch failed: ${fetchResult.stderr}');
          continue;
        }

        final pullResult = await Process.run(
          'git', ['pull', 'origin', branch],
          workingDirectory: targetPath,
          runInShell: true,
        );

        if (pullResult.exitCode == 0) {
          print('   ✓ Updated successfully');
        } else {
          print('   ❌ Pull failed: ${pullResult.stderr}');
        }
      } else {
        print('✓ $name: Already exists');
      }
      
      // Always verify registration even if module already exists
      await _verifyRegistration(name, targetPath);
    } else {
      print('📥 $name: Cloning from $url (branch: $branch)...');
      
      final cloneResult = await Process.run(
        'git', ['clone', '-b', branch, url, targetPath],
        runInShell: true,
      );

      if (cloneResult.exitCode == 0) {
        print('   ✓ Cloned successfully');
        
        // Register in pubspec.yaml and all_modules.dart
        await _verifyRegistration(name, targetPath);
      } else {
        print('   ❌ Clone failed: ${cloneResult.stderr}');
      }
    }
  }
}

/// Verify and fix module registration in pubspec.yaml and all_modules.dart
Future<void> _verifyRegistration(String moduleName, String targetPath) async {
  print('   🔍 Verifying registration...');
  
  // Check and register in pubspec.yaml
  await _registerModule(moduleName, targetPath);
  
  // Check and register in all_modules.dart
  await _registerModuleManifest(moduleName);
}

Future<void> _checkStatus(YamlList modules) async {
  print('📊 Module Status:');
  print('─' * 60);
  
  for (final module in modules) {
    final name = module['name'] as String;
    final branch = module['branch'] as String? ?? 'main';
    final enabled = module['enabled'] as bool? ?? true;
    final targetPath = 'modules/$name';
    final targetDir = Directory(targetPath);

    if (!enabled) {
      print('⏸️  $name: Disabled');
      continue;
    }

    if (!targetDir.existsSync()) {
      print('❌ $name: Not cloned');
      continue;
    }

    // Get current branch
    final branchResult = await Process.run(
      'git', ['branch', '--show-current'],
      workingDirectory: targetPath,
      runInShell: true,
    );
    final currentBranch = branchResult.stdout.toString().trim();

    // Get status
    final statusResult = await Process.run(
      'git', ['status', '--porcelain'],
      workingDirectory: targetPath,
      runInShell: true,
    );
    final hasChanges = statusResult.stdout.toString().trim().isNotEmpty;

    // Get last commit
    final logResult = await Process.run(
      'git', ['log', '-1', '--format=%h %s'],
      workingDirectory: targetPath,
      runInShell: true,
    );
    final lastCommit = logResult.stdout.toString().trim();

    final branchStatus = currentBranch == branch ? '✓' : '⚠️ ($currentBranch)';
    final changeStatus = hasChanges ? '📝 modified' : '✓ clean';
    
    print('$branchStatus $name [$changeStatus]');
    print('   └─ $lastCommit');
  }
  print('─' * 60);
}

Future<void> _cleanModules(YamlList modules) async {
  print('🗑️  Deleting modules...');
  
  for (final module in modules) {
    final name = module['name'] as String;
    final targetPath = 'modules/$name';
    final targetDir = Directory(targetPath);

    if (targetDir.existsSync()) {
      stdout.write('❓ Delete $name? (y/N): ');
      final response = stdin.readLineSync()?.toLowerCase() ?? 'n';
      
      if (response == 'y' || response == 'yes') {
        try {
          targetDir.deleteSync(recursive: true);
          print('   ✓ $name deleted');
        } catch (e) {
          print('   ❌ Failed to delete: $e');
        }
      } else {
        print('   ⏭️  Skipped');
      }
    }
  }
}

Future<void> _registerModule(String moduleName, String targetPath) async {
  final pubspecFile = File('pubspec.yaml');
  String pubspecContent = pubspecFile.readAsStringSync();

  if (!pubspecContent.contains('$moduleName:')) {
    final depIndex = pubspecContent.indexOf('dependencies:');
    if (depIndex != -1) {
      final interfaceIndex = pubspecContent.indexOf('module_interface:');
      if (interfaceIndex != -1) {
        final pathIndex = pubspecContent.indexOf('path: packages/module_interface', interfaceIndex);
        final nextLineIndex = pubspecContent.indexOf('\n', pathIndex) + 1;
        
        final insertion = '\n  $moduleName:\n    path: modules/$moduleName\n';
        pubspecContent = pubspecContent.substring(0, nextLineIndex) + insertion + pubspecContent.substring(nextLineIndex);
      } else {
        final nextLineIndex = pubspecContent.indexOf('\n', depIndex) + 1;
        final insertion = '  $moduleName:\n    path: modules/$moduleName\n';
        pubspecContent = pubspecContent.substring(0, nextLineIndex) + insertion + pubspecContent.substring(nextLineIndex);
      }
      pubspecFile.writeAsStringSync(pubspecContent);
      print('      📝 pubspec.yaml: Added');
    }
  } else {
    print('      ✓ pubspec.yaml: OK');
  }
}

Future<void> _registerModuleManifest(String moduleName) async {
  final manifestFile = File('lib/modules/all_modules.dart');
  if (!manifestFile.existsSync()) {
    print('      ⚠ all_modules.dart: Not found, skipping');
    return;
  }

  String manifestContent = manifestFile.readAsStringSync();
  
  String toPascalCase(String s) {
    return s.split(RegExp(r'[_-]')).map((part) {
      if (part.isEmpty) return part;
      return part[0].toUpperCase() + part.substring(1);
    }).join('');
  }

  final className = '${toPascalCase(moduleName)}Module';
  final importStatement = "import 'package:$moduleName/${moduleName}_module.dart';";
  final registrationStatement = "    ModuleRegistry.register($className());";

  if (!manifestContent.contains(importStatement)) {
    // Insert import
    final lastImportIndex = manifestContent.lastIndexOf("import '");
    final nextLineIndex = manifestContent.indexOf('\n', lastImportIndex) + 1;
    manifestContent = '${manifestContent.substring(0, nextLineIndex)}$importStatement\n${manifestContent.substring(nextLineIndex)}';
    
    // Insert registration
    final lastRegIndex = manifestContent.lastIndexOf('ModuleRegistry.register');
    if (lastRegIndex != -1) {
      final regNextLineIndex = manifestContent.indexOf('\n', lastRegIndex) + 1;
      manifestContent = '${manifestContent.substring(0, regNextLineIndex)}$registrationStatement\n${manifestContent.substring(regNextLineIndex)}';
    }
    
    manifestFile.writeAsStringSync(manifestContent);
    print('      📝 all_modules.dart: Added');
  } else {
    print('      ✓ all_modules.dart: OK');
  }
}

void _printHelp() {
  print('''
External Module Manager - Manage external modules without git submodule

Usage:
  dart run tool/manage_external_modules.dart [options]

Options:
  (no options)  Clone modules that don't exist
  --pull, -p    Update all modules from remote
  --status, -s  Show status of all modules
  --clean, -c   Delete modules (with confirmation)
  --help, -h    Show this help

Configuration:
  Edit modules.yaml file to add/modify modules.
  Use modules.yaml.example as a template.

Strategy:
  This tool uses regular git clone (not submodule) so there are
  no changes to .gitmodules in the main repository.
  The modules/ folder is gitignored so it won't be tracked.

Examples:
  dart run tool/manage_external_modules.dart           # Initial setup
  dart run tool/manage_external_modules.dart --pull    # Update all
  dart run tool/manage_external_modules.dart --status  # Check status
''');
}
