# Panduan Git Submodule untuk Modul

Dokumentasi ini menjelaskan cara menerapkan Git Submodule untuk memisahkan repository modul dari repository aplikasi utama. Strategi ini memungkinkan tim yang berbeda untuk mengerjakan modul yang berbeda secara independen.

---

## Konsep Dasar

Dalam arsitektur ini, modul eksternal diperlakukan sebagai **Local Package Flutter** yang berada di dalam folder `modules/`. Untuk menghindari ketergantungan melingkar (*circular dependency*), semua kontrak dasar (seperti `BaseModule`) dipisahkan ke dalam package `packages/module_interface`.

### Aturan Penting Modul Eksternal
1.  **Hanya bergantung pada `module_interface`**: Modul tidak boleh mengimport file dari `package:super_app/...`.
2.  **Gunakan Abstraksi**: Jika modul butuh konfigurasi (misal API URL), definisikan interface di modul dan biarkan App utama menginject implementasinya.
3.  **Self-Contained**: Modul harus memiliki `pubspec.yaml` sendiri dan bisa dijalankan (minimal di-analyze) secara independen.

---

## Cara Menambahkan Modul Baru (Submodule)

Kami telah menyediakan tool CLI untuk memudahkan proses ini.

### 1. Menggunakan CLI Tool (Rekomendasi)

Jalankan perintah berikut di root project:

```bash
# Menggunakan HTTPS
dart run tool/add_submodule.dart https://github.com/username/repo-name.git

# Menggunakan SSH (Pastikan SSH Key sudah terkonfigurasi)
dart run tool/add_submodule.dart git@github.com:username/repo-name.git
```

**Apa yang dilakukan tool ini secara otomatis?**
1.  Menjalankan `git submodule add` ke dalam direktori `modules/`.
2.  Mengkonversi nama repo (misal `artificial-intelligence`) menjadi nama package yang valid (`artificial_intelligence`).
3.  Mendaftarkan module path di `pubspec.yaml` utama.
4.  Menambahkan import dan registrasi di `lib/modules/all_modules.dart`.
5.  Menjalankan `flutter pub get`.

### 2. Persiapan di Repository Modul

Sebelum menambahkan submodule, pastikan repository modul Anda memiliki struktur berikut:

**`pubspec.yaml` (Modul):**
```yaml
name: artificial_intelligence
dependencies:
  flutter:
    sdk: flutter
  # WAJIB: Bergantung ke interface, bukan ke app utama
  module_interface:
    path: ../../packages/module_interface
```

**`lib/artificial_intelligence_module.dart`:**
```dart
import 'package:module_interface/module_interface.dart';

class artificialIntelligenceModule extends BaseModule {
  @override
  String get name => 'artificial_intelligence';
  
  @override
  String get version => '1.0.0';

  // ... implementasi lainnya ...
}
```

---

## Workflow Pengembangan

### Mengambil Perubahan Terbaru
Jika ada rekan tim lain yang mengupdate submodule, Anda perlu menarik perubahannya:
```bash
git submodule update --remote --merge
```

### Melakukan Commit di Submodule
Jika Anda mengubah kode di dalam folder `modules/nama_modul`:
1.  Masuk ke folder modul tersebut.
2.  Lakukan commit dan push di direktori tersebut.
3.  Kembali ke root project, lalu commit perubahan "pointer" submodule di project utama.

---

## Troubleshooting

### Error: "module_interface not found"
Pastikan path di `pubspec.yaml` milik modul sudah benar. Karena folder modul berada di `modules/nama_modul`, maka path ke interface biasanya adalah `../../packages/module_interface`.

### SSH Authentication Failed
Jika menggunakan URL SSH, pastikan `ssh-agent` Anda berjalan dan key Anda sudah ditambahkan (`ssh-add`).
