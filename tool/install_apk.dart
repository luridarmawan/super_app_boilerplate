// Pasang APK release ke HP yang tersambung lewat adb, lalu jalankan aplikasinya.
//
// Dipakai oleh `make apk RUN=1` / `make apk-run` setelah APK selesai dibuild.
//
// Jalankan:
//   dart run tool/install_apk.dart              # satu HP tersambung
//   dart run tool/install_apk.dart -s <serial>  # pilih HP bila lebih dari satu
//
// adb dicari berurutan dari: ANDROID_HOME, ANDROID_SDK_ROOT, sdk.dir di
// android/local.properties, lalu PATH.

// ignore_for_file: avoid_print

import 'dart:io';

Future<void> main(List<String> args) async {
  final projectDir = File(Platform.script.toFilePath()).parent.parent;
  final apk = File('${projectDir.path}/build/app/outputs/flutter-apk/app-release.apk');
  if (!apk.existsSync()) {
    print('❌ ${apk.path} tidak ditemukan. Jalankan `make apk` dulu.');
    exit(1);
  }

  final adb = _findAdb(projectDir);
  final packageId = _readApplicationId(projectDir);

  final serial = _readSerial(args) ?? await _pickDevice(adb);
  final target = ['-s', serial];

  print('📲 Memasang ${apk.uri.pathSegments.last} ke $serial ...');
  final install = await Process.run(adb, [...target, 'install', '-r', apk.path]);
  stdout.write(install.stdout);
  stderr.write(install.stderr);
  if (install.exitCode != 0) {
    final output = '${install.stdout}${install.stderr}';
    if (output.contains('INSTALL_FAILED_UPDATE_INCOMPATIBLE')) {
      print('❌ Tanda tangan APK berbeda dengan aplikasi yang sudah terpasang');
      print('   (misalnya versi Play Store atau build debug). Hapus dulu dengan:');
      print('   "$adb" -s $serial uninstall $packageId');
    }
    exit(install.exitCode);
  }

  print('🚀 Menjalankan $packageId ...');
  final launch = await Process.run(adb, [
    ...target,
    'shell',
    'monkey',
    '-p',
    packageId,
    '-c',
    'android.intent.category.LAUNCHER',
    '1',
  ]);
  if (launch.exitCode != 0) {
    stderr.write(launch.stderr);
    print('❌ Gagal menjalankan aplikasi.');
    exit(launch.exitCode);
  }
  print('✅ Aplikasi terpasang dan berjalan di $serial');
}

String _findAdb(Directory projectDir) {
  final exe = Platform.isWindows ? 'adb.exe' : 'adb';
  final sdkDirs = <String>[
    ?Platform.environment['ANDROID_HOME'],
    ?Platform.environment['ANDROID_SDK_ROOT'],
    ?_readSdkDirFromLocalProperties(projectDir),
  ];
  for (final sdk in sdkDirs) {
    final candidate = File('$sdk/platform-tools/$exe');
    if (candidate.existsSync()) return candidate.path;
  }
  return 'adb'; // harapkan ada di PATH
}

String? _readSdkDirFromLocalProperties(Directory projectDir) {
  final file = File('${projectDir.path}/android/local.properties');
  if (!file.existsSync()) return null;
  for (final line in file.readAsLinesSync()) {
    final match = RegExp(r'^\s*sdk\.dir\s*=\s*(.+)$').firstMatch(line);
    if (match != null) {
      // local.properties meng-escape backslash dan titik dua: C\:\\Users\\...
      return match.group(1)!.trim().replaceAll(r'\\', r'\').replaceAll(r'\:', ':');
    }
  }
  return null;
}

String _readApplicationId(Directory projectDir) {
  for (final name in ['build.gradle.kts', 'build.gradle']) {
    final file = File('${projectDir.path}/android/app/$name');
    if (!file.existsSync()) continue;
    final match = RegExp(r'''applicationId\s*=?\s*["']([^"']+)["']''')
        .firstMatch(file.readAsStringSync());
    if (match != null) return match.group(1)!;
  }
  print('❌ applicationId tidak ditemukan di android/app/build.gradle(.kts)');
  exit(1);
}

String? _readSerial(List<String> args) {
  final i = args.indexOf('-s');
  if (i == -1) return null;
  if (i + 1 >= args.length) {
    print('❌ -s butuh serial perangkat.');
    exit(64);
  }
  return args[i + 1];
}

Future<String> _pickDevice(String adb) async {
  final ProcessResult result;
  try {
    result = await Process.run(adb, ['devices']);
  } on ProcessException {
    print('❌ adb tidak ditemukan. Pasang Android SDK platform-tools atau set ANDROID_HOME.');
    exit(1);
  }
  final devices = (result.stdout as String)
      .split('\n')
      .skip(1)
      .map((line) => line.trim().split(RegExp(r'\s+')))
      .where((cols) => cols.length >= 2)
      .toList();

  final ready = devices.where((cols) => cols[1] == 'device').map((cols) => cols[0]).toList();
  final unauthorized = devices.where((cols) => cols[1] == 'unauthorized').map((cols) => cols[0]);

  if (ready.length == 1) return ready.single;
  if (ready.isEmpty) {
    print('❌ Tidak ada HP yang tersambung.');
    if (unauthorized.isNotEmpty) {
      print('   ${unauthorized.join(', ')} belum diizinkan: buka HP dan setujui dialog "Allow USB debugging".');
    } else {
      print('   Sambungkan HP lewat USB dan aktifkan USB debugging.');
    }
    exit(1);
  }
  print('❌ Ada ${ready.length} perangkat tersambung: ${ready.join(', ')}');
  print('   Pilih salah satu: make apk RUN=1 DEVICE=<serial>');
  exit(1);
}
