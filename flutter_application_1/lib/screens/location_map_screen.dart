import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../models/location.dart';
import '../repositories/location_repository.dart';
import '../services/mapbox_service.dart';

/// Ties layers 2 and 3 together: fetches the saved locations from
/// Supabase (via LocationRepository) and draws them on the map (via
/// MapboxService), as soon as both the map and the data are ready.
class LocationsMapScreen extends StatefulWidget {
  const LocationsMapScreen({super.key});

  @override
  State<LocationsMapScreen> createState() => _LocationsMapScreenState();
}

class _LocationsMapScreenState extends State<LocationsMapScreen> {
  final LocationRepository _repository = LocationRepository();
  final MapboxService _mapboxService = MapboxService();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Locations')),
      body: Stack(
        children: [
          MapWidget(
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(24.7453, 42.1354)), // Plovdiv
              zoom: 6,
            ),
            onMapCreated: _onMapCreated,
          ),
          if (_isLoading)
            const Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _ErrorBanner(
                message: _errorMessage!,
                onRetry: _loadLocations,
              ),
            ),
        ],
      ),
    );
  }

  /// Runs once, the moment MapWidget finishes creating the underlying
  /// native map. This is the earliest point MapboxService has an
  /// actual map to draw on — so the fetch is triggered from here,
  /// not from initState().
  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    await _mapboxService.attachMap(mapboxMap);
    await _loadLocations();
  }

  /// Fetches from Supabase through the repository, then hands the
  /// result to MapboxService to draw as markers.
  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Location> locations = await _repository.getAllLocations();
      await _mapboxService.showLocations(locations);
    } on LocationFetchException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      // mounted check: the screen could have been closed while the
      // fetch was still in flight, in which case calling setState
      // would throw.
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.red)),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}