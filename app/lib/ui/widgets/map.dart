import 'package:mnmn/ui/all.dart';

const _defaultZoom = 16.0;

extension LatLngExtension on LatLng {
  // Pseudo factory constructo
  static LatLng fromPoint(Map<String, dynamic> point) {
    return LatLng(
      (point['coordinates'] as List<dynamic>)[1] as double,
      (point['coordinates'] as List<dynamic>)[0] as double,
    );
  }
}

class MapWidget extends StatelessWidget {
  const MapWidget(
    this.latLng, {
    this.circleRadius,
    this.withPin = false,
    this.enableScroll = false,
    this.enableZoom = false,
    this.zoom,
  });

  final double? circleRadius;
  final bool enableScroll;
  final bool enableZoom;
  final LatLng latLng;
  final bool withPin;
  final double? zoom;

  @override
  Widget build(BuildContext context) {
    final map = GoogleMap(
      initialCameraPosition: CameraPosition(
        target: latLng,
        zoom: zoom ?? _defaultZoom,
      ),
      myLocationEnabled: true,
      // markers: {
      //   Marker(
      //     markerId: MarkerId(''),
      //     position: latLng,
      //   ),
      // },
      circles: {
        if (circleRadius != null)
          Circle(
            circleId: CircleId(''),
            center: latLng,
            radius: circleRadius!,
            fillColor: Colors.deepOrange.withOpacity(0.4),
            strokeWidth: 0,
          ),
      },
      scrollGesturesEnabled: enableScroll,
      zoomControlsEnabled: enableZoom,
      zoomGesturesEnabled: enableZoom,
    );

    return Stack(
      children: [
        map,
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white54,
          ),
          child: Text(
              '(${latLng.longitude.toStringAsFixed(6)}, ${latLng.latitude.toStringAsFixed(6)})'),
        ),
      ],
    );
  }
}
