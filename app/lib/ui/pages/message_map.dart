import 'package:mnmn/ui/all.dart';

class MessageMap extends HookWidget {
  const MessageMap({required this.message});

  final Map<String, dynamic> message;

  @override
  Widget build(BuildContext context) {
    final radius = (message['receive_radius'] as num).toDouble();
    LatLng circleCenter;
    if (message['pray_site_id'] == null) {
      circleCenter = LatLngExtension.fromPoint(
          message['location'] as Map<String, dynamic>);
    } else {
      final praySite = context
          .read<GlobalStore>()
          .praySites
          .firstWhere((praySite) => praySite.id == message['pray_site_id']);
      circleCenter = praySite.latLng;
    }
    final circles = <Circle>{
      Circle(
        fillColor: Theme.of(context).accentColor.withOpacity(0.5),
        strokeWidth: 0,
        circleId: const CircleId('myCircle'),
        center: circleCenter,
        radius: radius,
      )
    };
    final body = Stack(
      children: [
        CustomMapMarkerFutureBuilder(
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            final mapMarker = snapshot.data!;
            return GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: circleCenter,
                zoom: 14,
              ),
              markers: <Marker>{
                Marker(
                  markerId: MarkerId(message['id'].toString()),
                  position: circleCenter,
                  icon: mapMarker[0],
                ),
              },
              circles: circles,
            );
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('MAP'),
      ),
      body: body,
    );
  }
}
