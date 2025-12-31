// ignore_for_file: avoid_print
import 'dart:io';
import 'package:yaml/yaml.dart';

/// External Module Manager CLI Tool
///
/// Mengelola modul eksternal berdasarkan konfigurasi di modules.yaml
/// Strategi ini menghindari penggunaan git submodule agar tidak mengubah
/// file .gitmodules di repository utama.
///
/// Usage:
///   dart run tool/manage_external_modules.dart           # Clone modul yang belum ada
///   dart run tool/manage_external_modules.dart --pull    # Update semua modul
///   dart run tool/manage_external_modules.dart --status  # Cek status semua modul
///   dart run tool/manage_external_modules.dart --clean   # Hapus semua modul
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
    print('⚠️  File modules.yaml tidak ditemukan!');
    print('');
    print('📋 Cara setup:');
    print('   1. Copy modules.yaml.example menjadi modules.yaml');
    print('   2. Edit modules.yaml sesuai kebutuhan');
    print('   3. Jalankan ulang: dart run tool/manage_external_modules.dart');
    print('');
    exit(1);
  }

  final manifestContent = manifestFile.readAsStringSync();
  final yaml = loadYaml(manifestContent);
  
  if (yaml == null || yaml['modules'] == null) {
    print('⚠️  Tidak ada modul yang dikonfigurasi di modules.yaml');
    exit(0);
  }

  final modules = yaml['modules'] as YamlList;
  
  if (modules.isEmpty) {
    print('⚠️  Daftar modul kosong di modules.yaml');
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
  print('📦 Ditemukan ${modules.length} modul di manifest');
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
      print('⏭️  $name: Dilewati (enabled: false)');
      continue;
    }

    final targetPath = 'modules/$name';
    final targetDir = Directory(targetPath);

    if (targetDir.existsSync()) {
      if (pullUpdates) {
        print('🔄 $name: Mengupdate dari $branch...');
        
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
        print('✓ $name: Sudah ada');
      }
    } else {
      print('📥 $name: Cloning dari $url (branch: $branch)...');
      
      final cloneResult = await Process.run(
        'git', ['clone', '-b', branch, url, targetPath],
        runInShell: true,
      );

      if (cloneResult.exitCode == 0) {
        print('   ✓ Cloned successfully');
        
        // Register in pubspec.yaml
        await _registerModule(name, targetPath);
        
        // Register in all_modules.dart
        await _registerModuleManifest(name);
      } else {
        print('   ❌ Clone failed: ${cloneResult.stderr}');
      }
    }
  }
}

Future<void> _checkStatus(YamlList modules) async {
  print('📊 Status Modul:');
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
  print('🗑️  Menghapus modul...');
  
  for (final module in modules) {
    final name = module['name'] as String;
    final targetPath = 'modules/$name';
    final targetDir = Directory(targetPath);

    if (targetDir.existsSync()) {
      stdout.write('❓ Hapus $name? (y/N): ');
      final response = stdin.readLineSync()?.toLowerCase() ?? 'n';
      
      if (response == 'y' || response == 'yes') {
        try {
          targetDir.deleteSync(recursive: true);
          print('   ✓ $name dihapus');
        } catch (e) {
          print('   ❌ Gagal menghapus: $e');
        }
      } else {
        print('   ⏭️  Dilewati');
      }
    }
  }
}

Future<void> _registerModule(String moduleName, String targetPath) async {
  print('   📝 Registering in pubspec.yaml...');
  
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
      print('      ✓ Added to pubspec.yaml');
    }
  } else {
    print('      ⚠ Already in pubspec.yaml');
  }
}

Future<void> _registerModuleManifest(String moduleName) async {
  print('   📝 Registering in all_modules.dart...');
  
  final manifestFile = File('lib/modules/all_modules.dart');
  if (!manifestFile.existsSync()) {
    print('      ⚠ all_modules.dart not found, skipping registration');
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
    print('      ✓ Added to all_modules.dart');
  } else {
    print('      ⚠ Already in all_modules.dart');
  }
}

void _printHelp() {
  print('''
External Module Manager - Mengelola modul eksternal tanpa git submodule

Usage:
  dart run tool/manage_external_modules.dart [options]

Options:
  (tanpa opsi)  Clone modul yang belum ada
  --pull, -p    Update semua modul dari remote
  --status, -s  Tampilkan status semua modul
  --clean, -c   Hapus modul (dengan konfirmasi)
  --help, -h    Tampilkan bantuan ini

Konfigurasi:
  Edit file modules.yaml untuk menambah/mengubah modul.
  Gunakan modules.yaml.example sebagai template.

Strategi:
  Tool ini menggunakan git clone biasa (bukan submodule) sehingga
  tidak ada perubahan di .gitmodules pada repository utama.
  Folder modules/ di-gitignore agar tidak ter-track.

Contoh:
  dart run tool/manage_external_modules.dart           # Setup awal
  dart run tool/manage_external_modules.dart --pull    # Update semua
  dart run tool/manage_external_modules.dart --status  # Cek status
''');
}
