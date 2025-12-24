# Permission Helper

A utility class for managing Android runtime permissions in Flutter.

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