import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaJornadasWidget extends StatelessWidget {
  final LatLng initialCenter;
  final double zoom;
  final List<Marker> markers;
  final MapController? mapController;
  final void Function(TapPosition, LatLng)? onTap;
  final void Function(MapCamera, bool)? onPositionChanged;

  const MapaJornadasWidget({
    super.key,
    required this.initialCenter,
    this.zoom = 14.0,
    this.markers = const [],
    this.mapController,
    this.onTap,
    this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: zoom,
        onTap: onTap,
        onPositionChanged: onPositionChanged,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.causapp.causapp',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
