import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_info.dart';
import '../../core/gps/gps_provider.dart';
import '../../core/gps/gps_service.dart';
import '../../core/l10n/app_localizations.dart';

/// Widget to display current GPS location
/// Shows location info if GPS is enabled, otherwise shows disabled message
class LocationDisplayWidget extends ConsumerStatefulWidget {
  /// Whether to show a compact version
  final bool compact;

  /// Optional callback when location is updated
  final Function(double lat, double lng)? onLocationUpdated;

  const LocationDisplayWidget({
    super.key,
    this.compact = false,
    this.onLocationUpdated,
  });

  @override
  ConsumerState<LocationDisplayWidget> createState() => _LocationDisplayWidgetState();
}

class _LocationDisplayWidgetState extends ConsumerState<LocationDisplayWidget> {
  bool _isAddressExpanded = false;

  @override
  void initState() {
    super.initState();
    // Initialize GPS after first frame and get location immediately if ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (AppInfo.enableGps) {
        await ref.read(gpsProvider.notifier).initialize();

        // If GPS is ready (service enabled & has permission), get location immediately
        final gpsState = ref.read(gpsProvider);
        if (gpsState.isReady) {
          _getCurrentLocation();
        }
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    final position = await ref.read(gpsProvider.notifier).getCurrentLocation();

    if (position != null) {
      if (widget.onLocationUpdated != null) {
        widget.onLocationUpdated!(position.latitude, position.longitude);
      }

      // Fetch address if reverse geocoding URL is configured
      if (GpsService.instance.isReverseGeoEnabled) {
        await ref.read(gpsProvider.notifier).getAddressFromCurrentPosition();
      }
    }
  }

  /// Open Google Maps with current location coordinates
  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch Google Maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    // Check if GPS is enabled in environment
    if (!AppInfo.enableGps) {
      return _buildDisabledCard(context, l10n, colorScheme);
    }

    final gpsState = ref.watch(gpsProvider);

    if (widget.compact) {
      return _buildCompactView(context, l10n, colorScheme, gpsState);
    }

    return _buildFullView(context, l10n, colorScheme, gpsState);
  }

  Widget _buildDisabledCard(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.location_off,
              color: colorScheme.outline,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.gpsDisabled,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                  ),
                  Text(
                    l10n.gpsDisabledDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactView(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    GpsState gpsState,
  ) {
    return InkWell(
      onTap: gpsState.isLoading ? null : _getCurrentLocation,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (gpsState.isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            else
              Icon(
                Icons.location_on,
                color: colorScheme.primary,
                size: 18,
              ),
            const SizedBox(width: 6),
            Text(
              gpsState.hasPosition
                  ? gpsState.coordinatesString
                  : l10n.myLocation,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullView(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    GpsState gpsState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Map icon - changes when location is available and opens Google Maps on tap
            GestureDetector(
              onTap: gpsState.hasPosition
                  ? () => _openGoogleMaps(
                        gpsState.latitude,
                        gpsState.longitude,
                      )
                  : null,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gpsState.hasPosition
                      ? colorScheme.primary
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  gpsState.hasPosition ? Icons.pin_drop : Icons.place,
                  color: gpsState.hasPosition
                      ? colorScheme.onPrimary
                      : colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Address or loading/error state
            Expanded(
              child: _buildAddressContent(context, l10n, colorScheme, gpsState),
            ),
            
            const SizedBox(width: 8),
            
            // Refresh button
            IconButton(
              onPressed: (gpsState.isLoading || gpsState.isLoadingAddress) 
                  ? null 
                  : _getCurrentLocation,
              icon: (gpsState.isLoading || gpsState.isLoadingAddress)
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      color: colorScheme.primary,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressContent(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    GpsState gpsState,
  ) {
    // Loading state
    if (gpsState.isLoading) {
      return Text(
        l10n.gettingLocation,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
      );
    }

    // Loading address state
    if (gpsState.isLoadingAddress) {
      return Text(
        l10n.gettingLocation,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
      );
    }

    // Error state
    if (gpsState.errorMessage != null) {
      return GestureDetector(
        onTap: () => ref.read(gpsProvider.notifier).openLocationSettings(),
        child: Text(
          gpsState.errorMessage!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    // Has address
    if (gpsState.hasAddress) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isAddressExpanded = !_isAddressExpanded;
          });
        },
        child: AnimatedCrossFade(
          firstChild: Text(
            gpsState.address!,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            gpsState.address!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          crossFadeState: _isAddressExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      );
    }

    // Has position but no address (reverse geocoding not configured)
    if (gpsState.hasPosition) {
      return Text(
        gpsState.coordinatesString,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
      );
    }

    // No location yet - prompt to get location
    return GestureDetector(
      onTap: _getCurrentLocation,
      child: Text(
        l10n.myLocation,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
      ),
    );
  }
}

/// Simple button widget to get and display current location
class GetLocationButton extends ConsumerWidget {
  /// Label for the button
  final String? label;

  /// Icon for the button
  final IconData icon;

  /// Callback when location is retrieved
  final Function(double lat, double lng)? onLocationRetrieved;

  const GetLocationButton({
    super.key,
    this.label,
    this.icon = Icons.location_on,
    this.onLocationRetrieved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final gpsState = ref.watch(gpsProvider);

    // If GPS is disabled, show disabled button
    if (!AppInfo.enableGps) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.location_off),
        label: Text(l10n.gpsDisabled),
      );
    }

    return FilledButton.tonal(
      onPressed: gpsState.isLoading
          ? null
          : () async {
              final position = await ref.read(gpsProvider.notifier).getCurrentLocation();
              if (position != null && onLocationRetrieved != null) {
                onLocationRetrieved!(position.latitude, position.longitude);
              }
            },
      child: gpsState.isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                if (label != null) ...[
                  const SizedBox(width: 6),
                  Text(label!),
                ],
              ],
            ),
    );
  }
}
