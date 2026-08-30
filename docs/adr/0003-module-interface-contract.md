# ADR 0003 — Paket `module_interface` sebagai kontrak bersama shell dan modul

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `packages/module_interface/`, `lib/modules/module_base.dart`

## Konteks

`arrow_sense` adalah repo terpisah yang di-*mount* ke `modules/arrow_sense` (lihat [ADR 0004](0004-external-module-as-cloned-repo.md)). Modul itu butuh `BaseModule`, `NavigationItem`, `QuickActionItem`, dan layanan refresh token — semuanya awalnya tinggal di `lib/` aplikasi induk dengan nama paket `super_app`.

Kalau modul meng-`import 'package:super_app/...'`, arah dependensi terbalik: modul jadi bergantung pada aplikasi, bukan sebaliknya. Modul tidak bisa di-`pub get`, di-test, atau dikembangkan tanpa seluruh aplikasi induk.

## Keputusan

Kontrak dipisahkan ke paket path-dependency `packages/module_interface`, dan **kedua** sisi bergantung padanya:

```
super_app  ──▶ module_interface ◀── arrow_sense
```

Isi paket sengaja dijaga minimal:

- `module_base.dart` — `BaseModule` + `DashboardWidgetConfig`
- `navigation_item.dart` — `NavigationItem`
- `quick_action_item.dart` — `QuickActionItem`
- `token_refresh_service.dart` — `TokenRefreshService` singleton yang dapat dipanggil modul

Aplikasi induk tidak mendefinisikan ulang kontrak; `lib/modules/module_base.dart` hanya me-*re-export* paket (`export 'package:module_interface/module_interface.dart';`) supaya kode lama yang meng-import path internal tetap kompilasi.

Dependensi `module_interface` dibatasi pada yang benar-benar muncul di permukaan kontrak: `flutter_riverpod` (untuk `Override`), `go_router` (untuk `RouteBase`), `dio`, `shared_preferences`, dan `flutter_dotenv`.

## Konsekuensi

**Positif**
- `arrow_sense` bisa dikembangkan dan di-test sebagai paket berdiri sendiri; satu-satunya dependensi ke ekosistem OSA adalah `module_interface`.
- Perubahan yang merusak kontrak terlihat sebagai perubahan versi paket, bukan sebagai kegagalan kompilasi acak di modul.

**Negatif / biaya**
- Kontrak ikut menyeret pilihan teknologi: karena `routes` bertipe `List<RouteBase>` dan `providerOverrides` bertipe `List<Override>`, **setiap modul wajib memakai GoRouter dan Riverpod**. Mengganti salah satunya berarti perubahan yang merusak seluruh modul.
- `TokenRefreshService` kini ada **dua** implementasi: satu di `packages/module_interface/lib/src/token_refresh_service.dart` (dipakai modul, konfigurasi lewat `AUTH_TOKEN_REFRESH_URL`) dan satu di `lib/core/auth/token_refresh_service.dart` (dipakai shell, konfigurasi lewat `AppInfo`, punya tambahan callback `onAuthExpired`). Keduanya singleton terpisah yang menulis ke kunci SharedPreferences yang sama (`app_saved_user`). Ini duplikasi yang disadari dan menjadi utang teknis — lihat [ADR 0008](0008-auth-jwt-login.md).
- Setiap simbol yang ingin dibagi ke modul harus dinaikkan dulu ke paket ini; menaruhnya di `lib/core/` "sementara" akan langsung mematahkan modul eksternal.

## Alternatif yang ditolak

- **Modul meng-import `package:super_app`** — ditolak: membalik arah dependensi, modul tidak bisa berdiri sendiri.
- **Menerbitkan `module_interface` ke pub.dev** — ditolak untuk saat ini; kontrak masih sering berubah dan path dependency lebih cepat untuk iterasi.

## Referensi

- [`docs/SubModule.md`](../SubModule.md)
