# GPS / Location Feature

The GPS feature allows the application to access user location using the `geolocator` package. This feature can be enabled or disabled via environment variables.

> **📚 Related Documents:**
> - **[README.md](../README.md)** - Main project documentation
> - **[Modular.md](./Modular.md)** - Modular architecture

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

Add the following variables to your `.env` file:

```env
# Enable/disable GPS feature
ENABLE_GPS=true

# Reverse geocoding URL (optional)
# Use {lat} and {lon} as placeholders
# Leave empty to disable address lookup
GPS_REVERSE_GEO_URL=https://nominatim.openstreetmap.org/reverse?format=json&lat={lat}&lon={lon}
```

| Variable | Description |
|----------|-------------|
| `ENABLE_GPS` | `true` to enable GPS, `false` to disable |
| `GPS_REVERSE_GEO_URL` | Reverse geocoding API URL with `{lat}` and `{lon}` placeholders. Leave empty to disable address feature. |

Access in code via `AppInfo`:

```dart
import 'package:super_app/core/constants/app_info.dart';

// Check if GPS is enabled
if (AppInfo.enableGps) {
  // GPS is enabled
}

// Get reverse geocoding URL
String url = AppInfo.gpsReverseGeoUrl;
```

---

## Dependencies

Packages used (`pubspec.yaml`):

```yaml
dependencies:
  geolocator: ^13.0.2  # GPS & Location
```

---

## Platform Configuration

### Android

Permissions are already configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Location/GPS Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS

Permission descriptions are already configured in `ios/Runner/Info.plist`:

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

Singleton service for handling GPS operations:

- Permission handling
- Get current position
- Get last known position
- Position stream
- Distance & bearing calculation
- Reverse geocoding

### GpsProvider (`lib/core/gps/gps_provider.dart`)

Riverpod state management:

- `gpsProvider` - StateNotifier for GPS state
- `gpsServiceProvider` - Provider for GpsService instance
- `positionStreamProvider` - StreamProvider for real-time updates
- `isGpsEnabledProvider` - Check if GPS is enabled

### GpsState

```dart
class GpsState {
  final Position? currentPosition;
  final bool isLoading;
  final bool hasPermission;
  final bool isServiceEnabled;
  final String? errorMessage;
  final String? address;          // Address from reverse geocoding
  final bool isLoadingAddress;    // Loading state for address fetch
  
  // Computed properties
  bool get isReady;
  bool get hasPosition;
  bool get hasAddress;  // Check if address is available
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

A complete widget for displaying location with a ready-made UI.

```dart
import 'package:super_app/shared/widgets/location_display_widget.dart';
import 'package:super_app/core/constants/app_info.dart';

// Full view (Card with details)
if (AppInfo.enableGps)
  LocationDisplayWidget(
    onLocationUpdated: (lat, lng) {
      debugPrint('Location: $lat, $lng');
    },
  ),

// Compact view (for toolbar/header)
if (AppInfo.enableGps)
  LocationDisplayWidget(
    compact: true,
    onLocationUpdated: (lat, lng) {
      // Handle location update
    },
  ),
```

**Full View Features:**
- Map icon with address display
- Refresh button
- Tap address to expand/collapse full text
- Error message (tap to open settings)
- "My Location" prompt when no position yet

**Compact View Features:**
- Inline display with icon
- Tap to refresh location
- Coordinates or "My Location" text

### Using GetLocationButton

A simple button to get location.

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

For full control with Riverpod.

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
        
        // Show address
        if (gpsState.hasAddress)
          Text('Address: ${gpsState.address}'),
        
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

// Clear address
ref.read(gpsProvider.notifier).clearAddress();

// Open device location settings
await ref.read(gpsProvider.notifier).openLocationSettings();

// Open app settings
await ref.read(gpsProvider.notifier).openAppSettings();

// Calculate distance to target
double? meters = ref.read(gpsProvider.notifier).distanceTo(-6.2, 106.8);

// Get formatted distance
String? distance = ref.read(gpsProvider.notifier).formattedDistanceTo(-6.2, 106.8);
// Returns: "500 m" or "1.5 km"

// Get address from current position (reverse geocoding)
String? address = await ref.read(gpsProvider.notifier).getAddressFromCurrentPosition();

// Get address from specific coordinates
String? address2 = await ref.read(gpsProvider.notifier).getAddressFromCoordinates(-6.2, 106.8);
```

### Using GpsService Directly

For low-level access without state management.

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

// Check if reverse geocoding is available
bool hasReverseGeo = gpsService.isReverseGeoEnabled;

// Get address from coordinates (reverse geocoding)
String? address = await gpsService.reverseGeocode(-6.2088, 106.8456);
print('Address: $address');
```

### Using Position Stream Provider

For real-time location updates.

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
| `isReverseGeoEnabled` | `bool` | Check if reverse geocoding URL is configured |
| `reverseGeocode()` | `Future<String?>` | Get address from coordinates |

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

GPS strings are available in Indonesian and English in `lib/core/l10n/app_localizations.dart`:

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
| `address` | Alamat | Address |

---

## Troubleshooting

### GPS not working

1. **Ensure `ENABLE_GPS=true` in `.env`**
   ```env
   ENABLE_GPS=true
   ```

2. **Run `flutter pub get`** after updating pubspec.yaml

3. **Check permissions** in device settings

### Permission denied

The widget will display an error message with "Open Settings" option. User can:
1. Tap "Open Settings"
2. Enable location permission for the app
3. Return to app and refresh

### Location service disabled

If device GPS is turned off:
1. Widget displays error
2. Tap "Open Settings"
3. Enable Location/GPS on device
4. Return to app and refresh

### Reverse geocoding returns 403 error

If using Nominatim (OpenStreetMap) API and getting 403 Forbidden:
- The `GpsService` already includes a `User-Agent` header which is required by Nominatim
- Ensure your app name is set correctly in `AppInfo.name`

### iOS Simulator

GPS in iOS Simulator:
1. Open Simulator
2. Features → Location → Custom Location...
3. Enter coordinates or select a preset

### Android Emulator

GPS in Android Emulator:
1. Click "..." on emulator toolbar
2. Location tab
3. Set latitude/longitude
4. Click "Set Location"

---

## Example Implementation

Example implementation in Dashboard (`lib/features/dashboard/main_dashboard.dart`):

```dart
// Import
import '../../shared/widgets/location_display_widget.dart';

// Inside _buildHomeContent(), after BannerCarousel
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

- **[README.md](../README.md)** - Main project documentation
- **[Modular.md](./Modular.md)** - Modular architecture
- **[API.md](./API.md)** - Network layer documentation
- [Geolocator Package Documentation](https://pub.dev/packages/geolocator)

---

*Updated: January 1, 2026*
*Version: 1.2.1*
