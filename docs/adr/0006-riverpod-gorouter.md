# ADR 0006 — Riverpod untuk state, GoRouter untuk navigasi

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `lib/core/config/app_config.dart`, `lib/core/routes/app_router.dart`, `lib/main.dart`

## Konteks

Aplikasi butuh state global lintas layar (user login, tema, locale, posisi sidebar, konektivitas) dan navigasi berbasis URL yang bisa **dikontribusikan oleh modul** — karena `BaseModule.routes` mengembalikan daftar route yang di-merge ke router aplikasi (lihat [ADR 0002](0002-plugin-module-registry.md)).

Navigator 1.0 (`Navigator.push`) tidak memungkinkan modul menyumbang route secara deklaratif; route harus didaftarkan di satu tempat sebagai data.

## Keputusan

- **Riverpod (`flutter_riverpod`)** sebagai satu-satunya container state/DI. Seluruh aplikasi dibungkus `ProviderScope` di `main.dart`. Provider inti terpusat di `lib/core/config/app_config.dart`: `appConfigProvider` (StateNotifier, dipersist ke SharedPreferences), `authServiceProvider`, `authStateNotifierProvider`, `currentUserProvider`, `isLoggedInProvider`, `themeProvider`, `localeProvider`, `sidebarPositionProvider`.
- **GoRouter** sebagai router. `routerProvider` membangun `GoRouter` sekali, menggabungkan route shell dengan `ModuleRegistry.allRoutes`, menentukan `initialLocation` secara dinamis (splash vs campaign home), dan memasang `redirect` untuk penjagaan rute.
- Modul menyumbang state lewat `BaseModule.providerOverrides` (`List<Override>`) yang dikumpulkan registry.

## Konsekuensi

**Positif**
- Route berbentuk data (`List<RouteBase>`), sehingga modul dapat menyumbangkannya tanpa menyentuh berkas router.
- Deep link dan navigasi berbasis path bekerja apa adanya — dipakai oleh quick action dan auto-logout (`redirectToLogin` cukup memanggil `context.go('/login')`).
- Satu mekanisme untuk state dan injeksi dependensi; tidak ada container kedua.

**Negatif / biaya**
- Kontrak `module_interface` ikut mengunci kedua pustaka ini: `RouteBase` dan `Override` muncul di permukaan `BaseModule`, jadi mengganti router atau state management adalah perubahan yang merusak seluruh modul (lihat [ADR 0003](0003-module-interface-contract.md)).
- Versi mayor GoRouter (`^17.x`) harus dijaga sinkron antara `super_app`, `module_interface`, dan `arrow_sense`; ketiganya mendeklarasikan constraint sendiri-sendiri.
- `routerProvider` membangun router dari `ModuleRegistry.allRoutes` yang bersifat statis — route hasil modul tidak reaktif terhadap perubahan flag saat runtime; mengubah flag butuh restart aplikasi.
- Route yang tidak terdaftar hanya ketahuan saat runtime. Contoh terbuka yang tercatat: quick action **Match** dan **Session** milik `arrow_sense` menunjuk `/arrow_sense` yang belum didaftarkan.

## Alternatif yang ditolak

- **Provider / BLoC** — ditolak: Riverpod dipilih karena tidak butuh `BuildContext` untuk membaca state, penting bagi kode modul dan service yang berjalan di luar widget tree.
- **Navigator 1.0 / `onGenerateRoute`** — ditolak: modul tidak bisa menyumbang route secara deklaratif.
