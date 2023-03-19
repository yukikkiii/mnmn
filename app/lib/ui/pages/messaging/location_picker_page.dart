import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';

class LocationPickerPage extends HookWidget {
  const LocationPickerPage(this.updater);

  final ValueNotifier<int> updater;

  @override
  Widget build(BuildContext context) {
    final store = context.read<GlobalStore>();
    final messagingState = context.read<MessagingRootPageState>();

    // States
    final markerAtInitialCameraPosition =
        useState(messagingState.draftMessage.location != null);
    final locationsState = useState<List<UserLocation>?>(null);
    final locations = locationsState.value;

    // Lifecycle
    useEffect(() {
      if (messagingState.draftMessage.isPraySite) {
        messagingState.draftMessage.isPraySite = false;
      }

      // Fetch locations
      Future<void> f() async {
        locationsState.value =
            ((await store.api.listMyLocations())['items'] as List<dynamic>)
                .whereType<Map<String, dynamic>>()
                .toList()
                .map((rawLocation) => UserLocation.fromMap(rawLocation))
                .toList();
      }

      f();
    }, const []);

    return locations == null
        ? const Center(child: CircularProgressIndicator())
        : locations.isEmpty
            ? const Center(
                child: Text(
                  'まにまにを設置できる場所がありません。まにまにを設置するには、位置情報機能を有効化しアプリを再起動してください。',
                ),
              )
            : Stack(
                children: [
                  LocationPickerMap(
                    pickRadius: 100,
                    locations: {
                      ...locations,
                    },
                    markerAtInitialCameraPosition:
                        markerAtInitialCameraPosition.value,
                    initialCameraPosition: messagingState.draftMessage.location,
                    onSelectLocation: (location) {
                      messagingState.draftMessage.location = location.latLng;
                      messagingState.draftMessage.isPraySite = false;
                      updater.value++;
                      markerAtInitialCameraPosition.value = true;
                    },
                  ),
                  const MapOverlayText(
                    '赤い円の内側に設置してください',
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 32),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            AppColors.praySite.withOpacity(0.8),
                          ),
                        ),
                        onPressed: () {
                          messagingState.draftMessage.isPraySite = true;
                          messagingState.draftMessage.location = null;
                          messagingState.goForward();
                        },
                        child: const Text(
                          'イノリドコロに設置する',
                        ),
                      ),
                    ),
                  ),
                ],
              );
  }
}
