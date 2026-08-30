
# Firebase Remote Config

Remote Config memungkinkan perubahan konfigurasi dan feature flag secara real-time dari Firebase Console **tanpa update aplikasi**.

---

## Enable / Disable

Aktifkan atau nonaktifkan fitur ini melalui `.env`:

```env
# ============================================
# FIREBASE REMOTE CONFIG
# ============================================
REMOTE_CONFIG_ENABLE=true   # ganti false untuk nonaktifkan
```

Saat `false`: Firebase **tidak** diinisialisasi sama sekali. Semua getter mengembalikan **default value**.

---

## Custom Remote Config

Selain menggunakan Firebase Console, Anda dapat menggunakan **Custom API** sebagai sumber konfigurasi. Ini berguna jika Anda ingin mengelola parameter secara mandiri tanpa bergantung pada Firebase.

### Konfigurasi `.env`

Aktifkan dengan mengisi URL API pada variable berikut:

```env
REMOTE_CONFIG_CUSTOM_URL="https://your-api.com/remote-config.json"
```

### Prioritas Penggunaan
1. Jika `REMOTE_CONFIG_CUSTOM_URL` **diisi**, app akan mengambil data dari URL tersebut.
2. Jika `REMOTE_CONFIG_CUSTOM_URL` **kosong**, app akan menggunakan Firebase Remote Config.
3. Jika `REMOTE_CONFIG_ENABLE=false`, semua Remote Config dinonaktifkan.

### Format Response API
Referensi struktur JSON untuk Custom API dapat dilihat pada:
`docs/remote_config/remote_config.json`

Struktur dasarnya adalah sebagai berikut:

```json
{
  "parameters": {
    "key_name": {
      "defaultValue": { "value": "default_val" },
      "valueType": "STRING"
    }
  }
}
```

*Note: App akan mencoba mengambil nilai dari field `value` atau `defaultValue.value` di dalam setiap parameter.*


---

## Parameter yang Tersedia

