import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum to represent the connectivity status
enum ConnectivityStatus {
  online,
  offline,
}

/// Provider for the Connectivity instance
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// StreamProvider that monitors connectivity changes
final connectivityStreamProvider = StreamProvider<ConnectivityStatus>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  
  return connectivity.onConnectivityChanged.map((results) {
    // Check if any connectivity result indicates we're online
    final hasConnection = results.any((result) => 
      result != ConnectivityResult.none
    );
    return hasConnection ? ConnectivityStatus.online : ConnectivityStatus.offline;
  });
});

/// Provider to check the current connectivity status
final currentConnectivityProvider = FutureProvider<ConnectivityStatus>((ref) async {
  final connectivity = ref.watch(connectivityProvider);
  final results = await connectivity.checkConnectivity();
  
  final hasConnection = results.any((result) => 
    result != ConnectivityResult.none
  );
  return hasConnection ? ConnectivityStatus.online : ConnectivityStatus.offline;
});

/// Combined provider that uses both stream and current status
/// This ensures we always have a status, even on first load
final connectivityStatusProvider = Provider<ConnectivityStatus>((ref) {
  // First try to get the stream value
  final streamStatus = ref.watch(connectivityStreamProvider);
  
  return streamStatus.when(
    data: (status) => status,
    loading: () {
      // While loading, try to get current status
      final currentStatus = ref.watch(currentConnectivityProvider);
      return currentStatus.when(
        data: (status) => status,
        loading: () => ConnectivityStatus.online, // Assume online initially
        error: (_, __) => ConnectivityStatus.online,
      );
    },
    error: (_, __) => ConnectivityStatus.online, // Assume online on error
  );
});

/// Simple boolean provider for convenience
final isOfflineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider);
  return status == ConnectivityStatus.offline;
});
