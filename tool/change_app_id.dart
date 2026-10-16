// Dart script untuk mengubah Application ID di seluruh project
// Jalankan: dart run tool/change_app_id.dart <new_app_id>
// Contoh: dart run tool/change_app_id.dart com.company.project

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

  // Kandidat ID lama. Normalnya hanya satu (dari build.gradle.kts), tetapi
  // kalau project sempat diubah manual dan tidak sinkron (misalnya gradle
  // sudah ID baru sementara MainActivity.kt dan iOS masih ID lama), kita
  // kumpulkan juga dari package MainActivity.kt yang ada supaya iOS dan
  // dokumentasi tetap ikut terganti.
  final oldAppIds = <String>{currentAppId}
    ..addAll(_detectMainActivityPackages(projectDir))
    ..remove(newAppId);
  if (oldAppIds.length > 1) {
    print('ℹ️  Terdeteksi beberapa ID lama yang tidak sinkron: '
        '${oldAppIds.join(', ')}');
  }

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
  changedFiles += _updateIosProjectPbxproj(projectDir, oldAppIds, newAppId);

  // 4. Update documentation files
  changedFiles += _updateDocumentation(projectDir, oldAppIds, newAppId);

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

  // Update namespace. Cocokkan nilai apa pun (bukan hanya oldAppId) agar
  // namespace yang sempat tidak sinkron dengan applicationId ikut dibetulkan.
  final namespaceRegex = RegExp(r'namespace\s*=\s*"([^"]+)"');
  final namespaceMatch = namespaceRegex.firstMatch(content);
  if (namespaceMatch != null && namespaceMatch.group(1) != newAppId) {
    if (namespaceMatch.group(1) != oldAppId) {
      print(
        'ℹ️  namespace sebelumnya "${namespaceMatch.group(1)}" '
        'tidak sama dengan applicationId "$oldAppId" — disamakan.',
      );
    }
    content = content.replaceFirst(namespaceRegex, 'namespace = "$newAppId"');
    changed = true;
  }

  // Update applicationId
  final appIdRegex = RegExp('applicationId\\s*=\\s*"${RegExp.escape(oldAppId)}"');
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

  // Convert app ID to path (e.g., com.company.project -> com/company/project)
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

  // Hapus SEMUA MainActivity.kt lain di luar package baru, bukan hanya yang
  // ada di path oldAppId. Ini menangani kondisi tidak sinkron, misalnya
  // applicationId sudah diganti manual tetapi MainActivity.kt masih tertinggal
  // di package lama (manifest memakai ".MainActivity" relatif ke namespace,
  // sehingga file yang tertinggal itu tidak dipakai dan hanya membingungkan).
  if (!oldMainActivityFile.existsSync()) {
    print(
      'ℹ️  MainActivity.kt tidak ditemukan di package "$oldAppId"; '
      'mencari sisa MainActivity.kt di package lain.',
    );
  }
  final newAbs = _normalize(newMainActivityFile.absolute.path);
  final staleFiles = _findMainActivityFiles(kotlinBaseDir)
      .where((f) => _normalize(f.absolute.path) != newAbs)
      .toList();
  for (final stale in staleFiles) {
    try {
      stale.deleteSync();
      final rel = stale.path
          .substring(kotlinBaseDir.path.length + 1)
          .replaceAll('\\', '/');
      print('🗑️  [DEL] android/app/src/main/kotlin/$rel (deleted)');
      _pruneEmptyDirs(stale.parent, kotlinBaseDir);
    } catch (e) {
      print('⚠️  [WARN] Gagal menghapus ${stale.path}: $e');
    }
  }

  return 1;
}

/// Samakan pemisah path (Windows memakai `\`, Dart kadang `/`).
String _normalize(String path) => path.replaceAll('\\', '/');

/// Semua MainActivity.kt di bawah [kotlinBaseDir], apa pun package-nya.
List<File> _findMainActivityFiles(Directory kotlinBaseDir) {
  if (!kotlinBaseDir.existsSync()) return const [];
  return kotlinBaseDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => _normalize(f.path).endsWith('/MainActivity.kt'))
      .toList();
}

