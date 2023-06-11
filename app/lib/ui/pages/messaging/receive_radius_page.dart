import 'package:mnmn/ui/all.dart';

class ReceiveRadiusPage extends HookWidget {
  const ReceiveRadiusPage();

  @override
  Widget build(BuildContext context) {
    final messagingState = context.read<MessagingRootPageState>();

    // States
    final receiveRadiusState = useState(
      messagingState.draftMessage.receiveRadius.toDouble(),
    );
    final receiveRadius = receiveRadiusState.value;

    // Set up map
    final location = messagingState.draftMessage.location!;
    final markers = {
      Marker(
        markerId: MarkerId(location.toString()),
        position: location,
      ),
    };
    final circles = <Circle>{
      Circle(
        fillColor: Theme.of(context).accentColor.withOpacity(0.5),
        strokeWidth: 0,
        circleId: const CircleId('myCircle'),
        center: location,
        radius: receiveRadius,
      )
    };

    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: CameraPosition(
            target: location,
            zoom: 15,
          ),
          markers: markers.toSet(),
          circles: circles,
        ),
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            height: 120,
            width: MediaQuery.of(context).size.width / 1.1,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, top: 10, right: 10, bottom: 5),
              child: Column(children: [
                Slider(
                  activeColor: Colors.deepPurple,
                  inactiveColor: Colors.deepPurpleAccent.withOpacity(0.4),
                  value: receiveRadius,
                  divisions: 20,
                  min: 100,
                  max: 500,
                  onChanged: (double value) {
                    receiveRadiusState.value = value;
                  },
                  label: '${receiveRadius.floor()}m',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '受け取り範囲: ${receiveRadius.floor()}m',
                      style: context.textStyle.copyWith(
                        fontSize: context.textStyle.fontSize! * 1.2,
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      child: const Text(
                        '決定',
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        messagingState.draftMessage.receiveRadius =
                            receiveRadius.toInt();
                        messagingState.goForward();
                      },
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}
