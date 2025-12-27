import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/app_info.dart';

/// GPS Service for handling location functionality
/// 
/// This service provides methods for:
/// - Checking GPS availability and permissions
/// - Getting current location
/// - Streaming location updates
/// - Calculating distance between two points
class GpsService {
  GpsService._();
  
  static final GpsService _instance = GpsService._();
  static GpsService get instance => _instance;

  /// Check if GPS feature is enabled in environment
  bool get isGpsEnabled => AppInfo.enableGps;

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    if (!isGpsEnabled) return false;
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  /// Returns true if permission is granted
  Future<bool> requestPermission() async {
    if (!isGpsEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('GpsService: Location permission denied');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('GpsService: Location permission permanently denied');
      return false;
    }
    
    return true;
  }

  /// Get current position
  /// Returns null if GPS is disabled or permission not granted
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    if (!isGpsEnabled) {
      debugPrint('GpsService: GPS is disabled in environment');
      return null;
    }

    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('GpsService: Location services are disabled');
      return null;
    }

    // Check and request permission
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      debugPrint('GpsService: No location permission');
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeLimit,
        ),
      );
      debugPrint('GpsService: Got position - Lat: ${position.latitude}, Lng: ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('GpsService: Error getting position - $e');
      return null;
    }
  }

  /// Get last known position (faster but may be outdated)
  Future<Position?> getLastKnownPosition() async {
    if (!isGpsEnabled) return null;
    
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('GpsService: Error getting last known position - $e');
      return null;
    }
  }

  /// Stream position updates
  /// Returns empty stream if GPS is disabled
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    if (!isGpsEnabled) {
      debugPrint('GpsService: GPS is disabled, returning empty stream');
      return const Stream.empty();
    }

    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Calculate distance between two points in meters
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate bearing between two points
  double calculateBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Open location settings on the device
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (for permission settings)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Format distance for display
  /// Returns distance in meters or kilometers based on value
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }
}
