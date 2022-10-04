import 'dart:math' show max, min, sqrt;

import 'package:hexagon/hexagon.dart';
import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';

class AddressBookPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final store = context.read<GlobalStore>();
    final messagingState = context.read<MessagingRootPageState>();

    // States
    final update = context
        .select<GlobalStore, int>((store) => store.updateAddressBookCount);
    final isLoading = useState(false);
    final friends = useState(<dynamic>[]);

    // Callbacks
    final addFriend = useCallback(() {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => AddFriendPage()),
      );
    }, const []);
    final loadMessages = useCallback(() {
      isLoading.value = true;

      store.api.listFriends().then((res) {
        friends.value = res['items'] as List<dynamic>;
      }).whenComplete(() => isLoading.value = false);
    }, const []);
    final onSelectFriend = useCallback((User friend) {
      Future<void> f() async {
        final confirmation = await showDialog<bool>(
          context: context,
          builder: (_) => _FriendDialog(friend),
        );
        if (confirmation ?? false) {
          messagingState.draftMessage.to = friend;
          messagingState.goForward();
        }
      }

      f();
    }, const []);

    // Lifecycle
    useEffect(loadMessages, [update]);

    // UI
    final filteredFriends = friends.value;

    if (isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 60,
          ),
          child: _FriendList(
            filteredFriends
                .map((dynamic it) => User.fromMap(it as Map<String, dynamic>))
                .toList(),
            onSelectFriend: onSelectFriend,
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: addFriend,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, color: Colors.white),
                  pl4,
                  Text('ユーザー検索', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 40,
              right: 30,
              left: 30,
            ),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: friends.value
                  .map<Widget>(
                    (dynamic friend) {
                      final user = User.fromMap(friend as Map<String, dynamic>);
                      return GestureDetector(
                        onTap: () => onSelectFriend(user),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: uploadedImage(user.profileImage),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                user.name,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            pt16,
                          ],
                        ),
                      );
                    },
                  )
                  .intersperse(pl8)
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _FriendDialog extends StatelessWidget {
  const _FriendDialog(this.friend);

  final User friend;

  @override
  Widget build(BuildContext context) {
    final user = friend;
    var selfIntroduction = user.selfIntroduction;
    if (selfIntroduction.isEmpty) {
      selfIntroduction = '(自己紹介が設定されていません)';
    }

    return AppDialog(
      user: user,
      actions: TextButton(
        onPressed: () async {
          Navigator.pop(context, true);
        },
        child: const Text('この人へ送る'),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            selfIntroduction,
          ),
        ),
      ],
    );
  }
}

class _FriendList extends StatelessWidget {
  const _FriendList(
    this.friends, {
    required this.onSelectFriend,
  });

  final List<User> friends;
  final void Function(User) onSelectFriend;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => ConstrainedBox(
        constraints:
            BoxConstraints.tightFor(height: constraints.maxHeight - 120),
        child: _buildFriendsViewer(context, constraints.maxHeight - 120),
      ),
    );
  }

  Widget _buildFriendsViewer(BuildContext context, double height) {
    int i = 0;

    final count = friends.length;
    final colRows = getColRows(count);
    final cols = max(3, colRows[0]);
    final rows = max(3, colRows[1]);
    final width = 150.0 * cols;
    final container = Container();

    return InteractiveViewer(
      minScale: 1,
      constrained: false,
      child: SizedBox(
        width: max(MediaQuery.of(context).size.width, width),
        height: max(height, 150.0 * rows * sqrt(3) / 2),
        child: HexagonOffsetGrid.oddPointy(
          columns: cols,
          rows: rows,
          buildTile: (x, y) {
            if (!shouldRender(count, x, y)) {
              return HexagonWidgetBuilder(child: container);
            }

            i++;
            late Widget child;
            if (i > friends.length) {
              child = Column(
                children: const [
                  pt8,
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent,
                  ),
                ],
              );
            } else {
              final friend = friends[i - 1];
              child = GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelectFriend(friend),
                child: Column(
                  children: [
                    pt8,
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: uploadedImage(friend.profileImage),
                    ),
                    Text(
                      friend.name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return HexagonWidgetBuilder(
              child: child,
            );
          },
        ),
      ),
    );
  }

  List<int> getColRows(int count) {
    switch (count) {
      case 0:
        return [0, 0];
      case 1:
        return [1, 1];
      case 2:
        return [2, 1];
      case 3:
      case 4:
        return [2, 2];
      case 5:
      case 6:
        return [2, 3];
      case 7:
      case 8:
      case 9:
        return [3, 3];
      default:
        final cols = sqrt(count).ceil();
        return [cols, (count / cols).ceil()];
    }
  }

  bool shouldRender(int count, int x, int y) {
    if (count >= 9) {
      return true;
    }

    final v2 = y == 1 && x <= 1;
    final v3 = y == 2 && x == 1;
    final v4 = y == 0 && x == 1;

    if (count == 1) {
      return y == 1 && x == 1;
    } else if (count == 2) {
      return v2;
    } else if (count == 3) {
      return v2 || v3;
    } else if (count == 4) {
      return v2 || v3 || v4;
    } else if (count == 5) {
      return (y == 0 && x <= 1) || (y == 1 && x == 0) || (y == 2 && x <= 1);
    } else if (count == 6) {
      return (y == 0 && x <= 1) || v2 || (y == 2 && x <= 1);
    } else if (count == 7 || count == 8) {
      return y == 0 || v2 || y == 2;
    }
    return false;
  }
}
