// Build release tanpa kredensial demo di dalam bundle.
//
// `.env` di-bundle sebagai asset (lihat pubspec.yaml), jadi semua isinya ikut
// masuk ke APK/AAB dan bisa dibaca siapa pun yang membongkar file tersebut.
// Script ini menghapus sementara baris USERNAME_DEFAULT / PASSWORD_DEFAULT
// (termasuk yang di-comment) dari `.env`, menjalankan `flutter build`, lalu
// mengembalikan `.env` seperti semula, juga ketika build gagal.
//
// Jalankan:
//   dart run tool/build_release.dart appbundle --release
//   dart run tool/build_release.dart apk --release --target-platform=android-arm64

// ignore_for_file: avoid_print

import 'dart:io';

const _strippedKeys = ['USERNAME_DEFAULT', 'PASSWORD_DEFAULT'];

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run tool/build_release.dart <apk|appbundle|ipa> [flutter build args]');
    exit(64);
  }

  final projectDir = File(Platform.script.toFilePath()).parent.parent;
  final envFile = File('${projectDir.path}/.env');
  final backupFile = File('${projectDir.path}/.env.build-backup');

  if (backupFile.existsSync()) {
    print('❌ ${backupFile.path} masih ada dari build sebelumnya yang terputus.');
    print('   Periksa isinya, kembalikan ke .env bila perlu, lalu hapus file tersebut.');
    exit(1);
  }
  if (!envFile.existsSync()) {
    print('❌ File .env tidak ditemukan!');
    exit(1);
  }

  final original = envFile.readAsStringSync();
  final keyPattern = RegExp(r'^\s*#?\s*(' + _strippedKeys.join('|') + r')\s*=');
  final lines = original.split('\n');
  final kept = lines.where((line) => !keyPattern.hasMatch(line)).toList();
  final removed = lines.length - kept.length;

  envFile.copySync(backupFile.path);
  var exitCode = 1;
  try {
    envFile.writeAsStringSync(kept.join('\n'));
    print('🔒 $removed baris kredensial demo dihapus sementara dari .env');

    final process = await Process.start(
      'flutter',
      ['build', ...args],
      workingDirectory: projectDir.path,
      runInShell: true,
      mode: ProcessStartMode.inheritStdio,
    );
    exitCode = await process.exitCode;
  } finally {
    envFile.writeAsStringSync(original);
    backupFile.deleteSync();
    print('↩️  .env dikembalikan seperti semula');
  }
  exit(exitCode);
}
