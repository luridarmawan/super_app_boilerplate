# ADR 0001 — Layering Clean Architecture: `core` / `features` / `modules` / `shared`

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `lib/core/`, `lib/features/`, `lib/modules/`, `lib/shared/`

## Konteks

OSA dibangun di atas [Boilerplate Super App](https://github.com/luridarmawan/super_app_module) yang harus melayani dua kebutuhan sekaligus: (a) menjadi *shell* aplikasi dengan fitur bawaan (auth, dashboard, profil, setelan), dan (b) menjadi host bagi modul bisnis yang dikembangkan terpisah — dalam produk ini `arrow_sense`.

Kalau semua kode ditaruh dalam satu folder `screens/`, infrastruktur (network, auth, tema) akan tercampur dengan fitur, dan modul eksternal terpaksa meng-`import` layar aplikasi induk. Ketergantungan itu membuat modul tidak bisa dilepas/dipasang lagi.

## Keputusan

Kode `lib/` dibagi menjadi empat lapis dengan arah dependensi satu arah:

```
features ─┐
modules  ─┼──▶ core        (infrastruktur; tidak boleh meng-import ke atas)
shared   ─┘
```

| Folder | Isi | Aturan |
|--------|-----|--------|
| `lib/core/` | auth, network, l10n, theme, gps, notification, routes, services, config, constants | **Tidak boleh** meng-import `features/`, `modules/`, atau `shared/` |
| `lib/features/` | fitur bawaan shell: auth, dashboard, profile, settings, splash, campaign, maintenance | Boleh memakai `core` dan `shared` |
| `lib/modules/` | modul internal (`news`, `sample`) + registry modul | Boleh memakai `core`; berbicara ke shell lewat kontrak `BaseModule` |
| `lib/shared/` | widget & layar info yang dipakai lintas fitur | Boleh memakai `core` saja |

## Konsekuensi

**Positif**
- `core` menjadi lapisan paling stabil: analisis graf menunjukkan fan-in tinggi (48 masuk, 0 keluar) — persis profil yang diharapkan untuk lapisan infrastruktur.
- Modul dapat dinonaktifkan tanpa menyentuh `core` atau `features`.
- Aturan arah dependensi bisa dicek cepat lewat graf: batas antar-paket yang tercatat adalah `features → core`, `shared → core`, `modules → features`, `modules → core` — tidak ada `core → features`.

**Negatif / biaya**
- Ada jalur `modules → features` (12 pemanggilan) yang secara ketat melanggar semangat lapisan: modul internal masih menyentuh layar fitur. Ini ditoleransi untuk modul *internal* (`lib/modules/news`), tetapi **tidak** boleh terjadi untuk modul eksternal — lihat [ADR 0003](0003-module-interface-contract.md).
- Aturan ini tidak ditegakkan oleh compiler; hanya konvensi + review.

## Alternatif yang ditolak

- **Feature-first murni** (setiap fitur membawa network/theme sendiri) — ditolak karena duplikasi interceptor, tema, dan lokalisasi di setiap fitur.
- **Satu paket per lapis (multi-package workspace)** — ditolak karena menambah biaya build dan `pub get` untuk keuntungan yang belum dibutuhkan pada skala ini; hanya kontrak modul yang dipisahkan menjadi paket (lihat ADR 0003).

## Referensi

- [`docs/SuperApp-Architecture.md`](../SuperApp-Architecture.md)
- [`BRIEF.md` §5 Arsitektur](../../BRIEF.md)
