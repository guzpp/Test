import 'package:flutter/material.dart' show Colors;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../models/location.dart';

/// The layer responsible for talking to the Mapbox SDK. Wraps the
/// pieces the app needs — creating the annotation manager and
/// drawing markers — the same way LocationService wraps Supabase.
/// The rest of the app should call this class, never MapboxMap or
/// CircleAnnotationManager directly.
class MapboxService {
  MapboxMap? _map;
  CircleAnnotationManager? _circleManager;

  /// Call this once, from the MapWidget's onMapCreated callback.
  /// Nothing else in this class works until this has finished,
  /// because the annotation manager can only be created once a
  /// real native map exists.
  Future<void> attachMap(MapboxMap map) async {
    _map = map;
    _circleManager = await map.annotations.createCircleAnnotationManager();
  }

  /// Removes every marker currently drawn.
  Future<void> clearMarkers() async {
    await _circleManager?.deleteAll();
  }

  /// Draws one circle marker per Location, replacing whatever
  /// markers were on the map before.
  Future<void> showLocations(List<Location> locations) async {
    final manager = _circleManager;
    if (manager == null) return; // attachMap() hasn't finished yet

    await manager.deleteAll();

    await manager.createMulti([
      for (final location in locations)
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(location.longitude, location.latitude),
          ),
          circleRadius: 8.0,
          circleColor: Colors.redAccent.toARGB32(),
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 2.0,
        ),
    ]);
  }

  /// Smoothly animates the camera to a location. Not used by the
  /// visualization step yet, but handy once you add "tap a location
  /// in a list to jump to it on the map".
  Future<void> flyTo(Location location, {double zoom = 14}) async {
    final map = _map;
    if (map == null) return;

    await map.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(location.longitude, location.latitude),
        ),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 1200),
    );
  }
}