import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';
import 'package:mnmn/ui/pages/contact_page.dart';

const statusLabels = {
  0: 'すべて',
  1: '下書き',
  2: '封済み',
  3: '送り済',
  4: '(お気に入り)', // 表示上では使用されない
  5: '未受信',
};
const statusLabelsReceiver = {
  2: '未開封',
  3: '受取済',
};

class MessageHistoryPage extends StatefulWidget {
  @override
  _MessageHistoryPageState createState() => _MessageHistoryPageState();
}

class _MessageHistoryPageState extends State<MessageHistoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelPadding: EdgeInsets.symmetric(horizontal: 16.0),
            indicatorPadding: EdgeInsets.symmetric(horizontal: 8.0),
            tabs: [
              Tab(text: '届いた手紙'),
              Tab(text: '綴った手紙'),
            ],
          ),
          pt24,
          Flexible(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MessagesList(
                  fetch: (context) =>
                      context.read<GlobalStore>().api.listMessages,
                  isSent: false,
                  showIcon: true,
                ),
                _MessagesList(
                  fetch: (context) =>
                      context.read<GlobalStore>().api.listMessagesSent,
                  isSent: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

typedef _FetchFunction = Future<Map<String, dynamic>> Function(
    [Map<String, dynamic> params]);

class _MessagesList extends HookWidget {
  const _MessagesList({
    required this.isSent,
    required this.fetch,
    this.showIcon = false,
  });

  final bool isSent;
  final _FetchFunction Function(BuildContext) fetch;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final store = context.read<GlobalStore>();

    useAutomaticKeepAlive();

    // Detect update
    final update = context.watch<GlobalStore>().messageHistoryCount;

    final statusFilter = useState(0);
    final isLoading = useState(true);
    final messages = useState(<dynamic>[]);
    final readMessage = useCallback((Map<String, dynamic> message) {
      if (message['received_at'] == null && showIcon) {
        // 未受信のメッセージ
        context.showTextSnackBar('このまにまにを開くには、受け取り場所まで移動して受信する必要があります。');
        return;
      }

      if (message['status'] == 1) {
        // 下書き
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => MessagingRootPage(
              draftMessage: DraftMessage()
                ..id = message['id'] as int?
                ..receiveRadius = message['receive_radius'] as int
                ..to = User.fromMap(message['to_user'] as Map<String, dynamic>)
                ..location = message['location'] == null
                    ? null
                    : LatLngExtension.fromPoint(
                        message['location'] as Map<String, dynamic>)
                ..note = message['note'] as String
                ..items =
                    Story.fromMap(message['data'] as Map<String, dynamic>).items
                ..isPraySite =
                    message['receive_radius'] == 0, // イノリドコロに設置したメッセージは 0 である
            ),
          ),
        );
        return;
      } else if (showIcon && message['status'] == 2) {
        // 未開封メッセージを開いたとき、ステータスを変更する
        store.api.openMessage(message['id'] as int);
        message['status'] = 3;
        messages.value = List<Map<String, dynamic>>.from(messages.value);
      }

      StoryDesigner.openReader(
        context,
        Story.fromMap(message['data'] as Map<String, dynamic>),
      );
    }, const []);

    // fetch message
    useEffect(() {
      isLoading.value = true;
      fetch(context)().then((res) {
        messages.value = res['items'] as List<dynamic>;
      }).whenComplete(() => isLoading.value = false);
    }, [update]);

    final messagesTab = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        for (final status in isSent ? const [0, 1, 2] : const [0, 2, 3, 5, 4])
          Expanded(
            child: OutlinedButton(
              onPressed: () => statusFilter.value = status,
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                side: statusFilter.value == status
                    ? MaterialStateProperty.all(
                        BorderSide(color: context.theme.accentColor))
                    : null,
                backgroundColor: statusFilter.value == status
                    ? MaterialStateProperty.all(context.theme.accentColor)
                    : null,
              ),
              child: showIcon && status == 4
                  ? Icon(
                      Icons.favorite,
                      size: context.textStyle.fontSize,
                      color: statusFilter.value == status
                          ? Colors.white
                          : Colors.grey[600],
                    )
                  : Text(
                      showIcon
                          ? (statusLabelsReceiver[status] ??
                              statusLabels[status]!)
                          : statusLabels[status]!,
                      style: TextStyle(
                        color: statusFilter.value == status
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                    ),
            ),
          ),
      ].intersperse(pl8).surroundWith(pl24),
    );
    if (isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (messages.value.isEmpty) {
      return Column(
        children: [
          messagesTab,
          Expanded(child: Container()),
          const Center(
            child: Text('まだまにまにがありません'),
          ),
          Expanded(child: Container()),
        ],
      );
    }

    print(showIcon);
    // ユーザーがブロックされていないか

    final filteredMessages = statusFilter.value == 0
        ? messages.value
        : messages.value.where((dynamic message) {
            if (statusFilter.value == 4) {
              // お気に入り
              // ignore: avoid_dynamic_calls
              return message['is_favorite'] as bool;
            } else if (statusFilter.value == 5) {
              // 未受信
              // ignore: avoid_dynamic_calls
              return message['received_at'] == null;
            } else if (showIcon &&
                statusFilter.value == 2 &&
                // ignore: avoid_dynamic_calls
                message['received_at'] == null) {
              // 届いた手紙: 未開封から未受信を除外
              return false;
            } else if (!showIcon && statusFilter.value == 2) {
              // 綴った手紙: 封済みに開封済みも表示
              return message['status'] == 2 || message['status'] == 3;
            }

            return message['status'] == statusFilter.value;
          }).toList();
    final messagesView = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: horizontalPadding,
      itemCount: filteredMessages.length,
      itemBuilder: (context, i) {
        final message = filteredMessages[i] as Map<String, dynamic>;
        final userMap =
            message[isSent ? 'to_user' : 'from_user'] as Map<String, dynamic>;
        final user = User.fromMap(userMap);
        final isFavorite = message['is_favorite'] as bool;
        final status = message['status'] as int;
        final isHighlighted = message['status'] == 1 ||
            showIcon && message['status'] == 2; // 下書きまたは未読
        final isNotReceived = message['received_at'] == null && showIcon;
        String statusLabelText = '';
        String text = '';
        if (showIcon) {
          statusLabelText = message['received_at'] == null
              ? '未受信'
              : statusLabelsReceiver[status]!;
          text = message['received_at'] == null
              ? '${message['receive_radius'] == 0 ? 'イノリドコロ' : '受け取り場所'}で受信してください'
              : (message['text'] as String? ?? '(本文がありません)');
        } else {
          statusLabelText = statusLabels[status]!;
          final note = message['note'] as String;
          text = note.isEmpty ? '(メモがありません)' : note;
        }

        final showRetrieveButton = showIcon && isNotReceived;
        final from_user_id = userMap['id'] as int;
        final list = store.currentUser?.blockUsers;
        // ユーザーがブロックされていないか
        if (list != null) {
          if (!isSent && list.contains(from_user_id)) {
            return SizedBox.shrink();
          }
        }
        final hideMessage = message['hide'] as bool?;
        // メッセージがオフにできるか
        if (hideMessage != null) {
          if (hideMessage) {
            return SizedBox.shrink();
          }
        }
        return ListTile(
          onTap: () => readMessage(message),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: uploadedImage(user.profileImage),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: isHighlighted ? TextStyles.bold : null,
                        ),
                      ),
                      pl12,
                      if (isNotReceived) ...[
                        Text(
                          statusLabelText,
                          style: TextStyles.accentBoldSmall,
                        ),
                        pl12,
                      ] else if (!showIcon && isHighlighted) ...[
                        const Icon(
                          Icons.edit_outlined,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        pl12,
                      ],
                    ],
                  ),
                ),
                Text(
                  DateFormat.yMd().format(
                    DateTimeExtension.parseLocal(
                        message['created_at'] as String),
                  ),
                  style: isHighlighted ? TextStyles.bold : null,
                ),
              ],
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Transform.translate(
                  offset: Offset(-8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                          style: isNotReceived
                              ? TextStyles.weakBoldLarge
                              : isHighlighted
                                  ? TextStyles.bold
                                      .copyWith(color: Colors.black)
                                  : null,
                        ),
                      ),
                      if (!showRetrieveButton && message['receive_radius'] != 0)
                        InkWell(
                          onTap: () {
                            // Make sure camera always moves
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => MessageMap(message: message),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'MAP',
                              style: TextStyles.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (showRetrieveButton && message['receive_radius'] != 0) ...[
                InkWell(
                  onTap: () {
                    final latLng = LatLngExtension.fromPoint(
                        message['location'] as Map<String, dynamic>);
                    // Make sure camera always moves
                    store.retrievePageCamera = LatLng(
                      latLng.latitude,
                      latLng.longitude,
                    );

                    final state =
                        store.getGlobalKey<HomePageState>().currentState!;
                    state.setCurrentIndex(HomePageState.RETRIEVE_PAGE_INDEX);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.pin_drop_outlined,
                      color: AppColors.accent,
                      size: 28,
                    ),
                  ),
                ),
              ],
              if (showIcon && !isNotReceived) ...[
                InkWell(
                  onTap: () async {
                    message['is_favorite'] = !isFavorite;
                    messages.value = List<dynamic>.from(messages.value);

                    showLoadingDialog(context);
                    try {
                      await (isFavorite
                          ? store.api.unfavoriteMessage
                          : store.api.favoriteMessage)(message['id'] as int);
                      context.showTextSnackBar(isFavorite
                          ? 'まにまにのお気に入り登録を解除しました。'
                          : 'まにまにをお気に入り登録しました。');
                    } finally {
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 28,
                    ),
                  ),
                ),
              ],
              InkWell(
                onTap: () async {
                  final String? selectedText = await showDialog<String>(
                      context: context,
                      builder: (_) {
                        return SimpleDialogSample(
                            message_id: message['id'] as int,
                            from_user:
                                message['from_user'] as Map<String, dynamic>);
                      });
                  print(selectedText);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.darkGrey,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          messagesTab,
          pt24,
          ListTileTheme(
            child: messagesView,
          ),
        ],
      ),
    );
  }
}

class SimpleDialogSample extends StatelessWidget {
  final int message_id;
  final Map<String, dynamic> from_user;
  SimpleDialogSample({required this.from_user, required this.message_id});

  @override
  Widget build(BuildContext context) {
    final store = context.read<GlobalStore>();
    // States
    return SimpleDialog(
      children: [
        SimpleDialogOption(
          child: const Text('このメッセージを通報する'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => ContactPage()),
            );
          },
        ),
        SimpleDialogOption(
          child: const Text('このユーザーをブロック'),
          onPressed: () async {
            final req = from_user;
            await store.api.blockUser(req);
            store.updateAddressBook();
            Navigator.pop(context, 'このユーザーをブロックしました');
          },
        ),
        SimpleDialogOption(
          child: const Text('このメッセージを非表示にする'),
          onPressed: () async {
            await store.api.hideMessage(message_id);
            store.updateAddressBook();
            Navigator.pop(context, 'このメッセージを非表示にしました');
          },
        )
      ],
    );
  }
}
