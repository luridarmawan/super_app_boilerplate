# ADR 0009 — Lokalisasi memakai `Map<String, String>` Dart, bukan ARB/`gen_l10n`

- **Status:** Accepted
- **Tanggal:** 2026-08-30
- **Konteks kode:** `lib/core/l10n/`, `modules/arrow_sense/lib/l10n/`

## Konteks

OSA mendukung empat bahasa: English (default), Indonesia, Türkçe, dan 한국어. Pendekatan baku Flutter adalah berkas ARB + `flutter gen-l10n`, yang menghasilkan kelas terketik saat build.

Kendalanya di arsitektur ini: **modul membawa string-nya sendiri**. `arrow_sense` punya ratusan istilah panahan yang tidak relevan bagi shell, dan modul adalah repo terpisah. Pipeline `gen-l10n` beroperasi per paket dengan konfigurasi `l10n.yaml`, sehingga setiap modul akan butuh langkah generate sendiri dan menghasilkan delegate yang harus dijahit manual ke `MaterialApp` aplikasi induk.

## Keputusan

Lokalisasi ditulis tangan sebagai peta Dart, dengan pola yang sama di shell maupun modul:

```
lib/core/l10n/
├── app_localizations.dart   # delegate + translate(key) + getter bertipe
├── en_strings.dart          # const Map<String, String>
├── id_strings.dart
├── tr_strings.dart
└── ko_strings.dart
```

- `AppLocalizations.translate(key)` mencari di locale aktif, **fallback ke `en`**, lalu mengembalikan `key` itu sendiri bila tidak ditemukan — tidak pernah melempar exception.
- Setiap modul mereplikasi pola yang sama dengan delegate sendiri (`ArrowSenseLocalizations` dengan `arrowSenseEnStrings`, `arrowSenseIdStrings`, dst.).
- Locale aktif berasal dari `localeProvider` (dipersist ke SharedPreferences), bukan dari locale sistem saja.

## Konsekuensi

**Positif**
- Tidak ada langkah build tambahan; menambah string cukup mengedit empat berkas Dart.
- Modul dapat dilokalkan sepenuhnya tanpa menyentuh l10n shell dan tanpa pipeline generate.
- Fallback berlapis membuat terjemahan yang belum lengkap tidak pernah menyebabkan crash.

**Negatif / biaya**
- **Kunci tidak diperiksa compiler.** Salah ketik menghasilkan teks kunci mentah di layar, bukan error build. Ini diredam sebagian dengan menyediakan getter bertipe di `AppLocalizations` untuk string yang sering dipakai.
- Tidak ada dukungan pluralisasi/ICU dan tidak ada alat untuk mendeteksi kunci yang hilang di salah satu bahasa.
- Tidak kompatibel dengan alat penerjemahan berbasis ARB/XLIFF; menyerahkan pekerjaan ke penerjemah eksternal berarti mengirim berkas Dart.
- **Delegate modul belum terpasang.** Di `lib/main.dart`, `ArrowSenseLocalizations.delegate` masih dikomentari, sehingga `ArrowSenseLocalizations.of(context)` selalu jatuh ke jalur fallback — membuat instance baru dari `Localizations.localeOf(context)` setiap dipanggil. Secara fungsional berjalan (locale tetap benar), tetapi bukan mekanisme yang dirancang dan kehilangan caching delegate. Lihat [ADR modul 0006](../../modules/arrow_sense/docs/adr/0006-module-scoped-localization.md).

## Alternatif yang ditolak

- **ARB + `flutter gen-l10n`** — ditolak: butuh konfigurasi dan langkah generate per paket, merepotkan untuk modul yang berkembang di repo terpisah.
- **`easy_localization` dengan asset JSON** — ditolak: menambah dependensi dan memindahkan string ke asset runtime, sementara keuntungannya di atas peta Dart tipis untuk kebutuhan saat ini.

## Referensi

- [`docs/LOCALIZATION.md`](../LOCALIZATION.md)