Daftarkan parameter di [Firebase Console](https://console.firebase.google.com/) → **Remote Config**.

| Parameter | Tipe | Default | Keterangan |
|-----------|------|---------|------------|
| `ai_provider` | String | `"carik"` | AI provider: `"gemini"`, `"openai"`, dll. |
| `latest_version` | String | `""` | Versi terbaru app, e.g. `"1.2.0"`. Untuk notifikasi update. |
| `min_version` | String | `""` | Versi minimum yang masih didukung. |
| `latest_version_number` | Int | `0` | Build number versi terbaru, e.g. `92`. Dipakai untuk deteksi update. |
| `minimum_version_number` | Int | `0` | Build number minimum. Di bawah nilai ini user **wajib** update. |
| `force_update` | Bool | `false` | Bila `true`, update jadi **wajib** selama ada versi lebih baru — walau build number masih di atas minimum. |
| `update_url` | String | `""` | URL halaman update (Play Store / App Store). |
| `widget_location_enable` | Bool | `true` | Enable/disable widget lokasi di workspace. |
| `maintenance_mode` | Bool | `false` | Enable/disable maintenance mode. ⚠️ Gunakan `fetchMaintenanceMode()` agar realtime. |

Daftar ini harus selalu sama dengan `_defaults` di
`lib/core/services/remote_config_service.dart:24`.

> [!NOTE]
> Jika menggunakan **Custom Remote Config**, pastikan parameter yang Anda definisikan di API sesuai dengan key yang ada di tabel di atas. Contoh response lengkap ada di [`docs/remote_config/remote_config.json`](./remote_config/remote_config.json). Salinan yang mencerminkan konfigurasi produksi OSA ada di [`tool/remote_config.json`](../tool/remote_config.json).


> Untuk menambah parameter baru, lihat bagian [Menambah Parameter Baru](#menambah-parameter-baru).

---

## Cara Penggunaan

### Import

```dart
import 'package:super_app/core/services/remote_config_service.dart';
```

### Getter Bernama (Recommended)

```dart
// String
final aiProvider    = RemoteConfigService.aiProvider;
final latestVersion = RemoteConfigService.latestVersion;
final updateUrl     = RemoteConfigService.updateUrl;

// Bool
final locationOn      = RemoteConfigService.widgetLocationEnable;
final isMaintenance   = RemoteConfigService.maintenanceMode;
final mustForceUpdate = RemoteConfigService.forceUpdate;
```

### Getter Generik

```dart
final text  = RemoteConfigService.getString('key_name');
final flag  = RemoteConfigService.getBool('feature_flag');
final count = RemoteConfigService.getInt('max_retry');
final score = RemoteConfigService.getDouble('threshold');
```

### Realtime Fetch (Tanpa Cache)

Gunakan saat parameter **harus selalu mencerminkan nilai terkini** dari Firebase Console,
tanpa menunggu cache expired (misal: `maintenance_mode`, kill-switch fitur).

```dart
// Named shortcut — paling umum dipakai
final isMaintenance = await RemoteConfigService.fetchMaintenanceMode();

// Generic fetch by key
final flag   = await RemoteConfigService.fetchBool('maintenance_mode');
final text   = await RemoteConfigService.fetchString('ai_provider');
final count  = await RemoteConfigService.fetchInt('max_retry');
final score  = await RemoteConfigService.fetchDouble('threshold');

// Low-level: hanya fetch + activate, baca sendiri setelahnya
final updated = await RemoteConfigService.fetchRealtime();
final isMaintenance = RemoteConfigService.maintenanceMode; // baca dari cache yg baru di-activate
```

> ⚠️ **Perhatikan Firebase quota**: Firebase membatasi **5 fetch per jam per device** di production.
> Gunakan realtime fetch hanya di titik kritis (splash screen, sebelum aksi penting),
> bukan di setiap build widget.

---

## Contoh Penggunaan

### Cek Update Aplikasi (berbasis build number)

Perbandingan versi memakai **build number** (angka setelah `+` pada `pubspec.yaml`,
mis. `1.1.5+84` → `84`), bukan string versi.

| Kondisi | Perilaku |
|---------|----------|
| `force_update = true` **dan** ada versi lebih baru | Update **wajib** — walau build number masih di atas `minimum_version_number`. |
| `buildNumber < minimum_version_number` | Update **wajib** — dialog tidak bisa ditutup (barrier & tombol back mati), hanya tombol *Update*. |
| `buildNumber < latest_version_number` | Update **opsional** — user memilih *Update App* atau *Continue Without Updating* (lanjut memakai aplikasi). |
| lainnya | Tidak ada dialog. |

Sumber build number terbaru (urut prioritas): parameter `latest_version_number` →
suffix `+build` pada `latest_version` → `version.versionNumber` di root JSON.
Sumber build number minimum: parameter `minimum_version_number` (alias
`min_version_number`) → suffix `+build` pada `min_version` →
`version.minimumVersionNumber` di root JSON.

> Urutan evaluasi: `force_update` diperiksa lebih dulu, baru `minimum_version_number`.
> Cukup salah satu terpenuhi untuk membuat update jadi wajib.

```dart
// Dashboard — dialog tampil sekali per sesi aplikasi
RemoteConfigService.checkForUpdate(context);

// Paksa tampil lagi, mis. dari menu "Cek pembaruan"
RemoteConfigService.checkForUpdate(context, force: true);

// Cek manual
RemoteConfigService.currentVersionNumber;  // build number app saat ini
RemoteConfigService.latestVersionNumber;   // build number terbaru
RemoteConfigService.minimumVersionNumber;  // build number minimum
RemoteConfigService.isUpdateAvailable;     // ada versi lebih baru
RemoteConfigService.isUpdateRequired;      // wajib update
```

### Pilih AI Provider

```dart
final provider = RemoteConfigService.aiProvider;

switch (provider) {
  case 'gemini':
    return GeminiAiService();
  case 'openai':
    return OpenAiService();
  default:
    return DefaultAiService();
}
```

### Maintenance Mode (Realtime)

```dart
// Di splash screen / router guard
final isMaintenance = await RemoteConfigService.fetchMaintenanceMode();
if (isMaintenance) {
  Navigator.pushReplacementNamed(context, '/maintenance');
  return;
}
```

### Feature Flag Widget

```dart
if (RemoteConfigService.widgetLocationEnable) {
  return const LocationWidget();
}
return const SizedBox.shrink();
```

---

## Menambah Parameter Baru

**1. Tambah di Firebase Console** → Remote Config → Add parameter

**2. Daftarkan default di `remote_config_service.dart`**

```dart
static const Map<String, dynamic> _defaults = {
  'ai_provider': 'carik',
  'latest_version': '',
  'widget_location_enable': true,
  'maintenance_mode': false,
  'force_update': false,
  'update_url': '',
  'min_version': '',
  'latest_version_number': 0,
  'minimum_version_number': 0,
  'your_new_param': 'default_value',  // ← tambah di sini
};
```

**3. Tambah getter bernama (opsional tapi recommended)**

```dart
static String get yourNewParam => getString('your_new_param');
```

**4. Tambah ke debug log di `initialize()`**

```dart
debugPrint('[RemoteConfig]    your_new_param = "${getString('your_new_param')}"');
```

---

## Fetch Behavior

| Environment | Interval | Keterangan |
|-------------|----------|------------|
| Production (`ENVIRONMENT=production`) | 1 jam | Sesuai Firebase quota |
| Development | 0 detik | Fetch setiap launch |

> Firebase membatasi fetch: maks **5 kali per jam** per device di production. Cache tetap aktif jika quota habis.

---

## Debug Log

```
[RemoteConfig] ✅ REMOTE_CONFIG_ENABLE=true — starting initialization...
[RemoteConfig] 📋 Defaults loaded:
[RemoteConfig]    ai_provider = carik
[RemoteConfig]    latest_version =
[RemoteConfig]    widget_location_enable = true
[RemoteConfig]    maintenance_mode = false
[RemoteConfig]    force_update = false
[RemoteConfig] ⏱  Fetch interval: production (1h)
[RemoteConfig] 🔄 Fetching from Firebase Console...
[RemoteConfig] 🆕 New values fetched and activated.
[RemoteConfig] 📦 Active parameter values:
[RemoteConfig]    ai_provider    = "gemini"
[RemoteConfig]    latest_version = "1.2.0"
[RemoteConfig]    widget_location_enable = "true"
```

| Ikon | Arti |
|------|------|
| ✅ | Remote Config aktif |
| ⛔ | Dinonaktifkan via `.env` |
| 📋 | Default values dimuat |
| ⏱ | Fetch interval dikonfigurasi |
| 🔄 | Sedang fetch dari Firebase |
| 🆕 | Nilai baru berhasil diambil |
| 🔁 | Tidak ada nilai baru, pakai cache |
| 📦 | Parameter aktif setelah fetch |
| ❌ | Error (non-fatal, app tetap berjalan) |

---

*Diperbarui: 28 Agustus 2026*
