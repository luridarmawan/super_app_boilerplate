
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

## Parameter yang Tersedia

Daftarkan parameter di [Firebase Console](https://console.firebase.google.com/) → **Remote Config**.

| Parameter | Tipe | Default | Keterangan |
|-----------|------|---------|------------|
| `ai_provider` | String | `"carik"` | AI provider: `"gemini"`, `"openai"`, dll. |
| `latest_version` | String | `""` | Versi terbaru app, e.g. `"1.2.0"`. Untuk notifikasi update. |
| `widget_location_enable` | Bool | `true` | Enable/disable widget lokasi di workspace. |
| `maintenance_mode` | Bool | `false` | Enable/disable maintenance mode. |

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

// Bool
final locationOn = RemoteConfigService.widgetLocationEnable;
```

### Getter Generik

```dart
final text  = RemoteConfigService.getString('key_name');
final flag  = RemoteConfigService.getBool('feature_flag');
final count = RemoteConfigService.getInt('max_retry');
final score = RemoteConfigService.getDouble('threshold');
```

---

## Contoh Penggunaan

### Notifikasi Update Aplikasi

```dart
final latest = RemoteConfigService.latestVersion;

if (latest.isNotEmpty && latest != AppInfo.version) {
  showUpdateDialog(context, latestVersion: latest);
}
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
  'ai_provider': '',
  'latest_version': '',
  'widget_location_enable': true,
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
[RemoteConfig]    ai_provider =
[RemoteConfig]    latest_version =
[RemoteConfig]    widget_location_enable = true
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
