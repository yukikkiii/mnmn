import 'dart:math' show asin, cos, sqrt;

import 'package:custom_info_window/custom_info_window.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';

class LocationPickerMap extends HookWidget {
  const LocationPickerMap({
    required this.locations,
    this.onSelectLocation,
    this.markerAtInitialCameraPosition = false,
    this.initialCameraPosition,
    this.selectedLocation,
    this.pickRadius,
  });

  final Iterable<UserLocation> locations;
  final Function(UserLocation)? onSelectLocation;
  final bool markerAtInitialCameraPosition;
  final LatLng? initialCameraPosition;
  final UserLocation? selectedLocation;
  final int? pickRadius;

  @override
  Widget build(BuildContext context) {
    final store = context.read<GlobalStore>();
    var locations = [
      ...this.locations,
    ];

    // イノリドコロと通常の設置場所が重なっているとき常にイノリドコロが優先されるように
    // this.locations の上に書かなければならない (firstWhere)
    locations = [...store.praySites, ...locations];

    final customInfoWindowController =
        useState<CustomInfoWindowController?>(null);
    useEffect(
      () {
        customInfoWindowController.value = CustomInfoWindowController();
        return () {
          customInfoWindowController.value!.dispose();
        };
      },
      [],
    );

    final mapControllerState = useState<GoogleMapController?>(null);

    useEffect(() {
      if (mapControllerState.value == null) {
        return;
      }
      if (this.initialCameraPosition != null) {
        mapControllerState.value!.moveCamera(
          CameraUpdate.newLatLng(this.initialCameraPosition!),
        );
      }
    }, [this.initialCameraPosition]);

    LatLng initialCameraPosition = this.initialCameraPosition ??
        context.read<GlobalStore>().currentLocation ??
        defaultLocation;
    if (this.initialCameraPosition == null && locations.isNotEmpty) {
      if (selectedLocation == null) {
        initialCameraPosition = this.locations.first.latLng;
      } else {
        try {
          initialCameraPosition = locations
              .firstWhere(
                (location) => location.id == selectedLocation!.id,
              )
              .latLng;
        } catch (_) {}
      }
    }

    final showInfoWindow = useCallback(
      (LatLng latLng) {
        final future = placemarkFromCoordinates(
          latLng.latitude,
          latLng.longitude,
        );

        customInfoWindowController.value!.addInfoWindow!(
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<List<Placemark>>(
                          future: future,
                          builder: (_, snapshot) {
                            if (snapshot.hasData) {
                              final placemark = snapshot.data!.first;
                              return Text((placemark.subLocality == ''
                                      ? [
                                          placemark.administrativeArea ?? '',
                                          placemark.locality ?? '',
                                        ]
                                      : [
                                          placemark.locality,
                                          placemark.subLocality
                                        ])
                                  .join(''));
                            }
                            return Container();
                          },
                        ),
                      ],
                    ),
                  ),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              const CustomPaint(
                size: Size(20, 20),
                painter: TrianglePainter(
                  strokeColor: Colors.white54,
                  strokeWidth: 10,
                  paintingStyle: PaintingStyle.fill,
                ),
              ),
            ],
          ),
          latLng,
        );
      },
      const [],
    );

    final circleLocations = <UserLocation>[];
    if (pickRadius == null) {
      circleLocations.addAll(
        locations.where(
          (location) => location.radius != null,
        ),
      );
    } else {
      circleLocations.addAll(
        locations.map(
          (location) => location.copyWith(radius: pickRadius),
        ),
      );
    }

    final circles = circleLocations
        .map(
          (location) => Circle(
            fillColor: location.isPraySite
                ? AppColors.praySite.withOpacity(0.5)
                : Theme.of(context).accentColor.withOpacity(0.5),
            strokeWidth: 0,
            circleId: CircleId(location.id.toString()),
            center: location.latLng,
            radius: location.radius!.toDouble(),
          ),
        )
        .toSet();

    return CustomMapMarkerFutureBuilder(
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final mapMarker = snapshot.data!;
        return Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) {
                mapControllerState.value = controller;
                customInfoWindowController.value!.googleMapController =
                    controller;
              },
              onCameraMove: (position) {
                customInfoWindowController.value!.onCameraMove!();
              },
              initialCameraPosition: CameraPosition(
                target: initialCameraPosition,
                zoom: 17.5,
              ),
              markers: pickRadius == null
                  ? locations.map((location) {
                      return Marker(
                        markerId: MarkerId(location.id.toString()),
                        position: location.latLng,
                        onTap: () {
                          customInfoWindowController.value!.hideInfoWindow!();

                          if (onSelectLocation != null) {
                            onSelectLocation!(location);
                          }
                        },
                        icon: location.isPraySite ? mapMarker[1] : mapMarker[0],
                      );
                    }).toSet()
                  : <Marker>{
                      if (markerAtInitialCameraPosition)
                        Marker(
                          markerId: const MarkerId('-1'),
                          position: initialCameraPosition,
                          onTap: () {
                            showInfoWindow(initialCameraPosition);
                          },
                          icon: mapMarker[0],
                        ),
                      ...locations
                          .where((location) => location.isPraySite)
                          .map((location) => Marker(
                                markerId: MarkerId(location.id.toString()),
                                position: location.latLng,
                                icon: mapMarker[1],
                              )),
                    },
              onTap: (latLng) async {
                if (pickRadius == null) {
                  return;
                }

                try {
                  final location = circleLocations.firstWhere((circle) {
                    if (circle.isPraySite) {
                      return false;
                    }

                    final isInsideCircle =
                        _distanceBetween(latLng, circle.latLng) <= pickRadius!;
                    return isInsideCircle;
                  }).copyWith(
                    latLng: latLng,
                  );
                  onSelectLocation!(location);
                  customInfoWindowController.value!.hideInfoWindow!();
                } catch (_) {}
              },
              circles: circles,
            ),
            CustomInfoWindow(
              controller: customInfoWindowController.value!,
              height: 75,
              width: 150,
              offset: 50,
            ),
          ],
        );
      },
    );
  }
}

// This algorithm is based on https://stackoverflow.com/questions/54138750/total-distance-calculation-from-latlng-list
double _distanceBetween(LatLng a, LatLng b) {
  const ONE_DEGREE_IN_RADIAN = 0.017453292519943295;
  final temp = 0.5 -
      cos((b.latitude - a.latitude) * ONE_DEGREE_IN_RADIAN) / 2 +
      cos(a.latitude * ONE_DEGREE_IN_RADIAN) *
          cos(b.latitude * ONE_DEGREE_IN_RADIAN) *
          (1 - cos((b.longitude - a.longitude) * ONE_DEGREE_IN_RADIAN)) /
          2;
  return 12742 * 1000 * asin(sqrt(temp));
}

// Based on https://stackoverflow.com/questions/56930636/flutter-button-with-custom-shape-triangle
class TrianglePainter extends CustomPainter {
  const TrianglePainter({
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
    this.paintingStyle = PaintingStyle.stroke,
  });

  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(x / 2, y)
      ..lineTo(x, 0)
      ..lineTo(0, 0);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
