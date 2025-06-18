import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapboxMap mapboxMap;

  final CameraOptions _cameraOptions = CameraOptions(
    center: Point(coordinates: Position(-52.3299, 4.9224)),
    zoom: 12.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        mapOptions: MapOptions(
          pixelRatio: MediaQuery.of(context).devicePixelRatio,
        ),
        cameraOptions: _cameraOptions,
        textureView: true,
        onMapCreated: _onMapCreated,
        styleUri: MapboxStyles.MAPBOX_STREETS,
      ),
    );
  }

  late PointAnnotationManager _pointAnnotationManager;

  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    _pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();

  }

  }
