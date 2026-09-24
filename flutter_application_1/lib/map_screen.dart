import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: MapWidget(
        styleUri: MapboxStyles.MAPBOX_STREETS,
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(24.7453, 42.1354)), // lng, lat
          zoom: 12,
        ),
        onStyleLoadedListener: (data){
          debugPrint('MAP: style loaded');
        },
        onMapLoadErrorListener: (data){
          debugPrint('MAP ERROR: ${data.type} - ${data.message}');
        },
      ),
    );
  }
}