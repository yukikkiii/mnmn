import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';

class MessageConfirmationPage extends HookWidget {
  const MessageConfirmationPage(this.scaffoldContext);

  final BuildContext scaffoldContext;

  @override
  Widget build(BuildContext context) {
    final messagingState = context.read<MessagingRootPageState>();

    // States
    final counterTextState = useState('');
    final noteController = useTextEditingController(
      text: messagingState.draftMessage.note,
    );

    // Callbacks
    final updateCounterText = useCallback(() {
      counterTextState.value = '${noteController.text.length}/100 文字';
    }, const []);
    noteController.addListener(updateCounterText);

    // Lifecycle
    useEffect(() {
      updateCounterText();
    }, []);

    final submit = useCallback(({bool asDraft = false}) {
      (() async {
        messagingState.draftMessage.note = noteController.text;

        try {
          showLoadingDialog(context);
          final message = messagingState.draftMessage;

          final store = context.read<GlobalStore>();
          final req = <String, dynamic>{
            'draft': asDraft,
            if (message.id != null) 'draft_id': message.id,
            'data': <String, dynamic>{
              'items': Story(message.items!).serializeItems(),
            },
            'to_user_id': message.to!.id,
            'lat': message.location?.latitude,
            'long': message.location?.longitude,
            'receive_radius': message.receiveRadius,
            'note': message.note,
          };
          if (message.isPraySite) {
            req['is_pray_site'] = message.isPraySite;
          }

          final res = await store.api.sendMessage(req);
          final success = (res['success'] as bool?) ?? false;
          if (!success) {
            throw Exception();
          }

          store.updateMessageHistory();
          if (asDraft) {
            Navigator.pop(context);
            Navigator.pop(context);
            context.showTextSnackBar('まにまにを下書き保存しました');
            return;
          }

          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                AppDialog(
                  actions: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: uploadedImage(
                          messagingState.draftMessage.to!.profileImage),
                    ),
                    pt8,
                    Text(
                      messagingState.draftMessage.to!.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    pt12,
                    const Text(
                      '送信しました。',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
          );

          store.updateMessageHistory();
          Navigator.pop(context, true);
        } catch (_) {
          context.showTextSnackBar('まにまにの送信に失敗しました。');
        }

        Navigator.pop(context);
      })();
    }, []);

    // Layout
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xffffffff).withOpacity(0.6),
            const Color(0xffe7e7e7).withOpacity(0.6),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: scrollablePaddingWithHorizontal,
        child: Column(
          children: [
            const Text('宛先'),
            pt8,
            CircleAvatar(
              radius: 40,
              backgroundImage:
              uploadedImage(messagingState.draftMessage.to!.profileImage),
            ),
            pt8,
            Text(
              messagingState.draftMessage.to!.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            pt48,
            const Text(
              'mnmnに封をします。',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            pt24,
            const Text(
              'どんな内容を送ったのか振り返るための\n'
                  '自分用のメモを残しましょう。',
              textAlign: TextAlign.center,
            ),
            pt24,
            TextField(
              controller: noteController,
              minLines: 7,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '自由にメモできます',
                fillColor: Colors.grey[300],
                counterText: counterTextState.value,
              ),
              maxLength: 100,
            ),
            pt32,
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(180, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => submit(asDraft: true),
              child: const Text(
                '下書き保存',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            pt12,
            TextButton(
              onPressed: submit,
              child: const Text(
                '封をして送信',
                style: TextStyles.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
