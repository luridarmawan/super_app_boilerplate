// Dart script untuk mengubah Application ID di seluruh project
// Jalankan: dart run tool/change_app_id.dart <new_app_id>
// Contoh: dart run tool/change_app_id.dart id.ihasa.app

// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) {
  print('');
  print('╔══════════════════════════════════════════════════════════════╗');
  print('║           🔧 CHANGE APPLICATION ID TOOL                      ║');
  print('╚══════════════════════════════════════════════════════════════╝');
  print('');

  // Validate arguments
  if (args.isEmpty) {
    print('❌ Error: Application ID baru harus diberikan sebagai argumen!');
    print('');
    print('📖 Penggunaan:');
    print('   dart run tool/change_app_id.dart <new_app_id>');
    print('');
    print('📝 Contoh:');
    print('   dart run tool/change_app_id.dart id.ihasa.app');
    print('   dart run tool/change_app_id.dart com.example.myapp');
    print('');
    exit(1);
  }

  final newAppId = args[0].trim();

  // Validate app ID format
  if (!_isValidAppId(newAppId)) {
    print('❌ Error: Format Application ID tidak valid!');
    print('');
    print('📋 Format yang valid:');
    print('   - Harus terdiri dari minimal 2 segmen dipisahkan titik');
    print('   - Setiap segmen harus dimulai dengan huruf');
    print('   - Hanya boleh mengandung huruf, angka, dan underscore');
    print('');
    print('📝 Contoh yang valid:');
    print('   - id.ihasa.app');
    print('   - com.example.myapp');
    print('   - org.company.app_name');
    print('');
    exit(1);
  }

  final scriptDir = File(Platform.script.toFilePath()).parent;
  final projectDir = scriptDir.parent;

  print('📁 Project directory: ${projectDir.path}');
  print('🆔 New Application ID: $newAppId');
  print('');

  // Detect current app ID from build.gradle.kts
  final currentAppId = _detectCurrentAppId(projectDir);
  if (currentAppId == null) {
    print('❌ Error: Tidak dapat mendeteksi Application ID saat ini!');
    exit(1);
  }

  if (currentAppId == newAppId) {
    print('ℹ️  Application ID sudah "$newAppId". Tidak ada perubahan.');
    exit(0);
  }

  print('📌 Current Application ID: $currentAppId');
  print('');
  print('═══════════════════════════════════════════════════════════════');
  print('🔄 Memulai proses perubahan...');
  print('═══════════════════════════════════════════════════════════════');
  print('');

  int changedFiles = 0;

  // 1. Update Android build.gradle.kts
  changedFiles += _updateBuildGradleKts(projectDir, currentAppId, newAppId);

  // 2. Update/Move MainActivity.kt
  changedFiles += _updateMainActivity(projectDir, currentAppId, newAppId);

  // 3. Update iOS project.pbxproj
  changedFiles += _updateIosProjectPbxproj(projectDir, currentAppId, newAppId);

  // 4. Update documentation files
  changedFiles += _updateDocumentation(projectDir, currentAppId, newAppId);

  print('');
  print('═══════════════════════════════════════════════════════════════');
  if (changedFiles > 0) {
    print('✅ Application ID berhasil diubah!');
    print('   Dari: $currentAppId');
    print('   Ke:   $newAppId');
    print('');
    print('📊 Total file yang diubah: $changedFiles');
  } else {
    print('⚠️  Tidak ada file yang diubah.');
  }
  print('═══════════════════════════════════════════════════════════════');
  print('');
  print('📋 Langkah selanjutnya:');
  print('   1. Jalankan: flutter clean');
  print('   2. Jalankan: flutter pub get');
  print('   3. Jika menggunakan Firebase, update google-services.json');
  print('   4. Jika menggunakan Google Sign-In, update SHA-1 di Google Cloud Console');
  print('');
}

/// Validate application ID format
bool _isValidAppId(String appId) {
  // Must have at least 2 segments
  final segments = appId.split('.');
  if (segments.length < 2) return false;

  // Each segment validation
  final segmentRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
  for (final segment in segments) {
    if (segment.isEmpty || !segmentRegex.hasMatch(segment)) {
      return false;
    }
  }

  return true;
}

