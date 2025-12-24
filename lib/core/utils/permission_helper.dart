import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

/// Helper class for managing app permissions
class PermissionHelper {
  
  /// Request storage permission
  /// Returns true if permission is granted
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    
    if (status.isGranted) {
      return true;
    }
    
    // For Android 11+ (API 30+), use manageExternalStorage
    if (status.isDenied) {
      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    }
    
    return false;
  }

  /// Request camera permission
  /// Returns true if permission is granted
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photos/gallery permission
  /// Returns true if permission is granted
  static Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    
    // Fallback to storage for older Android versions
    if (!status.isGranted) {
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
    
    return status.isGranted;
  }

  /// Request camera and photos permissions together
  /// Returns true if both permissions are granted
  static Future<bool> requestCameraAndPhotosPermission() async {
    final cameraGranted = await requestCameraPermission();
    final photosGranted = await requestPhotosPermission();
    return cameraGranted && photosGranted;
  }

  /// Request location/GPS permission
  /// Returns true if permission is granted
  static Future<bool> requestLocationPermission() async {
    // First check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, try to open settings
      await Geolocator.openLocationSettings();
      return false;
    }

    // Request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      await openAppSettings();
      return false;
    }

    return true;
  }

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted || 
           await Permission.manageExternalStorage.isGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Check if photos permission is granted
  static Future<bool> hasPhotosPermission() async {
    return await Permission.photos.isGranted || 
           await Permission.storage.isGranted;
  }

  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request all permissions at once
  /// Useful for onboarding flow
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};
    
    results['storage'] = await requestStoragePermission();
    results['camera'] = await requestCameraPermission();
    results['photos'] = await requestPhotosPermission();
    results['location'] = await requestLocationPermission();
    
    return results;
  }

  /// Open app settings (useful when permission is permanently denied)
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