/// Nama package yang dideklarasikan di setiap MainActivity.kt yang ada.
Set<String> _detectMainActivityPackages(Directory projectDir) {
  final kotlinBaseDir = Directory(
    '${projectDir.path}/android/app/src/main/kotlin',
  );
  final packageRegex = RegExp(r'^\s*package\s+([A-Za-z0-9_.]+)', multiLine: true);
  final result = <String>{};
  for (final f in _findMainActivityFiles(kotlinBaseDir)) {
    final match = packageRegex.firstMatch(f.readAsStringSync());
    if (match != null) result.add(match.group(1)!);
  }
  return result;
}

/// Semua nilai PRODUCT_BUNDLE_IDENTIFIER di project.pbxproj.
Set<String> _readIosBundleIds(String pbxprojContent) {
  final regex = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*"?([^";]+)"?\s*;');
  return regex
      .allMatches(pbxprojContent)
      .map((m) => m.group(1)!.trim())
      .toSet();
}

/// Hapus direktori kosong dari [dir] naik ke atas sampai (tidak termasuk) [stopAt].
void _pruneEmptyDirs(Directory dir, Directory stopAt) {
  var current = dir;
  final stopPath = _normalize(stopAt.absolute.path);
  while (_normalize(current.absolute.path) != stopPath &&
      _normalize(current.absolute.path).startsWith(stopPath) &&
      current.existsSync() &&
      current.listSync().isEmpty) {
    current.deleteSync();
    current = current.parent;
  }
}

/// Update iOS project.pbxproj
int _updateIosProjectPbxproj(
  Directory projectDir,
  Set<String> oldAppIds,
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

  // Bundle ID iOS bisa berupa app ID apa adanya, atau app ID + suffix
  // (mis. id.carik.superapp_demo.superAppBoilerplate dan ...RunnerTests).
  // Ganti prefiks app ID-nya saja, suffix dipertahankan.
  final bundleIds = _readIosBundleIds(content);
  for (final oldAppId in oldAppIds) {
    for (final bundleId in bundleIds) {
      if (bundleId == oldAppId || bundleId.startsWith('$oldAppId.')) {
        final newBundleId = newAppId + bundleId.substring(oldAppId.length);
        content = content.replaceAll(
          RegExp('PRODUCT_BUNDLE_IDENTIFIER\\s*=\\s*"?${RegExp.escape(bundleId)}"?\\s*;'),
          'PRODUCT_BUNDLE_IDENTIFIER = $newBundleId;',
        );
        changed = true;
      }
    }
  }

  if (!changed) {
    final remaining = bundleIds.where((b) => !b.startsWith('$newAppId.') && b != newAppId);
    if (remaining.isNotEmpty) {
      print('⚠️  [WARN] Bundle ID iOS tidak cocok dengan ID lama mana pun, '
          'periksa manual: ${remaining.join(', ')}');
    }
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
  Set<String> oldAppIds,
  String newAppId,
) {
  int changedCount = 0;

  final docFiles = [
    'README.md',
    'docs/SuperApp-Architecture.md',
    'docs/Notification.md',
    'docs/Auth.md',
    'docs/API.md',
    'docs/Keystore.md',
  ];

  for (final docPath in docFiles) {
    final file = File('${projectDir.path}/$docPath');
    if (!file.existsSync()) continue;

    var content = file.readAsStringSync();
    var changed = false;
    for (final oldAppId in oldAppIds) {
      // Batasi pada token utuh agar "id.carik.superapp_demo" tidak ikut
      // mengganti bagian dari ID lain yang kebetulan berawalan sama.
      final regex = RegExp('(?<![A-Za-z0-9_.])${RegExp.escape(oldAppId)}(?![A-Za-z0-9_])');
      if (regex.hasMatch(content)) {
        content = content.replaceAll(regex, newAppId);
        changed = true;
      }
    }
    if (changed) {
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
