// Dart script untuk increment build number di pubspec.yaml
// Jalankan: dart run tool/add_version.dart

// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final pubspecFile = File('${scriptDir.parent.path}/pubspec.yaml');

  // Cek apakah file ada
  if (!pubspecFile.existsSync()) {
    print('❌ Error: File pubspec.yaml tidak ditemukan!');
    exit(1);
  }

  // Baca isi file
  final content = pubspecFile.readAsStringSync();

  // Regex untuk mencari versi: version: X.Y.Z+N
  final versionRegex = RegExp(r'version:\s*(\d+\.\d+\.\d+)\+(\d+)');
  final match = versionRegex.firstMatch(content);

  if (match != null) {
    final versionName = match.group(1)!;
    final buildNumber = int.parse(match.group(2)!);
    final newBuildNumber = buildNumber + 1;

    final oldVersion = '$versionName+$buildNumber';
    final newVersion = '$versionName+$newBuildNumber';

    // Ganti versi di content
    final newContent = content.replaceFirst(
      'version: $oldVersion',
      'version: $newVersion',
    );

    // Tulis kembali ke file (mempertahankan line endings)
    pubspecFile.writeAsStringSync(newContent);

    print('');
    print('========================================');
    print('  🔼 Version bumped: $oldVersion → $newVersion');
    print('========================================');
    print('');
  } else {
    // Coba cari versi tanpa build number
    final simpleVersionRegex = RegExp(r'version:\s*(\d+\.\d+\.\d+)');
    final simpleMatch = simpleVersionRegex.firstMatch(content);

    if (simpleMatch != null) {
      final versionName = simpleMatch.group(1)!;
      final oldVersion = versionName;
      final newVersion = '$versionName+1';

      final newContent = content.replaceFirst(
        'version: $oldVersion',
        'version: $newVersion',
      );

      pubspecFile.writeAsStringSync(newContent);

      print('');
      print('========================================');
      print('  🔼 Version bumped: $oldVersion → $newVersion');
      print('========================================');
      print('');
    } else {
      print('❌ Error: Tidak dapat menemukan versi di pubspec.yaml');
      exit(1);
    }
  }
}
