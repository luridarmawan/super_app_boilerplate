# Panduan External Module

Dokumentasi ini menjelaskan cara mengelola modul eksternal **tanpa menggunakan git submodule**, sehingga tidak ada perubahan di `.gitmodules` pada repository utama.

---

## Konsep Dasar

Strategi ini menggunakan **git clone biasa** (bukan submodule) untuk modul eksternal. Konfigurasi modul disimpan dalam file `modules.yaml` yang **tidak di-track** oleh git, sehingga:

1. **Repo utama tetap bersih** - tidak ada perubahan di `.gitmodules`
2. **Fleksibel** - setiap developer bisa punya konfigurasi modul berbeda
3. **Opsional** - modul tidak wajib ada untuk build dasar
4. **CI/CD friendly** - pipeline bisa memilih modul mana yang diperlukan

### Arsitektur

```
super_app_boilerplate/
├── .gitignore              # ← modules/ & modules.yaml diabaikan
├── modules/                # ← TIDAK di-track (gitignored)
│   ├── sales_module/       # ← Clone dari repo eksternal
│   └── inventory_module/   # ← Clone dari repo eksternal
├── modules.yaml            # ← Manifest lokal (TIDAK di-track)
├── modules.yaml.example    # ← Template (DI-TRACK)
└── tool/
    └── manage_external_modules.dart
```

### Aturan Penting Modul Eksternal

1. **Hanya bergantung pada `module_interface`**: Modul tidak boleh mengimport file dari `package:super_app/...`.
2. **Gunakan Abstraksi**: Jika modul butuh konfigurasi (misal API URL), definisikan interface di modul dan biarkan App utama menginject implementasinya.
3. **Self-Contained**: Modul harus memiliki `pubspec.yaml` sendiri dan bisa di-analyze secara independen.

---

## Quick Start

### 1. Setup Pertama Kali

```bash
# Copy template manifest
copy modules.yaml.example modules.yaml

# Edit modules.yaml dengan text editor (tambahkan modul yang diperlukan)

# Clone semua modul
dart run tool/manage_external_modules.dart
```

### 2. Update Modul

```bash
# Pull perubahan terbaru dari semua modul
dart run tool/manage_external_modules.dart --pull
```

### 3. Cek Status

```bash
# Lihat status semua modul
dart run tool/manage_external_modules.dart --status
```

---

## Konfigurasi modules.yaml

### Format

```yaml
modules:
  # Modul dengan SSH URL
  - name: sales_module
    url: git@github.com:company/sales-module.git
    branch: development
    enabled: true

  # Modul dengan HTTPS URL
  - name: inventory_module
    url: https://github.com/company/inventory-module.git
    branch: main
    enabled: true

  # Modul yang dinonaktifkan (tidak akan di-clone)
  - name: reporting_module
    url: git@github.com:company/reporting-module.git
    branch: main
    enabled: false
```

### Field

| Field | Wajib | Default | Keterangan |
|-------|-------|---------|------------|
| `name` | ✅ | - | Nama folder modul (harus valid package name) |
| `url` | ✅ | - | URL repository (SSH atau HTTPS) |
| `branch` | ❌ | `main` | Branch yang akan di-clone |
| `enabled` | ❌ | `true` | Set `false` untuk skip modul ini |

---

## Command Reference

```bash
# Clone modul yang belum ada
dart run tool/manage_external_modules.dart

# Update semua modul dari remote
dart run tool/manage_external_modules.dart --pull

# Tampilkan status semua modul
dart run tool/manage_external_modules.dart --status

# Hapus modul (dengan konfirmasi)
dart run tool/manage_external_modules.dart --clean

# Tampilkan bantuan
dart run tool/manage_external_modules.dart --help
```

---

## Persiapan Repository Modul

Sebelum menambahkan modul eksternal, pastikan repository modul memiliki struktur berikut:

### `pubspec.yaml` (Modul)

```yaml
name: nama_modul
description: Deskripsi modul
version: 1.0.0

environment:
  sdk: ^3.0.0

dependencies:
  flutter:
    sdk: flutter
  # WAJIB: Bergantung ke interface, bukan ke app utama
  module_interface:
    path: ../../packages/module_interface
```

### `lib/nama_modul_module.dart`

```dart
import 'package:flutter/material.dart';
import 'package:module_interface/module_interface.dart';

class NamaModulModule extends BaseModule {
  @override
  String get name => 'nama_modul';
  
  @override
  String get version => '1.0.0';

  @override
  String get description => 'Deskripsi modul';

  @override
  Future<void> initialize() async {
    debugPrint('NamaModulModule: Initialized');
  }
}
```

---

## Workflow Pengembangan

### Mengerjakan Modul Eksternal

```bash
# 1. Masuk ke folder modul
cd modules/nama_modul

# 2. Lakukan perubahan, commit, dan push
git add .
git commit -m "feat: add new feature"
git push origin development

# 3. Kembali ke root project
cd ../..
```

### Menambahkan Developer Baru

```bash
# 1. Clone repo utama
git clone https://github.com/company/super_app_boilerplate.git
cd super_app_boilerplate

# 2. Copy dan edit manifest
copy modules.yaml.example modules.yaml
# Edit modules.yaml sesuai kebutuhan

# 3. Clone modul-modul
dart run tool/manage_external_modules.dart

# 4. Install dependencies
flutter pub get
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      # Setup modules.yaml dari secrets atau environment
      - name: Setup External Modules
        run: |
          cat << EOF > modules.yaml
          modules:
            - name: sales_module
              url: ${{ secrets.SALES_MODULE_URL }}
              branch: main
              enabled: true
          EOF
      
      # Clone modul
      - name: Sync External Modules
        run: dart run tool/manage_external_modules.dart
      
      - name: Build
        run: flutter build apk
```

---

## Troubleshooting

### Error: "modules.yaml tidak ditemukan"

```bash
# Copy template
copy modules.yaml.example modules.yaml
```

### Error: "module_interface not found"

Pastikan path di `pubspec.yaml` milik modul sudah benar:
```yaml
module_interface:
  path: ../../packages/module_interface
```

### SSH Authentication Failed

Jika menggunakan URL SSH, pastikan:
1. SSH key sudah di-generate: `ssh-keygen -t ed25519`
2. Public key sudah ditambahkan ke GitHub/GitLab
3. SSH agent berjalan: `eval "$(ssh-agent -s)" && ssh-add`

---

## Perbandingan dengan Git Submodule

| Aspek | Strategi Ini | Git Submodule |
|-------|--------------|---------------|
| Perubahan di repo utama | ❌ Tidak ada | ✅ Ada (.gitmodules) |
| Fleksibilitas per-developer | ✅ Tinggi | ❌ Rendah |
| Kompleksitas | ⚡ Rendah | 🔧 Sedang |
| Clone | `git clone` + script | `git clone --recursive` |
| Tracking versi | Manual di manifest | Otomatis via pointer |
