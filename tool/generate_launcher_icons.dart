// ignore_for_file: avoid_print
/// Tool to generate launcher icons from .env configuration
/// 
/// Usage: dart run tool/generate_launcher_icons.dart
/// 
/// This script reads LAUNCHER_ICON from .env file and updates
/// flutter_launcher_icons.yaml before running the icon generator.

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
    stdoutEncoding: const SystemEncoding(),
    stderrEncoding: const SystemEncoding(),
  );

  print(result.stdout);
  if (result.stderr.toString().isNotEmpty) {
    print(result.stderr);
  }

  if (result.exitCode == 0) {
    print('\n[SUCCESS] Launcher icons generated successfully!');
  } else {
    print('\n[FAILED] Failed to generate launcher icons');
    exit(result.exitCode);
  }
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
