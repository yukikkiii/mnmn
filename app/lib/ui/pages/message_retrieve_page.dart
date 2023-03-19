import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';

class MessageRetrievePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final store = context.read<GlobalStore>();
    final mapCameraPosUpdate = context
        .select<GlobalStore, LatLng?>((store) => store.retrievePageCamera);
    final mapCameraPosState = useState<LatLng?>(null);
    final messagesAvailable =
        context.select<GlobalStore, List<Map<String, dynamic>>?>(
            (store) => store.messagesAvailable);
    final messagesAvailableState = useState(messagesAvailable ?? []);
    final hasLoadedState = useState(messagesAvailable != null);
    final retrieveMessage = useCallback((Map<String, dynamic> message) async {
      final messageId = message['id'] as int;
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final store = context.read<GlobalStore>();
      final res = await store.api.retrieveMessages(
        <String, dynamic>{
          'lat': position.latitude,
          'long': position.longitude,
          'id': messageId,
        },
      );

      if (!(res['success'] as bool? ?? false)) {
        showDialog<void>(
          context: context,
          builder: (_) => AppDialog(
            user: User.fromMap(message['from_user'] as Map<String, dynamic>),
            actions: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            children: const [
              Text(
                'ここでは受け取りができません。',
                style: TextStyles.accentBold,
              ),
              pt8,
              Text(
                '受け取り場所まで移動してください。',
                style: TextStyles.weak,
              ),
            ],
          ),
        );
        return;
      }

      showDialog<void>(
        context: context,
        builder: (_) => AppDialog(
          user: User.fromMap(message['from_user'] as Map<String, dynamic>),
          actions: TextButton(
            onPressed: () {
              // 未開封メッセージを開いたとき、ステータスを変更する
              store.api.openMessage(message['id'] as int);
              message['status'] = 3;
              store.messagesAvailable =
                  List<Map<String, dynamic>>.from(messagesAvailable!);

              Navigator.pop(context);
              StoryDesigner.openReader(
                context,
                Story.fromMap(message['data'] as Map<String, dynamic>),
              );
            },
            child: const Text('読む'),
          ),
          children: const [
            Text('受け取りが完了しました。'),
          ],
        ),
      );

      messagesAvailableState.value = messagesAvailableState.value
          .where((message) => message['id'] as int != messageId)
          .toList();
      store.availableMessagesCount -= 1;
      store.updateMessageHistory();
    }, const []);
    
    // Lifecycle
    useAutomaticKeepAlive();
    print('ok3');
    useEffect(() {
      hasLoadedState.value = messagesAvailable != null;
      messagesAvailableState.value = messagesAvailable ?? [];
      return null;
    }, [messagesAvailable]);
    useEffect(() {
      if (store.retrievePageCamera != null) {
        mapCameraPosState.value = store.retrievePageCamera;
      }
      return null;
    }, [mapCameraPosUpdate]);
    // Layout
    if (!hasLoadedState.value) {
    
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    print(messagesAvailableState.value);
    final praySiteIds = <int>{};
    final locations = [
      ...messagesAvailableState.value.map(
        (message) => UserLocation.fromMap(<String, dynamic>{
          'id': message['id'],
          'point': message['location'] != null
              ? message['location'] as Map<String, dynamic>
              : "",
          'radius': message['receive_radius'],
        }),
      ),
    ].where(
      (location) {
        // 重複するイノリドコロを削除
        print("1");
         print(location.isPraySite);
        if (!location.isPraySite) {
          return true;
        }
        final added = praySiteIds.add(location.id);
       
        return added;
      },
    ).toList();
    return Stack(
      children: [
        LocationPickerMap(
          locations: locations,
          initialCameraPosition: mapCameraPosState.value ??
              context.read<GlobalStore>().currentLocation,
          onSelectLocation: (location) async {
          
            if (location.isPraySite) {
              if (store.praySiteMessages == 0) {
                context.showTextSnackBar('イノリドコロで受け取れるまにまにがありません');
                return;
              }

              final position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );
              final res = await store.api.retrieveMessages(<String, dynamic>{
                'lat': position.latitude,
                'long': position.longitude,
                'pray_site_id': location.id,
              });
              
              if (!(res['success'] as bool? ?? false)) {
                context.showTextSnackBar('まにまにを受け取るには、イノリドコロに移動する必要があります。');
                return;
              }

              context.showTextSnackBar('${res['count']} 件のまにまにを受け取りました。');
              store.updateMessageHistory();
              store.praySiteMessages = 0;
              store.availableMessagesCount =
                  store.availableMessagesCount - (res['count'] as int);
              return;
            }

            final message = messagesAvailableState.value
                .singleWhere((message) => message['id'] == location.id);
            retrieveMessage(message);
          },
        ),
        Selector<GlobalStore, int>(
          selector: (_, store) { 
          return store.praySiteMessages;
          },
          builder: (_, praySiteMessages, __) {
          
            if (praySiteMessages > 0) {
              return MapOverlayText(
                'イノリドコロで受け取れるまにまにが$praySiteMessages件あります',
              );
            } else if (locations.isEmpty) {
              return MapOverlayText(
                '受け取れるまにまにがありません',
                color: Colors.red.withOpacity(0.75),
              );
            }

            return Container();
          },
        )
      ],
    );
  }
}
