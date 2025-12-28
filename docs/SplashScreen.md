# Splash Screen 

Cara kerja splash screen:

1. **Jika belum login**: Splash screen akan **selalu ditampilkan**.
2. **Jika sudah login**:
   - Splash screen ditampilkan pada 5 peluncuran awal aplikasi.
   - Setelah itu, splash screen hanya akan muncul kembali apabila pengguna tidak membuka aplikasi selama lebih dari 24 jam (nilai dapat dikonfigurasi melalui .env).


## Konfigurasi .env

```env
ENABLE_SPLASH_SCREEN=true
SPLASH_SHOW_COUNT=5
SPLASH_DELAY=24
```

| Variable | Deskripsi | Default |
|----------|-----------|---------|
| `ENABLE_SPLASH_SCREEN` | Aktifkan/nonaktifkan splash screen | `false` |
| `SPLASH_SHOW_COUNT` | Jumlah peluncuran awal yang menampilkan splash screen (untuk user yang sudah login) | `5` |
| `SPLASH_DELAY` | Jam tidak aktif sebelum splash screen ditampilkan kembali (untuk user yang sudah login) | `24` |


## Implementasi Teknis

### File yang Terlibat

1. **`lib/core/constants/app_info.dart`**
   - `enableSplashScreen`: Flag untuk mengaktifkan splash screen
   - `splashShowCount`: Jumlah launch awal untuk menampilkan splash
   - `splashDelayHours`: Jam delay sebelum splash muncul kembali

2. **`lib/core/services/prefs_service.dart`**
   - `splashOpenCount`: Menghitung berapa kali app dibuka
   - `lastOpenedTime`: Waktu terakhir app dibuka
   - `shouldShowSplash()`: Menentukan apakah splash harus ditampilkan
   - `recordAppOpen()`: Mencatat setiap pembukaan app

3. **`lib/core/routes/app_router.dart`**
   - Logic untuk menentukan `initialLocation` berdasarkan kondisi splash dan status login

### Flow Logic

```
┌─────────────────────────────────────┐
│        App Launched                 │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│    ENABLE_SPLASH_SCREEN = true?     │
└─────────────────┬───────────────────┘
                  │
        ┌─────────┴─────────┐
        │ No                │ Yes
        ▼                   ▼
┌───────────────┐  ┌───────────────────────────┐
│ Skip Splash   │  │      User Logged In?      │
│ → Login/Dash  │  └─────────────┬─────────────┘
└───────────────┘                │
                       ┌─────────┴─────────┐
                       │ No                │ Yes
                       ▼                   ▼
              ┌──────────────┐   ┌───────────────────────────┐
              │ Show Splash  │   │ openCount < SPLASH_COUNT? │
              │ → Login      │   └─────────────┬─────────────┘
              └──────────────┘                 │
                                     ┌─────────┴─────────┐
                                     │ Yes               │ No
                                     ▼                   ▼
                            ┌──────────────┐   ┌──────────────────────────┐
                            │ Show Splash  │   │ lastOpen > DELAY hours?  │
                            │ → Dashboard  │   └────────────┬─────────────┘
                            └──────────────┘                │
                                                  ┌─────────┴─────────┐
                                                  │ Yes               │ No
                                                  ▼                   ▼
                                         ┌──────────────┐    ┌───────────────┐
                                         │ Show Splash  │    │ Skip Splash   │
                                         │ → Dashboard  │    │ → Dashboard   │
                                         └──────────────┘    └───────────────┘
```