/// Detect current application ID from build.gradle.kts
String? _detectCurrentAppId(Directory projectDir) {
  final buildGradleFile = File(
    '${projectDir.path}/android/app/build.gradle.kts',
  );

  if (!buildGradleFile.existsSync()) {
    print('⚠️  File build.gradle.kts tidak ditemukan');
    return null;
  }

  final content = buildGradleFile.readAsStringSync();
  final regex = RegExp(r'applicationId\s*=\s*"([^"]+)"');
  final match = regex.firstMatch(content);

  return match?.group(1);
}

/// Update Android build.gradle.kts
int _updateBuildGradleKts(
  Directory projectDir,
  String oldAppId,
  String newAppId,
) {
  final file = File('${projectDir.path}/android/app/build.gradle.kts');

  if (!file.existsSync()) {
    print('⚠️  [SKIP] android/app/build.gradle.kts tidak ditemukan');
    return 0;
  }

  var content = file.readAsStringSync();
  var changed = false;

  // Update namespace
  final namespaceRegex = RegExp(r'namespace\s*=\s*"' + RegExp.escape(oldAppId) + '"');
  if (namespaceRegex.hasMatch(content)) {
    content = content.replaceFirst(namespaceRegex, 'namespace = "$newAppId"');
    changed = true;
  }

  // Update applicationId
  final appIdRegex = RegExp(r'applicationId\s*=\s*"' + RegExp.escape(oldAppId) + '"');
  if (appIdRegex.hasMatch(content)) {
    content = content.replaceFirst(appIdRegex, 'applicationId = "$newAppId"');
    changed = true;
  }

  if (changed) {
    file.writeAsStringSync(content);
    print('✅ [OK] android/app/build.gradle.kts');
    return 1;
  }

  print('⚠️  [SKIP] android/app/build.gradle.kts - tidak ada perubahan');
  return 0;
}

/// Update/Move MainActivity.kt
int _updateMainActivity(
  Directory projectDir,
  String oldAppId,
  String newAppId,
) {
  final kotlinBaseDir = Directory(
    '${projectDir.path}/android/app/src/main/kotlin',
  );

  if (!kotlinBaseDir.existsSync()) {
    print('⚠️  [SKIP] Kotlin directory tidak ditemukan');
    return 0;
  }

  // Convert app ID to path (e.g., id.ihasa.app -> id/ihasa/app)
  final oldPath = oldAppId.replaceAll('.', '/');
  final newPath = newAppId.replaceAll('.', '/');

  final oldMainActivityFile = File(
    '${kotlinBaseDir.path}/$oldPath/MainActivity.kt',
  );
  final newMainActivityDir = Directory('${kotlinBaseDir.path}/$newPath');
  final newMainActivityFile = File('${newMainActivityDir.path}/MainActivity.kt');

  // Create new directory
  if (!newMainActivityDir.existsSync()) {
    newMainActivityDir.createSync(recursive: true);
  }

  // Write new MainActivity.kt
  final mainActivityContent = '''package $newAppId

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
''';

  newMainActivityFile.writeAsStringSync(mainActivityContent);
  print('✅ [OK] android/app/src/main/kotlin/$newPath/MainActivity.kt (created)');

  // Delete old directory structure
  if (oldMainActivityFile.existsSync()) {
    // Find the root folder of the old package to delete
    final oldRootSegment = oldAppId.split('.').first;
    final newRootSegment = newAppId.split('.').first;

    // Only delete if root segments are different
    if (oldRootSegment != newRootSegment) {
      final oldRootDir = Directory('${kotlinBaseDir.path}/$oldRootSegment');
      if (oldRootDir.existsSync()) {
        try {
          oldRootDir.deleteSync(recursive: true);
          print('🗑️  [DEL] android/app/src/main/kotlin/$oldRootSegment/ (deleted)');
        } catch (e) {
          print('⚠️  [WARN] Gagal menghapus folder lama: $e');
        }
      }
    } else {
      // Same root, try to delete the specific old path
      try {
        // Navigate up to find empty directories to clean
        _cleanupEmptyDirs(kotlinBaseDir, oldPath, newPath);
      } catch (e) {
        print('⚠️  [WARN] Gagal membersihkan folder lama: $e');
      }
    }
  }

  return 1;
}

