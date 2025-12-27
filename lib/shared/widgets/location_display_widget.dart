import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  void initState() {
    super.initState();
    // Initialize GPS after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AppInfo.enableGps) {
        ref.read(gpsProvider.notifier).initialize();
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    final l10n = context.l10n;
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

    if (mounted) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       position != null
      //           ? '${l10n.locationUpdated}: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}'
      //           : l10n.failedToGetLocation,
      //     ),
      //     behavior: SnackBarBehavior.floating,
      //     backgroundColor: position != null
      //         ? Theme.of(context).colorScheme.primary
      //         : Theme.of(context).colorScheme.error,
      //   ),
      // );
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.myLocation,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (gpsState.hasPosition)
                        Text(
                          gpsState.coordinatesString,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                        ),
                    ],
                  ),
                ),
                // Refresh button
                IconButton(
                  onPressed: gpsState.isLoading ? null : _getCurrentLocation,
                  icon: gpsState.isLoading
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

            // Location details
            if (gpsState.hasPosition) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              // Address section (only if reverse geocoding is configured)
              if (GpsService.instance.isReverseGeoEnabled) ...[
                _buildAddressSection(context, l10n, colorScheme, gpsState),
                const SizedBox(height: 12),
              ],
              
              // _buildInfoRow(
              //   context,
              //   icon: Icons.my_location,
              //   label: 'Latitude',
              //   value: gpsState.latitude.toStringAsFixed(6),
              // ),
              // const SizedBox(height: 8),
              // _buildInfoRow(
              //   context,
              //   icon: Icons.my_location,
              //   label: 'Longitude',
              //   value: gpsState.longitude.toStringAsFixed(6),
              // ),
              // const SizedBox(height: 8),
              _buildInfoRow(
                context,
                icon: Icons.radar,
                label: l10n.accuracy,
                value: '${gpsState.accuracy.toStringAsFixed(1)} m',
              ),
            ],

            // Error message
            if (gpsState.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        gpsState.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(gpsProvider.notifier).openLocationSettings();
                      },
                      child: Text(l10n.openSettings),
                    ),
                  ],
                ),
              ),
            ],

            // Get location button
            if (!gpsState.hasPosition && !gpsState.isLoading) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.location_searching),
                  label: Text(l10n.myLocation),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.outline,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    GpsState gpsState,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.place,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.address,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 2),
                if (gpsState.isLoadingAddress)
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.gettingLocation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                      ),
                    ],
                  )
                else if (gpsState.hasAddress)
                  Text(
                    gpsState.address!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  )
                else
                  Text(
                    l10n.notSet,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
              ],
            ),
          ),
          // Refresh address button
          if (!gpsState.isLoadingAddress)
            IconButton(
              onPressed: () {
                ref.read(gpsProvider.notifier).getAddressFromCurrentPosition();
              },
              icon: Icon(
                Icons.refresh,
                size: 18,
                color: colorScheme.primary,
              ),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
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
