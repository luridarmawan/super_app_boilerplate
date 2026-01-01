# Permission Helper

A utility class for managing Android and iOS runtime permissions in Flutter.

> **📚 Related Documents:**
> - **[GPS.md](./GPS.md)** - GPS/Location feature documentation
> - **[Notification.md](./Notification.md)** - Push notification (requires permission)
> - **[README.md](../README.md)** - Main project documentation

## Overview

The `PermissionHelper` class provides a simple and unified API to request and check permissions for:

- **Storage** - Read/write access to internal storage
- **Camera** - Capture photos using device camera
- **Photos/Gallery** - Access images from device gallery
- **Location/GPS** - Access device location

## Installation

Make sure these packages are added to your `pubspec.yaml`:

```yaml
dependencies:
  permission_handler: ^11.3.1
  geolocator: ^13.0.2
```

## Usage

### Import

```dart
import 'package:super_app/core/utils/permission_helper.dart';
```

### Requesting Permissions

```dart
// Request storage permission
bool hasStorage = await PermissionHelper.requestStoragePermission();

// Request camera permission
bool hasCamera = await PermissionHelper.requestCameraPermission();

// Request photos/gallery permission
bool hasPhotos = await PermissionHelper.requestPhotosPermission();

// Request camera and photos together
bool hasCameraAndPhotos = await PermissionHelper.requestCameraAndPhotosPermission();

// Request location/GPS permission
bool hasLocation = await PermissionHelper.requestLocationPermission();
```

### Request All Permissions at Once

Useful for onboarding flows:

```dart
Map<String, bool> results = await PermissionHelper.requestAllPermissions();

// Example result:
// {
//   'storage': true,
//   'camera': true,
//   'photos': true,
//   'location': false
// }

if (results['camera'] == true) {
  // Camera permission granted
}
```

### Checking Permission Status

```dart
bool hasStorage = await PermissionHelper.hasStoragePermission();
bool hasCamera = await PermissionHelper.hasCameraPermission();
bool hasPhotos = await PermissionHelper.hasPhotosPermission();
bool hasLocation = await PermissionHelper.hasLocationPermission();
```

### Handling Permanently Denied Permissions

When a user permanently denies a permission, redirect them to app settings:

```dart
bool granted = await PermissionHelper.requestCameraPermission();

if (!granted) {
  // Show dialog explaining why permission is needed
  // Then open app settings
  await PermissionHelper.openSettings();
}
```

## API Reference

| Method | Returns | Description |
|--------|---------|-------------|
| `requestStoragePermission()` | `Future<bool>` | Request storage read/write permission |
| `requestCameraPermission()` | `Future<bool>` | Request camera permission |
| `requestPhotosPermission()` | `Future<bool>` | Request photos/gallery permission |
| `requestCameraAndPhotosPermission()` | `Future<bool>` | Request both camera and photos permissions |
| `requestLocationPermission()` | `Future<bool>` | Request GPS location permission |
| `requestAllPermissions()` | `Future<Map<String, bool>>` | Request all permissions at once |
| `hasStoragePermission()` | `Future<bool>` | Check if storage permission is granted |
| `hasCameraPermission()` | `Future<bool>` | Check if camera permission is granted |
| `hasPhotosPermission()` | `Future<bool>` | Check if photos permission is granted |
| `hasLocationPermission()` | `Future<bool>` | Check if location permission is granted |
| `openSettings()` | `Future<void>` | Open app settings page |

## Important Notes

### Android Version Compatibility

| Android Version | API Level | Notes |
|-----------------|-----------|-------|
| Android 11+ | API 30+ | Use `MANAGE_EXTERNAL_STORAGE` for full storage access (Scoped Storage) |
| Android 13+ | API 33+ | Use `READ_MEDIA_IMAGES` for gallery access instead of `READ_EXTERNAL_STORAGE` |

### Best Practices

1. **Request at Runtime** - All permissions must be requested at runtime, not just declared in the manifest
2. **Explain Before Requesting** - Show a dialog explaining why the permission is needed before requesting
3. **Handle Denials Gracefully** - Provide fallback functionality when permissions are denied
4. **Permanently Denied** - Use `openSettings()` to guide users to enable permissions manually

### Example: Complete Permission Flow

```dart
Future<void> takePicture() async {
  // Check if camera permission is already granted
  if (await PermissionHelper.hasCameraPermission()) {
    // Permission granted, proceed with camera
    _openCamera();
    return;
  }

  // Request permission
  bool granted = await PermissionHelper.requestCameraPermission();
  
  if (granted) {
    _openCamera();
  } else {
    // Show message and optionally open settings
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Camera Permission Required'),
        content: Text('Please enable camera permission in settings to take photos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              PermissionHelper.openSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
```

## Related Files

- **Permission Helper Class**: `lib/core/utils/permission_helper.dart`
- **Android Manifest**: `android/app/src/main/AndroidManifest.xml`
- **iOS Info.plist**: `ios/Runner/Info.plist`

---

## iOS Configuration

For iOS, permissions are configured in `ios/Runner/Info.plist`:

### Camera Permission

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos.</string>
```

### Photo Library Permission

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs photo library access to save images.</string>
```

### Location Permission

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show your current position.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs location access in background to track your position.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to show your position and track in background.</string>
```

### iOS vs Android Comparison

| Permission | Android | iOS |
|------------|---------|-----|
| Camera | `CAMERA` | `NSCameraUsageDescription` |
| Gallery | `READ_MEDIA_IMAGES` (API 33+) | `NSPhotoLibraryUsageDescription` |
| Storage | `READ_EXTERNAL_STORAGE` | Not needed |
| Location | `ACCESS_FINE_LOCATION` | `NSLocationWhenInUseUsageDescription` |
| Background Location | `ACCESS_BACKGROUND_LOCATION` | `NSLocationAlwaysUsageDescription` |

---

## See Also

- **[GPS.md](./GPS.md)** - Complete GPS/Location documentation
- **[Notification.md](./Notification.md)** - Push notification (POST_NOTIFICATIONS permission)
- [permission_handler Package](https://pub.dev/packages/permission_handler)
- [geolocator Package](https://pub.dev/packages/geolocator)

---

*Updated: January 1, 2026*
*Version: 1.0.1*
