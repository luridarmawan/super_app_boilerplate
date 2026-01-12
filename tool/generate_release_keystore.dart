/// Tool to generate release keystore from key.properties configuration
///
/// Usage: dart run tool/generate_release_keystore.dart
///
/// This script reads key.properties and generates a release keystore
/// using the specified password, alias, and file path.
///
/// Prerequisites:
/// 1. Copy android/key.properties.example to android/key.properties
/// 2. Edit android/key.properties with your desired passwords
/// 3. Run this script
library;

// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  print('============================================');
  print('   RELEASE KEYSTORE GENERATOR');
  print('============================================\n');

  // Read key.properties file
  final keyPropertiesFile = File('android/key.properties');
  if (!keyPropertiesFile.existsSync()) {
    print('[ERROR] android/key.properties not found!');
    print('');
    print('Please create it first:');
    print('  1. Copy android/key.properties.example to android/key.properties');
    print('  2. Edit the file and set your passwords');
    print('  3. Run this script again');
    print('');
    print('Windows:');
    print('  copy android\\key.properties.example android\\key.properties');
    print('');
    print('Mac/Linux:');
    print('  cp android/key.properties.example android/key.properties');
    exit(1);
  }

  // Parse key.properties file
  print('[INFO] Reading android/key.properties...');
  final keyPropsContent = keyPropertiesFile.readAsStringSync();
  final keyProps = _parsePropertiesFile(keyPropsContent);

  // Validate required properties
  final requiredKeys = ['storePassword', 'keyPassword', 'keyAlias', 'storeFile'];
  final missingKeys = <String>[];

  for (final key in requiredKeys) {
    if (keyProps[key] == null || keyProps[key]!.isEmpty) {
      missingKeys.add(key);
    }
  }

  if (missingKeys.isNotEmpty) {
    print('[ERROR] Missing required properties in key.properties:');
    for (final key in missingKeys) {
      print('        - $key');
    }
    exit(1);
  }

  final storePassword = keyProps['storePassword']!;
  final keyPassword = keyProps['keyPassword']!;
  final keyAlias = keyProps['keyAlias']!;
  final storeFile = keyProps['storeFile']!;

  // Validate passwords
  if (storePassword == 'YOUR_STORE_PASSWORD' || keyPassword == 'YOUR_KEY_PASSWORD') {
    print('[ERROR] Please update the passwords in key.properties!');
    print('        The default placeholder values are not allowed.');
    exit(1);
  }

  if (storePassword.length < 6) {
    print('[ERROR] storePassword must be at least 6 characters!');
    exit(1);
  }

  if (keyPassword.length < 6) {
    print('[ERROR] keyPassword must be at least 6 characters!');
    exit(1);
  }

  print('[OK] key.properties parsed successfully');
  print('');
  print('Configuration:');
  print('  - Key Alias: $keyAlias');
  print('  - Store File: android/$storeFile');
  print('  - Store Password: ${'*' * storePassword.length}');
  print('  - Key Password: ${'*' * keyPassword.length}');
  print('');

  // Determine the keystore output path
  final keystorePath = 'android/$storeFile';
  final keystoreFile = File(keystorePath);

  // Check if keystore already exists
  if (keystoreFile.existsSync()) {
    print('[WARNING] Keystore already exists at: $keystorePath');
    print('');
    stdout.write('Do you want to overwrite it? (y/N): ');
    final response = stdin.readLineSync()?.toLowerCase() ?? '';
    
    if (response != 'y' && response != 'yes') {
      print('\n[CANCELLED] Keystore generation cancelled.');
      exit(0);
    }
    
    // Delete existing keystore
    keystoreFile.deleteSync();
    print('[INFO] Existing keystore deleted.');
    print('');
  }

  // Ensure keystores directory exists
  final keystoreDir = keystoreFile.parent;
  if (!keystoreDir.existsSync()) {
    keystoreDir.createSync(recursive: true);
    print('[INFO] Created directory: ${keystoreDir.path}');
  }

  // Get organization info from user
  print('Please provide the following information for the certificate:');
  print('(Press Enter to use default values in brackets)\n');

  stdout.write('What is your first and last name? [Developer]: ');
  final cn = stdin.readLineSync()?.trim();
  final commonName = (cn == null || cn.isEmpty) ? 'Developer' : cn;

  stdout.write('What is the name of your organizational unit? [Mobile Development]: ');
  final ou = stdin.readLineSync()?.trim();
  final orgUnit = (ou == null || ou.isEmpty) ? 'Mobile Development' : ou;

  stdout.write('What is the name of your organization? [My Company]: ');
  final o = stdin.readLineSync()?.trim();
  final org = (o == null || o.isEmpty) ? 'My Company' : o;

  stdout.write('What is the name of your City or Locality? [Jakarta]: ');
  final l = stdin.readLineSync()?.trim();
  final city = (l == null || l.isEmpty) ? 'Jakarta' : l;

  stdout.write('What is the name of your State or Province? [DKI Jakarta]: ');
  final st = stdin.readLineSync()?.trim();
  final state = (st == null || st.isEmpty) ? 'DKI Jakarta' : st;

  stdout.write('What is the two-letter country code? [ID]: ');
  final c = stdin.readLineSync()?.trim();
  final country = (c == null || c.isEmpty) ? 'ID' : c;

  print('');
  print('[INFO] Certificate DN: CN=$commonName, OU=$orgUnit, O=$org, L=$city, ST=$state, C=$country');
  print('');

  // Build the keytool command
  final dname = 'CN=$commonName, OU=$orgUnit, O=$org, L=$city, ST=$state, C=$country';
  
  print('[INFO] Generating keystore...\n');

  // Run keytool command
  final result = await Process.run(
    'keytool',
    [
      '-genkey',
      '-v',
      '-keystore', keystorePath,
      '-alias', keyAlias,
      '-keyalg', 'RSA',
      '-keysize', '2048',
      '-validity', '10000',
      '-storepass', storePassword,
      '-keypass', keyPassword,
      '-dname', dname,
    ],
    runInShell: true,
  );

  // Print output
  if (result.stdout.toString().isNotEmpty) {
    print(result.stdout.toString().trim());
  }

  if (result.exitCode == 0) {
    print('');
    print('============================================');
    print('   KEYSTORE GENERATED SUCCESSFULLY!');
    print('============================================');
    print('');
    print('Keystore Location: $keystorePath');
    print('Key Alias: $keyAlias');
    print('');
    print('IMPORTANT: Keep your keystore and passwords safe!');
    print('If you lose them, you won\'t be able to update your app on Play Store.');
    print('');
    print('Next steps:');
    print('  1. Backup your keystore file to a secure location');
    print('  2. Run: flutter build apk --release');
    print('  3. Your APK will be signed with the release keystore');
    print('');
    
    // Get SHA-1 fingerprint
    print('[INFO] Getting SHA-1 fingerprint...\n');
    
    final sha1Result = await Process.run(
      'keytool',
      [
        '-list',
        '-v',
        '-keystore', keystorePath,
        '-alias', keyAlias,
        '-storepass', storePassword,
      ],
      runInShell: true,
    );

    if (sha1Result.exitCode == 0) {
      final output = sha1Result.stdout.toString();
      final sha1Match = RegExp(r'SHA1:\s*([A-Fa-f0-9:]+)').firstMatch(output);
      final sha256Match = RegExp(r'SHA256:\s*([A-Fa-f0-9:]+)').firstMatch(output);
      
      if (sha1Match != null) {
        print('SHA-1 Fingerprint:');
        print('  ${sha1Match.group(1)}');
        print('');
      }
      
      if (sha256Match != null) {
        print('SHA-256 Fingerprint:');
        print('  ${sha256Match.group(1)}');
        print('');
      }
      
      print('Add the SHA-1 fingerprint to:');
      print('  - Google Cloud Console (for Google Sign-In)');
      print('  - Firebase Console (if using Firebase)');
    }
  } else {
    print('');
    print('[ERROR] Failed to generate keystore!');
    if (result.stderr.toString().isNotEmpty) {
      print(result.stderr.toString().trim());
    }
    exit(1);
  }
}

/// Parse properties file content into a Map
Map<String, String> _parsePropertiesFile(String content) {
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