/// Clean up empty directories after moving files
void _cleanupEmptyDirs(Directory baseDir, String oldPath, String newPath) {
  final oldSegments = oldPath.split('/');
  final newSegments = newPath.split('/');

  // Find where paths diverge
  int commonDepth = 0;
  for (int i = 0; i < oldSegments.length && i < newSegments.length; i++) {
    if (oldSegments[i] == newSegments[i]) {
      commonDepth = i + 1;
    } else {
      break;
    }
  }

  // Delete from the deepest unique folder
  if (commonDepth < oldSegments.length) {
    final pathToDelete = oldSegments.sublist(0, commonDepth + 1).join('/');
    final dirToDelete = Directory('${baseDir.path}/$pathToDelete');
    if (dirToDelete.existsSync()) {
      dirToDelete.deleteSync(recursive: true);
      print('🗑️  [DEL] ${baseDir.path}/$pathToDelete/ (deleted)');
    }
  }
}

/// Update iOS project.pbxproj
int _updateIosProjectPbxproj(
  Directory projectDir,
  String oldAppId,
  String newAppId,
) {
  final file = File(
    '${projectDir.path}/ios/Runner.xcodeproj/project.pbxproj',
  );

  if (!file.existsSync()) {
    print('⚠️  [SKIP] ios/Runner.xcodeproj/project.pbxproj tidak ditemukan');
    return 0;
  }

  var content = file.readAsStringSync();
  var changed = false;

  // Convert old app ID to iOS bundle identifier pattern
  // Could be: id.carik.superapp_demo.superAppBoilerplate or just the app ID
  
  // Pattern 1: Full bundle ID with suffix (e.g., id.carik.superapp_demo.superAppBoilerplate)
  final oldBundleIdWithSuffix = RegExp(
    RegExp.escape(oldAppId) + r'\.[a-zA-Z]+',
  );
  
  // Find all matches to see what suffixes exist
  final matches = oldBundleIdWithSuffix.allMatches(content).toList();
  final suffixes = <String>{};
  for (final match in matches) {
    final fullMatch = match.group(0)!;
    final suffix = fullMatch.replaceFirst('$oldAppId.', '');
    suffixes.add(suffix);
  }

  // Replace bundle IDs with suffixes
  for (final suffix in suffixes) {
    final oldBundleId = '$oldAppId.$suffix';
    final newBundleId = '$newAppId.$suffix';
    if (content.contains(oldBundleId)) {
      content = content.replaceAll(oldBundleId, newBundleId);
      changed = true;
    }
  }

  // Also replace standalone app ID (without suffix)
  if (content.contains('PRODUCT_BUNDLE_IDENTIFIER = $oldAppId;')) {
    content = content.replaceAll(
      'PRODUCT_BUNDLE_IDENTIFIER = $oldAppId;',
      'PRODUCT_BUNDLE_IDENTIFIER = $newAppId;',
    );
    changed = true;
  }

  if (changed) {
    file.writeAsStringSync(content);
    print('✅ [OK] ios/Runner.xcodeproj/project.pbxproj');
    return 1;
  }

  print('⚠️  [SKIP] ios/Runner.xcodeproj/project.pbxproj - tidak ada perubahan');
  return 0;
}

/// Update documentation files
int _updateDocumentation(
  Directory projectDir,
  String oldAppId,
  String newAppId,
) {
  int changedCount = 0;

  final docFiles = [
    'README.md',
    'docs/SuperApp-Architecture.md',
    'docs/Notification.md',
    'docs/Auth.md',
    'docs/API.md',
  ];

  for (final docPath in docFiles) {
    final file = File('${projectDir.path}/$docPath');
    if (!file.existsSync()) continue;

    var content = file.readAsStringSync();
    if (content.contains(oldAppId)) {
      content = content.replaceAll(oldAppId, newAppId);
      file.writeAsStringSync(content);
      print('✅ [OK] $docPath');
      changedCount++;
    }
  }

  if (changedCount == 0) {
    print('ℹ️  [INFO] Tidak ada file dokumentasi yang perlu diubah');
  }

  return changedCount;
}
