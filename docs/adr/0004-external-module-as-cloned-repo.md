# ADR 0004 — Modul eksternal di-*clone* lewat manifest, bukan git submodule

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `tool/manage_external_modules.dart`, `tool/sync_modules.dart`, `modules.yaml`, `.gitignore`

## Konteks

`arrow_sense` — modul yang memuat seluruh fitur panahan OSA — dikembangkan di repo Git tersendiri (`git@github.com:ihasa-id/archery_intelligence.git`, branch `development`), tetapi harus hadir di `modules/arrow_sense` agar bisa dijadikan path dependency oleh `pubspec.yaml`.

Mekanisme baku Git untuk ini adalah *submodule*. Masalahnya, `.gitmodules` adalah berkas milik repo induk: setiap developer yang menambah/mengganti modul untuk kebutuhannya sendiri akan mengubah berkas yang ter-*track*, dan boilerplate ini memang dirancang agar tiap turunan produk memakai kombinasi modul yang berbeda.

## Keputusan

Modul eksternal dideklarasikan di **`modules.yaml`** — berkas yang **tidak** di-track Git (templatnya `modules.yaml.example`) — lalu di-materialisasi oleh CLI Dart:

```bash
dart run tool/manage_external_modules.dart            # clone modul yang belum ada
dart run tool/manage_external_modules.dart --pull     # update semua modul
dart run tool/manage_external_modules.dart --status    # cek status
dart run tool/manage_external_modules.dart --clean     # hapus semua modul
dart run tool/sync_modules.dart                        # regenerate lib/modules/all_modules.dart
```

Alasan eksplisit dicatat di header `tool/manage_external_modules.dart`: *"This strategy avoids using git submodule to prevent changes to the .gitmodules file in the main repository."*

Setiap entri manifest berisi `name`, `url`, `branch`, dan `enabled`; modul dengan `enabled: false` tidak di-clone sama sekali.

### Catatan khusus repo OSA

`.gitignore` boilerplate menyediakan baris `modules/` untuk mengabaikan seluruh folder modul, tetapi di repo OSA baris itu **sengaja dikomentari**. Akibatnya 75 berkas `modules/arrow_sense/` ikut di-commit ke repo ini. Jadi di OSA `arrow_sense` bersifat *vendored*: repo asalnya tetap `archery_intelligence`, tetapi salinan kerjanya ada di dalam repo aplikasi sehingga build CI dan checkout bersih tidak memerlukan akses SSH ke repo modul.

## Konsekuensi

**Positif**
- Tidak ada `.gitmodules`; komposisi modul adalah keputusan lokal tiap developer/produk.
- `clone` + `flutter run` bekerja tanpa langkah `git submodule update --init`.
- Karena `modules/arrow_sense` di-commit di OSA, build tidak bergantung pada kredensial repo modul.

**Negatif / biaya**
- **Tidak ada penguncian revisi.** Submodule menyimpan commit SHA; manifest hanya menyimpan nama branch. Dua developer yang menjalankan `--pull` di hari berbeda bisa mendapat kode modul yang berbeda tanpa jejak di repo induk.
- Karena di OSA modul juga di-commit, ada **dua jalur perubahan** untuk berkas yang sama: edit langsung di `modules/arrow_sense` lalu commit ke repo induk, atau `--pull` dari repo modul. Keduanya bisa saling menimpa; kesepakatan kerjanya harus dijaga manual.
- `modules.yaml` tidak di-track, sehingga setup developer baru selalu butuh langkah salin manual dari `.example`.

## Alternatif yang ditolak

- **Git submodule** — ditolak: mengubah `.gitmodules` milik repo induk untuk setiap kombinasi modul (alasan tercatat di kode).
- **Publikasi modul sebagai paket pub (hosted/git dependency)** — ditolak untuk saat ini: modul dan aplikasi masih berubah beriringan, siklus rilis paket akan memperlambat iterasi.

## Referensi

- [`docs/SubModule.md`](../SubModule.md)
- [ADR 0012 — otomasi lewat script Dart](0012-dart-tooling-scripts.md)
