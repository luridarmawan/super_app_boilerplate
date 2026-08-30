# Architecture Decision Records — OSA (aplikasi utama)

Catatan keputusan arsitektur untuk aplikasi induk OSA (`super_app`). Setiap ADR merekam **konteks** yang melatarbelakangi keputusan, **keputusan** itu sendiri, **konsekuensi** yang ditanggung (positif maupun biayanya), dan **alternatif** yang ditolak.

> ADR untuk modul **Arrow Sense** berada terpisah di [`modules/arrow_sense/docs/adr/`](../../modules/arrow_sense/docs/adr/README.md), karena modul itu dikembangkan sebagai repo tersendiri.

## Daftar

| # | Keputusan | Status |
|---|-----------|--------|
| [0001](0001-clean-architecture-layering.md) | Layering Clean Architecture: `core` / `features` / `modules` / `shared` | Accepted |
| [0002](0002-plugin-module-registry.md) | Sistem modul plugin lewat `ModuleRegistry` | Accepted |
| [0003](0003-module-interface-contract.md) | Paket `module_interface` sebagai kontrak bersama shell dan modul | Accepted |
| [0004](0004-external-module-as-cloned-repo.md) | Modul eksternal di-*clone* lewat manifest, bukan git submodule | Accepted |
| [0005](0005-env-feature-flags.md) | Konfigurasi & feature flag lewat `.env`, bukan build flavor | Accepted |
| [0006](0006-riverpod-gorouter.md) | Riverpod untuk state, GoRouter untuk navigasi | Accepted |
| [0007](0007-network-layer.md) | Network layer Dio + Retrofit di atas `BaseRepository`, dengan penanganan bot-protection | Accepted |
| [0008](0008-auth-jwt-login.md) | Autentikasi WordPress *JWT Login* di balik `BaseAuthService` | Accepted |
| [0009](0009-localization-dart-maps.md) | Lokalisasi memakai `Map<String, String>` Dart, bukan ARB/`gen_l10n` | Accepted |
| [0010](0010-notification-abstraction.md) | Notifikasi push di balik `BaseNotificationService`, produksi memakai `mock` | Accepted |
| [0011](0011-remote-config-kill-switch.md) | Remote Config dua sumber sebagai kill-switch & force-update | Accepted |
| [0012](0012-dart-tooling-scripts.md) | Otomasi proyek sebagai script Dart di `tool/` | Accepted |

## Cara menambah ADR

1. Ambil nomor urut berikutnya, buat berkas `NNNN-judul-kebab-case.md`.
2. Pakai kerangka: **Status**, **Tanggal**, **Konteks kode**, lalu bagian *Konteks* → *Keputusan* → *Konsekuensi* (positif & biaya) → *Alternatif yang ditolak* → *Referensi*.
3. Tambahkan barisnya ke tabel di atas.
4. ADR yang tidak berlaku lagi **tidak dihapus** — ubah statusnya menjadi `Superseded by ADR NNNN` dan biarkan isinya sebagai catatan sejarah.

## Status yang dipakai

- **Accepted** — berlaku dan tercermin di kode saat ini.
- **Superseded by ADR NNNN** — sudah digantikan keputusan lain.
- **Deprecated** — tidak lagi dianjurkan, tetapi jejaknya masih ada di kode.

## Bacaan pendamping

- [`BRIEF.md`](../../BRIEF.md) — sumber tunggal kebenaran untuk produk
- [`docs/SuperApp-Architecture.md`](../SuperApp-Architecture.md) — gambaran arsitektur menyeluruh
- [`docs/Modular.md`](../Modular.md) dan [`docs/SubModule.md`](../SubModule.md) — sistem modul
