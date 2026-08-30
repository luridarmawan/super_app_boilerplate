# ADR 0002 — Sistem modul plugin lewat `ModuleRegistry`

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `lib/modules/module_registry.dart`, `lib/modules/all_modules.dart`, `lib/main.dart`

## Konteks

Super app OSA harus bisa menambah/mengurangi area fungsional (Arrow Sense, News, dan modul lain di masa depan) tanpa mengubah `main.dart`, router, atau dashboard satu per satu. Kalau setiap modul harus mendaftarkan route-nya sendiri di `app_router.dart` dan menaruh kartunya sendiri di `main_dashboard.dart`, setiap penambahan modul menyentuh berkas milik shell — sumber konflik merge dan penghalang bagi repo modul terpisah.

## Keputusan

Modul mengimplementasikan `BaseModule` dan mendaftar ke satu registry statis (`ModuleRegistry`) sebelum `runApp()`. Registry-lah yang **mengagregasi** kontribusi modul, bukan shell yang memungut satu per satu:

- `ModuleRegistry.allRoutes` → di-*merge* ke GoRouter
- `ModuleRegistry.dashboardWidgets` / `dashboardConfigs` → slot dashboard, diurutkan `order`
- `ModuleRegistry.menuItems` → sidebar / workspace icon, dipisah `publicMenuItems` vs `protectedMenuItems`
- `ModuleRegistry.allQuickActions` → quick action (statis + modul)
- `ModuleRegistry.allProviderOverrides` → override Riverpod milik modul

Alur hidup modul dikendalikan registry:

1. `ModuleManifest.register()` — daftar modul (berkas hasil generate, lihat ADR 0012)
2. `ModuleRegistry.initializeAll()` — `validate()` lalu `initialize()` untuk modul **aktif** saja, dalam urutan hasil *topological sort* atas `module.dependencies`
3. `notifyUserLogin()` / `notifyUserLogout()` — siaran event sesi ke semua modul aktif
4. `disposeAll()` — dispose terbalik dari urutan inisialisasi

Keaktifan modul ditentukan feature flag `.env` (lihat [ADR 0005](0005-env-feature-flags.md)); `activeModules` menyaring berdasarkan `isModuleEnabled(name)`.

## Konsekuensi

**Positif**
- Menambah modul = menulis satu kelas `BaseModule` + satu flag `.env`. Shell tidak berubah.
- Kegagalan satu modul tidak menjatuhkan aplikasi: `initialize()` dibungkus `try/catch` per modul dan hanya menulis log.
- Dependensi antar-modul terselesaikan otomatis, dan siklus terdeteksi (diberi peringatan, bukan crash).

**Negatif / biaya**
- `ModuleRegistry` adalah **state statis global**. Konsekuensinya: urutan pendaftaran penting, registry harus di-`clear()` manual di test, dan `moduleRegistryProvider` hanyalah pembungkus tipis — provider Riverpod di sini tidak memberi isolasi apa pun.
- Modul yang gagal `validate()` tetap ikut di-`initialize()` (loop validasi hanya `continue`, tidak membuang modul dari daftar). Validasi saat ini efektif hanya sebagai peringatan log.
- Agregasi bersifat *eager*: seluruh route dan widget modul aktif dibangun saat startup, tidak ada lazy-loading per modul.

## Alternatif yang ditolak

- **Registrasi manual di `app_router.dart` + `main_dashboard.dart`** — ditolak: setiap modul menyentuh berkas shell.
- **Dependency injection container penuh (get_it / injectable)** — ditolak karena aplikasi sudah memakai Riverpod untuk state; menambah container kedua berarti dua sumber kebenaran.

## Referensi

- [`docs/Modular.md`](../Modular.md)
- [ADR 0003 — kontrak `module_interface`](0003-module-interface-contract.md)
