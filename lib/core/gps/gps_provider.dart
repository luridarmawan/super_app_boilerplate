import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'gps_service.dart';

/// Provider for GpsService singleton instance
final gpsServiceProvider = Provider<GpsService>((ref) {
  return GpsService.instance;
});

/// State class for GPS location
class GpsState {
  final Position? currentPosition;
  final bool isLoading;
  final bool hasPermission;
  final bool isServiceEnabled;
  final String? errorMessage;
  final String? address;
  final bool isLoadingAddress;

  const GpsState({
    this.currentPosition,
    this.isLoading = false,
    this.hasPermission = false,
    this.isServiceEnabled = false,
    this.errorMessage,
    this.address,
    this.isLoadingAddress = false,
  });

  GpsState copyWith({
    Position? currentPosition,
    bool? isLoading,
    bool? hasPermission,
    bool? isServiceEnabled,
    String? errorMessage,
    String? address,
    bool? isLoadingAddress,
    bool clearPosition = false,
    bool clearError = false,
    bool clearAddress = false,
  }) {
    return GpsState(
      currentPosition: clearPosition ? null : (currentPosition ?? this.currentPosition),
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      address: clearAddress ? null : (address ?? this.address),
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
    );
  }

  /// Check if GPS is available and ready
  bool get isReady => hasPermission && isServiceEnabled && !isLoading;

  /// Check if we have a valid position
  bool get hasPosition => currentPosition != null;

  /// Check if we have an address
  bool get hasAddress => address != null && address!.isNotEmpty;

  /// Get latitude (or 0 if no position)
  double get latitude => currentPosition?.latitude ?? 0;

  /// Get longitude (or 0 if no position)
  double get longitude => currentPosition?.longitude ?? 0;

  /// Get accuracy in meters (or 0 if no position)
  double get accuracy => currentPosition?.accuracy ?? 0;

  /// Get altitude in meters (or 0 if no position)
  double get altitude => currentPosition?.altitude ?? 0;

  /// Get formatted coordinates string
  String get coordinatesString {
    if (currentPosition == null) return 'No location';
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }
}

/// StateNotifier for managing GPS state
class GpsNotifier extends StateNotifier<GpsState> {
  final GpsService _gpsService;

  GpsNotifier(this._gpsService) : super(const GpsState());

  /// Initialize GPS service and check status
  Future<void> initialize() async {
    if (!_gpsService.isGpsEnabled) {
      state = state.copyWith(
        errorMessage: 'GPS is disabled in app configuration',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final isServiceEnabled = await _gpsService.isLocationServiceEnabled();
      final permission = await _gpsService.checkPermission();
      final hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      state = state.copyWith(
        isLoading: false,
        isServiceEnabled: isServiceEnabled,
        hasPermission: hasPermission,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize GPS: $e',
      );
    }
  }

  /// Request GPS permission
  Future<bool> requestPermission() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final granted = await _gpsService.requestPermission();
      state = state.copyWith(
        isLoading: false,
        hasPermission: granted,
        errorMessage: granted ? null : 'Location permission denied',
      );
      return granted;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to request permission: $e',
      );
      return false;
    }
  }

  /// Get current location
  Future<Position?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final position = await _gpsService.getCurrentPosition(accuracy: accuracy);
      
      if (position != null) {
        state = state.copyWith(
          isLoading: false,
          currentPosition: position,
          hasPermission: true,
          isServiceEnabled: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Unable to get current location',
        );
      }
      
      return position;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to get location: $e',
      );
      return null;
    }
  }

  /// Clear current position
  void clearPosition() {
    state = state.copyWith(clearPosition: true, clearError: true, clearAddress: true);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear address
  void clearAddress() {
    state = state.copyWith(clearAddress: true);
  }

  /// Get address from current position using reverse geocoding
  /// Returns null if GPS_REVERSE_GEO_URL is not configured or request fails
  Future<String?> getAddressFromCurrentPosition() async {
    if (!state.hasPosition) {
      return null;
    }

    if (!_gpsService.isReverseGeoEnabled) {
      return null;
    }

    state = state.copyWith(isLoadingAddress: true);

    try {
      final address = await _gpsService.reverseGeocode(
        state.latitude,
        state.longitude,
      );

      state = state.copyWith(
        isLoadingAddress: false,
        address: address,
      );

      return address;
    } catch (e) {
      state = state.copyWith(
        isLoadingAddress: false,
      );
      return null;
    }
  }

  /// Get address from specific coordinates
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    if (!_gpsService.isReverseGeoEnabled) {
      return null;
    }

    return await _gpsService.reverseGeocode(lat, lng);
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    await _gpsService.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await _gpsService.openAppSettings();
  }

  /// Calculate distance from current position to a target
  double? distanceTo(double targetLat, double targetLng) {
    if (state.currentPosition == null) return null;
    
    return _gpsService.calculateDistance(
      startLatitude: state.latitude,
      startLongitude: state.longitude,
      endLatitude: targetLat,
      endLongitude: targetLng,
    );
  }

  /// Get formatted distance to target
  String? formattedDistanceTo(double targetLat, double targetLng) {
    final distance = distanceTo(targetLat, targetLng);
    if (distance == null) return null;
    return _gpsService.formatDistance(distance);
  }
}

/// Provider for GPS state management
final gpsProvider = StateNotifierProvider<GpsNotifier, GpsState>((ref) {
  final gpsService = ref.watch(gpsServiceProvider);
  return GpsNotifier(gpsService);
});

/// Provider for position stream
final positionStreamProvider = StreamProvider<Position>((ref) {
  final gpsService = ref.watch(gpsServiceProvider);
  return gpsService.getPositionStream();
});

/// Provider to check if GPS feature is enabled
final isGpsEnabledProvider = Provider<bool>((ref) {
  final gpsService = ref.watch(gpsServiceProvider);
  return gpsService.isGpsEnabled;
});
