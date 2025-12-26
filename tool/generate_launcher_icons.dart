/// Tool to generate launcher icons from .env configuration
///
/// Usage: dart run tool/generate_launcher_icons.dart
///
/// This script reads LAUNCHER_ICON from .env file and updates
/// flutter_launcher_icons.yaml before running the icon generator.
library;

// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  print('============================================');
  print('   LAUNCHER ICON GENERATOR FROM .ENV');
  print('============================================\n');

  // Read .env file
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('[ERROR] .env file not found!');
    print('        Please create .env file from .env.example');
    exit(1);
  }

  // Parse .env file
  final envContent = envFile.readAsStringSync();
  final envMap = _parseEnvFile(envContent);

  // Get LAUNCHER_ICON value
  final launcherIcon = envMap['LAUNCHER_ICON'];
  if (launcherIcon == null || launcherIcon.isEmpty) {
    print('[ERROR] LAUNCHER_ICON not found in .env file!');
    print('        Please add LAUNCHER_ICON="path/to/your/icon.png" to .env');
    exit(1);
  }

  print('[INFO] LAUNCHER_ICON from .env: $launcherIcon');

  // Verify icon file exists
  final iconFile = File(launcherIcon);
  if (!iconFile.existsSync()) {
    print('[ERROR] Icon file not found: $launcherIcon');
    exit(1);
  }
  print('[OK] Icon file exists\n');

  // Update flutter_launcher_icons.yaml
  print('[INFO] Updating flutter_launcher_icons.yaml...');
  _updateLauncherIconsYaml(launcherIcon);
  print('[OK] Configuration updated\n');

  // Run flutter_launcher_icons
  print('Running flutter_launcher_icons...\n');
  
  // Set UTF-8 encoding on Windows to display Unicode characters correctly
  if (Platform.isWindows) {
    await Process.run('chcp', ['65001'], runInShell: true);
  }
  
  final result = await Process.run(
    'dart',
    ['run', 'flutter_launcher_icons'],
    runInShell: true,
  );

  // Clean and print output
  final cleanedOutput = _cleanOutput(result.stdout.toString()).trim();
  print(cleanedOutput);
  
  if (result.stderr.toString().isNotEmpty) {
    final cleanedError = _cleanOutput(result.stderr.toString()).trim();
    print(cleanedError);
  }

  if (result.exitCode == 0) {
    print('\n[SUCCESS] Launcher icons generated successfully!');
  } else {
    print('\n[FAILED] Failed to generate launcher icons');
    exit(result.exitCode);
  }
}

/// Clean output by replacing Unicode characters with ASCII equivalents
String _cleanOutput(String input) {
  // Normalize line endings and process line by line
  final normalizedInput = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final lines = normalizedInput.split('\n');
  final cleanedLines = <String>[];
  
  for (var line in lines) {
    // Mojibake patterns (corrupted UTF-8 displayed as Windows-1252)
    final mojibakeReplacements = {
      'âš ï¸': '[!]',
      'âš ': '[!]',
      'âœ"': '[OK]',
      'âœ•': '[X]',
      'âœ—': '[X]',
      'â•': '=',
      'â€"': '-',
      'â€™': "'",
      'â€¢': '*',
      'â€': '',
      'ï¸': '',
    };
    
    for (final entry in mojibakeReplacements.entries) {
      line = line.replaceAll(entry.key, entry.value);
    }
    
    // Remove any remaining â followed by special chars
    line = line.replaceAll(RegExp(r'â[^\w\s]'), '');
    
    // Unicode replacements for when UTF-8 works correctly
    final unicodeReplacements = {
      '═': '=',
      '╔': '+',
      '╗': '+',
      '╚': '+',
      '╝': '+',
      '║': '|',
      '─': '-',
      '✓': '[OK]',
      '✔': '[OK]',
      '✕': '[X]',
      '✗': '[X]',
      '•': '*',
      '⚠️': '[!]',
      '⚠': '[!]',
    };
    
    for (final entry in unicodeReplacements.entries) {
      line = line.replaceAll(entry.key, entry.value);
    }
    
    // Fix lone quote at start of line (leftover from mojibake)
    // Handle various quote characters: " " " ″ ʺ
    line = line.replaceAll(RegExp(r'^[""\u201C\u201D\u2033\u02BA] '), '[OK] ');
    
    // Skip irrelevant warning lines for mobile-only projects
    if (line.contains('web\\index.html') || 
        line.contains('web/index.html') ||
        line.contains('.\\web') ||
        line.contains('./web') ||
        line.contains('.\\windows') ||
        line.contains('./windows') ||
        line.contains('.\\macos') ||
        line.contains('./macos') ||
        line.contains('Requirements failed for platform') ||
        line.contains('FormatException: Unexpected end of input') ||
        line.trim() == '^') {
      continue;
    }
    
    cleanedLines.add(line);
  }
  
  // Remove consecutive empty lines
  final result = <String>[];
  var lastWasEmpty = false;
  for (var line in cleanedLines) {
    // Clean any remaining carriage return
    line = line.replaceAll('\r', '');
    final isEmpty = line.trim().isEmpty;
    if (isEmpty && lastWasEmpty) {
      continue; // Skip consecutive empty lines
    }
    result.add(line);
    lastWasEmpty = isEmpty;
  }
  
  return result.join('\n');
}

/// Parse .env file content into a Map
Map<String, String> _parseEnvFile(String content) {
  final map = <String, String>{};
  final lines = content.split('\n');

  for (var line in lines) {
    line = line.trim();
    
    // Skip comments and empty lines
    if (line.isEmpty || line.startsWith('#')) continue;

    // Find the first '=' character
    final equalsIndex = line.indexOf('=');
    if (equalsIndex == -1) continue;

    final key = line.substring(0, equalsIndex).trim();
    var value = line.substring(equalsIndex + 1).trim();

    // Remove surrounding quotes if present
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1);
    }

    map[key] = value;
  }

  return map;
}

/// Update flutter_launcher_icons.yaml with the new icon path
void _updateLauncherIconsYaml(String iconPath) {
  final yamlContent = '''# flutter_launcher_icons configuration
# Auto-generated from .env LAUNCHER_ICON
# Do not edit manually - run: dart run tool/generate_launcher_icons.dart

flutter_launcher_icons:
  image_path: "$iconPath"

  android: "launcher_icon"
  min_sdk_android: 21
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "$iconPath"

  ios: true
  remove_alpha_ios: true

  web:
    generate: true
    image_path: "$iconPath"
    background_color: "#FFFFFF"
    theme_color: "#1565C0"

  windows:
    generate: true
    image_path: "$iconPath"
    icon_size: 48

  macos:
    generate: true
    image_path: "$iconPath"
''';

  File('flutter_launcher_icons.yaml').writeAsStringSync(yamlContent);
}
