// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  syncModules();
}

void syncModules() {
  print('🔄 Syncing modules...');

  final modulesDir = Directory('lib/modules');
  if (!modulesDir.existsSync()) {
    print('❌ Error: lib/modules directory not found');
    return;
  }

  final List<String> imports = [];
  final List<String> registrations = [];

  final entities = modulesDir.listSync(recursive: true);
  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('_module.dart')) {
      final path = entity.path;
      final fileName = path.split(Platform.pathSeparator).last;
      
      if (fileName == 'module_base.dart' || fileName == 'all_modules.dart') continue;

      try {
        final content = entity.readAsStringSync();
        final classMatch = RegExp(r'class\s+(\w+)\s+extends\s+BaseModule').firstMatch(content);
        
        if (classMatch != null) {
          final className = classMatch.group(1)!;
          
          // Normalize path for registration
          String relativePath;
          if (path.contains('lib/modules/')) {
            relativePath = path.split('lib/modules/').last;
          } else if (path.contains('lib\\modules\\')) {
            relativePath = path.split('lib\\modules\\').last;
          } else {
            // Fallback for different path formats
            relativePath = path.replaceAll('\\', '/').split('/modules/').last;
          }
          
          relativePath = relativePath.replaceAll('\\', '/');

          imports.add("import '$relativePath';");
          registrations.add("    ModuleRegistry.register($className());");
          print('   ✓ Found: $className ($relativePath)');
        }
      } catch (e) {
        print('   ⚠ Error reading $path: $e');
      }
    }
  }

  imports.sort();
  registrations.sort();

  final manifestContent = '''import 'module_registry.dart';
${imports.join('\n')}

/// Auto-generated file. Do not edit manually.
/// This file registers all available modules to the registry.
class ModuleManifest {
  static void register() {
${registrations.join('\n')}
  }
}
''';

  File('lib/modules/all_modules.dart').writeAsStringSync(manifestContent);
  print('✅ lib/modules/all_modules.dart updated successfully!');
}
