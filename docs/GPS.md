# GPS / Location Feature

Fitur GPS memungkinkan aplikasi mengakses lokasi pengguna menggunakan package `geolocator`. Fitur ini dapat diaktifkan atau dinonaktifkan melalui environment variable.

## Table of Contents

- [Environment Configuration](#environment-configuration)
- [Dependencies](#dependencies)
- [Platform Configuration](#platform-configuration)
- [Architecture](#architecture)
- [Usage](#usage)
  - [Using LocationDisplayWidget](#using-locationdisplaywidget)
  - [Using GetLocationButton](#using-getlocationbutton)
  - [Using GpsProvider Directly](#using-gpsprovider-directly)
  - [Using GpsService Directly](#using-gpsservice-directly)
- [API Reference](#api-reference)
- [Localization](#localization)
- [Troubleshooting](#troubleshooting)

---

## Environment Configuration

Tambahkan variabel berikut di file `.env`:

```env
# Enable/disable GPS feature
ENABLE_GPS=true
```

| Value | Description |
|-------|-------------|
| `true` | GPS feature enabled, widgets ditampilkan |
| `false` | GPS feature disabled, widgets disembunyikan |

Akses di kode melalui `AppInfo.enableGps`:

```dart
import 'package:super_app/core/constants/app_info.dart';

if (AppInfo.enableGps) {
  // GPS is enabled
}
```

---

## Dependencies

Package yang digunakan (`pubspec.yaml`):

```yaml
dependencies:
  geolocator: ^13.0.2  # GPS & Location
```

---

## Platform Configuration

### Android

Permission sudah dikonfigurasi di `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Location/GPS Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS

Permission descriptions sudah dikonfigurasi di `ios/Runner/Info.plist`:

```xml
<!-- Location Permissions -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when in use to show your current position.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location when in background to track your position.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location to show your current position and track in background.</string>
```

---

## Architecture

```
lib/
├── core/
│   ├── constants/
│   │   └── app_info.dart          # enableGps getter
│   ├── gps/
│   │   ├── gps_service.dart       # GPS Service (singleton)
│   │   └── gps_provider.dart      # Riverpod providers
│   └── l10n/
│       └── app_localizations.dart # GPS strings (ID/EN)
└── shared/
    └── widgets/
        └── location_display_widget.dart  # UI widgets
```

### GpsService (`lib/core/gps/gps_service.dart`)

Singleton service untuk menangani operasi GPS:

- Permission handling
- Get current position
- Get last known position
- Position stream
- Distance & bearing calculation

### GpsProvider (`lib/core/gps/gps_provider.dart`)

Riverpod state management:

- `gpsProvider` - StateNotifier untuk GPS state
- `gpsServiceProvider` - Provider untuk GpsService instance
- `positionStreamProvider` - StreamProvider untuk real-time updates
- `isGpsEnabledProvider` - Check apakah GPS enabled

### GpsState

```dart
class GpsState {
  final Position? currentPosition;
  final bool isLoading;
  final bool hasPermission;
  final bool isServiceEnabled;
  final String? errorMessage;
  
  // Computed properties
  bool get isReady;
  bool get hasPosition;
  double get latitude;
  double get longitude;
  double get accuracy;
  double get altitude;
  String get coordinatesString;
}
```

---

## Usage

### Using LocationDisplayWidget

Widget lengkap untuk menampilkan lokasi dengan UI yang sudah jadi.

```dart
import 'package:super_app/shared/widgets/location_display_widget.dart';
import 'package:super_app/core/constants/app_info.dart';

// Full view (Card dengan detail)
if (AppInfo.enableGps)
  LocationDisplayWidget(
    onLocationUpdated: (lat, lng) {
      debugPrint('Location: $lat, $lng');
    },
  ),

// Compact view (untuk toolbar/header)
if (AppInfo.enableGps)
  LocationDisplayWidget(
    compact: true,
    onLocationUpdated: (lat, lng) {
      // Handle location update
    },
  ),
```

**Full View Features:**
- Header dengan icon dan koordinat
- Tombol refresh
- Detail Latitude, Longitude, Accuracy
- Error message dengan tombol Open Settings
- Tombol "Get Location" jika belum ada posisi

**Compact View Features:**
- Inline display dengan icon
- Tap untuk refresh lokasi
- Koordinat atau "My Location" text

### Using GetLocationButton

Button sederhana untuk mendapatkan lokasi.

```dart
import 'package:super_app/shared/widgets/location_display_widget.dart';

GetLocationButton(
  label: 'My Location',  // Optional
  icon: Icons.location_on,  // Optional, default: Icons.location_on
  onLocationRetrieved: (lat, lng) {
    // Handle location
    print('Lat: $lat, Lng: $lng');
  },
)
```

### Using GpsProvider Directly

Untuk kontrol penuh dengan Riverpod.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_app/core/gps/gps_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpsState = ref.watch(gpsProvider);
    
    return Column(
      children: [
        // Show loading indicator
        if (gpsState.isLoading)
          CircularProgressIndicator(),
        
        // Show coordinates
        if (gpsState.hasPosition)
          Text('Location: ${gpsState.coordinatesString}'),
        
        // Show error
        if (gpsState.errorMessage != null)
          Text('Error: ${gpsState.errorMessage}'),
        
        // Get location button
        ElevatedButton(
          onPressed: () async {
            final position = await ref.read(gpsProvider.notifier).getCurrentLocation();
            if (position != null) {
              print('Got location: ${position.latitude}, ${position.longitude}');
            }
          },
          child: Text('Get Location'),
        ),
      ],
    );
  }
}
```

**GpsNotifier Methods:**

```dart
// Initialize GPS and check status
await ref.read(gpsProvider.notifier).initialize();

// Request permission
bool granted = await ref.read(gpsProvider.notifier).requestPermission();

// Get current location
Position? position = await ref.read(gpsProvider.notifier).getCurrentLocation(
  accuracy: LocationAccuracy.high,  // Optional
);

// Clear position
ref.read(gpsProvider.notifier).clearPosition();

// Clear error
ref.read(gpsProvider.notifier).clearError();

// Open device location settings
await ref.read(gpsProvider.notifier).openLocationSettings();

// Open app settings
await ref.read(gpsProvider.notifier).openAppSettings();

// Calculate distance to target
double? meters = ref.read(gpsProvider.notifier).distanceTo(-6.2, 106.8);

// Get formatted distance
String? distance = ref.read(gpsProvider.notifier).formattedDistanceTo(-6.2, 106.8);
// Returns: "500 m" or "1.5 km"
```

### Using GpsService Directly

Untuk akses low-level tanpa state management.

```dart
import 'package:super_app/core/gps/gps_service.dart';

final gpsService = GpsService.instance;

// Check if GPS is enabled in environment
bool isEnabled = gpsService.isGpsEnabled;

// Check if location service is enabled on device
bool serviceEnabled = await gpsService.isLocationServiceEnabled();

// Request permission
bool hasPermission = await gpsService.requestPermission();

// Get current position
Position? position = await gpsService.getCurrentPosition(
  accuracy: LocationAccuracy.high,
  timeLimit: Duration(seconds: 30),
);

// Get last known position (faster but may be outdated)
Position? lastPosition = await gpsService.getLastKnownPosition();

// Stream position updates
Stream<Position> positionStream = gpsService.getPositionStream(
  accuracy: LocationAccuracy.high,
  distanceFilter: 10,  // meters
);

positionStream.listen((position) {
  print('New position: ${position.latitude}, ${position.longitude}');
});

// Calculate distance between two points (meters)
double distance = gpsService.calculateDistance(
  startLatitude: -6.2088,
  startLongitude: 106.8456,
  endLatitude: -6.1751,
  endLongitude: 106.8650,
);

// Calculate bearing between two points (degrees)
double bearing = gpsService.calculateBearing(
  startLatitude: -6.2088,
  startLongitude: 106.8456,
  endLatitude: -6.1751,
  endLongitude: 106.8650,
);

// Format distance for display
String formatted = gpsService.formatDistance(1500);  // "1.5 km"
String formatted2 = gpsService.formatDistance(500);   // "500 m"

// Open device settings
await gpsService.openLocationSettings();
await gpsService.openAppSettings();
```

### Using Position Stream Provider

Untuk real-time location updates.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_app/core/gps/gps_provider.dart';

class LiveLocationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(positionStreamProvider);
    
    return positionAsync.when(
      data: (position) => Text(
        'Live: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

---

## API Reference

### GpsService Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `isGpsEnabled` | `bool` | Check if GPS is enabled in env |
| `isLocationServiceEnabled()` | `Future<bool>` | Check if device location is enabled |
| `checkPermission()` | `Future<LocationPermission>` | Check current permission status |
| `requestPermission()` | `Future<bool>` | Request location permission |
| `getCurrentPosition()` | `Future<Position?>` | Get current GPS position |
| `getLastKnownPosition()` | `Future<Position?>` | Get last known position |
| `getPositionStream()` | `Stream<Position>` | Stream of position updates |
| `calculateDistance()` | `double` | Distance in meters between two points |
| `calculateBearing()` | `double` | Bearing in degrees between two points |
| `openLocationSettings()` | `Future<bool>` | Open device location settings |
| `openAppSettings()` | `Future<bool>` | Open app permission settings |
| `formatDistance()` | `String` | Format distance for display |

### LocationAccuracy Options

```dart
LocationAccuracy.lowest      // ~3000m accuracy
LocationAccuracy.low         // ~1000m accuracy
LocationAccuracy.medium      // ~100m accuracy
LocationAccuracy.high        // ~10m accuracy (default)
LocationAccuracy.best        // Best available
LocationAccuracy.bestForNavigation  // Best for navigation
```

---

## Localization

GPS strings tersedia dalam Bahasa Indonesia dan English di `lib/core/l10n/app_localizations.dart`:

| Key | Indonesian | English |
|-----|------------|---------|
| `location` | Lokasi | Location |
| `myLocation` | Lokasi Saya | My Location |
| `gettingLocation` | Mendapatkan lokasi... | Getting location... |
| `gpsDisabled` | GPS Nonaktif | GPS Disabled |
| `gpsDisabledDesc` | Fitur GPS tidak diaktifkan... | GPS feature is not enabled... |
| `locationPermissionDenied` | Izin lokasi ditolak | Location permission denied |
| `locationServiceDisabled` | Layanan lokasi tidak aktif | Location service is disabled |
| `openSettings` | Buka Pengaturan | Open Settings |
| `locationUpdated` | Lokasi diperbarui | Location updated |
| `failedToGetLocation` | Gagal mendapatkan lokasi | Failed to get location |
| `accuracy` | Akurasi | Accuracy |

---

## Troubleshooting

### GPS tidak berfungsi

1. **Pastikan `ENABLE_GPS=true` di `.env`**
   ```env
   ENABLE_GPS=true
   ```

2. **Jalankan `flutter pub get`** setelah update pubspec.yaml

3. **Periksa permission** di device settings

### Permission denied

Widget akan menampilkan error message dengan tombol "Open Settings". User dapat:
1. Tap "Open Settings"
2. Enable location permission untuk app
3. Kembali ke app dan refresh

### Location service disabled

Jika GPS device dimatikan:
1. Widget menampilkan error
2. Tap "Open Settings"
3. Enable Location/GPS di device
4. Kembali ke app dan refresh

### iOS Simulator

GPS di iOS Simulator:
1. Buka Simulator
2. Features → Location → Custom Location...
3. Masukkan koordinat atau pilih preset

### Android Emulator

GPS di Android Emulator:
1. Klik "..." di toolbar emulator
2. Location tab
3. Set latitude/longitude
4. Klik "Set Location"

---

## Example Implementation

Contoh implementasi di Dashboard (`lib/features/dashboard/main_dashboard.dart`):

```dart
// Import
import '../../shared/widgets/location_display_widget.dart';

// Di dalam _buildHomeContent(), setelah BannerCarousel
if (AppInfo.enableGps)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: LocationDisplayWidget(
      onLocationUpdated: (lat, lng) {
        debugPrint('Location updated: $lat, $lng');
      },
    ),
  ),
```

---

## See Also

- [Geolocator Package Documentation](https://pub.dev/packages/geolocator)
- [Permission Helper](./Permission%20Helper.md)
- [Environment Configuration](./Environment.md)
