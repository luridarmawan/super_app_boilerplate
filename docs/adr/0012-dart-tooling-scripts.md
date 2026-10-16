# ADR 0012 — Otomasi proyek sebagai script Dart di `tool/`, bukan shell script

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `tool/`, `Makefile`

## Konteks

Beberapa tugas berulang di proyek ini tidak bisa dikerjakan tangan tanpa risiko: menaikkan build number sebelum rilis, mengganti application ID di berkas Android/iOS, membuat kerangka modul baru, meng-clone modul eksternal, dan meregenerasi manifest modul.

Tim bekerja di Windows dan Unix. Shell script akan butuh dua versi (`.sh` dan `.bat`), dan pekerjaan seperti mem-parsing `pubspec.yaml` atau memindai kelas `extends BaseModule` di seluruh pohon sumber jelas di luar wilayah nyaman shell.

## Keputusan

Semua otomasi ditulis sebagai program Dart mandiri di `tool/`, dijalankan dengan `dart run tool/<nama>.dart`:

| Script | Fungsi |
|--------|--------|
| `add_version.dart` | Menaikkan build number di `pubspec.yaml` sebelum build rilis |
| `change_app_id.dart` | Mengganti application ID di seluruh berkas Android/iOS |
| `generate_module.dart` / `generate_module_internal.dart` | Membuat kerangka modul baru (interaktif) |
| `manage_external_modules.dart` | Clone/pull/status/clean modul dari `modules.yaml` |
| `sync_modules.dart` | Memindai `lib/modules/**/*_module.dart` dan **meregenerasi** `lib/modules/all_modules.dart` |
| `generate_launcher_icons.dart` | Membungkus `flutter_launcher_icons` |
| `generate_release_keystore.dart` | Membuat keystore rilis |

`Makefile` hanya menjadi pembungkus tipis untuk urutan yang sering dipakai — misalnya `make build` = `flutter clean` → `flutter pub get` → `dart run tool/add_version.dart` → `flutter build appbundle --release`.

**Registrasi modul adalah kode hasil generate.** `sync_modules.dart` mencari pola `class <X> extends BaseModule` dengan regex, lalu menulis ulang `all_modules.dart` beserta header `/// Auto-generated file. Do not edit manually.`

## Konsekuensi

**Positif**
- Satu implementasi berjalan di Windows, macOS, dan Linux — tidak ada `.sh` + `.bat` kembar.
- Script memakai toolchain yang sudah pasti terpasang (Dart SDK) dan pustaka Dart (`package:yaml`) untuk mem-parsing berkas proyek dengan benar, bukan `sed`.
- Menambah modul tidak menuntut suntingan manual: jalankan `sync_modules.dart`.

**Negatif / biaya**
- `all_modules.dart` di-track Git tetapi hasil generate. Suntingan manual akan hilang pada sinkronisasi berikutnya, dan berkas ini rawan konflik merge.
- `sync_modules.dart` mendeteksi modul lewat **regex atas teks sumber**. Kelas modul yang ditulis dengan formatting tidak lazim (misalnya `extends` di baris berikutnya) tidak akan terdeteksi, tanpa peringatan.
- Script hanya memindai `lib/modules/`; modul eksternal di `modules/` tetap perlu di-import manual — terlihat pada `all_modules.dart` saat ini yang meng-import `package:arrow_sense/arrow_sense_module.dart` sementara registrasi lainnya berupa path relatif.
- Otomasi ini tidak dijalankan CI; disiplinnya bergantung pada developer menjalankan `make build` alih-alih `flutter build` langsung. Build number yang tidak naik akan ditolak store — dan pengecekan versi Remote Config ikut meleset (lihat [ADR 0011](0011-remote-config-kill-switch.md)).

## Alternatif yang ditolak

- **Shell/batch script** — ditolak: dua versi untuk dua platform, dan parsing YAML/Dart di shell terlalu rapuh.
- **melos atau `build_runner` untuk semuanya** — ditolak: `build_runner` sudah dipakai untuk Retrofit/JSON, tetapi tugas seperti clone repo dan menaikkan versi bukan transformasi sumber sehingga tidak cocok masuk pipeline generator.

## Referensi

- [`docs/Development-and-Build.md`](../Development-and-Build.md)
- [`docs/Change-Application-Id.md`](../Change-Application-Id.md)
- [`docs/Release.md`](../Release.md)
