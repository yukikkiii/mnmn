import 'package:mnmn/ui/all.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static const RETRIEVE_PAGE_INDEX = 2;

  int _currentIndex = 1;
  final _tabs = <Widget>[];
  final _pageController = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();

    _setTabs();
  }

  @override
  void reassemble() {
    super.reassemble();

    setState(() {
      _setTabs();
    });
  }

  void _setTabs() {
    _tabs
      ..clear()
      ..addAll([
        MessageHistoryPage(),
        MessagingPage(),
        MessageRetrievePage(),
        KotodamaPage(),
      ]);
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      // スワイプでメッセージを綴る操作のためスワイプでドロワーを開かないように
      drawerEdgeDragWidth: 0.0,
      drawer: const AppDrawer(),
      appBar: _AppBar(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        iconSize: 30,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 4.0),
              child: SvgPicture.asset(
                _currentIndex == 0
                    ? 'asset/images/mail_on.svg'
                    : 'asset/images/mail.svg',
                width: 30,
              ),
            ),
            label: 'mnmn',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SvgPicture.asset(
                _currentIndex == 1
                    ? 'asset/images/pen_on.svg'
                    : 'asset/images/pen.svg',
                width: 25,
              ),
            ),
            label: '祈る',
          ),
          BottomNavigationBarItem(
            icon: Consumer<GlobalStore>(
              builder: (_, store, icon) {
                return Stack(
                  children: <Widget>[
                    icon!,
                    if (store.availableMessagesCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            store.availableMessagesCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  ],
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 2, right: 6),
                child: SvgPicture.asset(
                  _currentIndex == 2
                      ? 'asset/images/pin_on.svg'
                      : 'asset/images/pin.svg',
                  width: 22,
                ),
              ),
            ),
            label: '受取りに行く',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SvgPicture.asset(
                _currentIndex == 3
                    ? 'asset/images/kotodama_on.svg'
                    : 'asset/images/kotodama.svg',
                width: 25,
              ),
            ),
            label: 'コトダマ',
          ),
          // BottomNavigationBarItem(
          //   icon: Padding(
          //     padding: const EdgeInsets.only(top: 8),
          //     child: SvgPicture.asset(
          //       _currentIndex == 4
          //           ? 'asset/images/gate_on.svg'
          //           : 'asset/images/gate.svg',
          //       width: 30,
          //     ),
          //   ),
          //   label: 'イノリドコロ',
          // ),
        ],
        onTap: setCurrentIndex,
      ),
    );

    return ListTileTheme(
      child: scaffold,
    );
  }

  void setCurrentIndex(int index) {
    _pageController.jumpToPage(
      index,
    );
    setState(() {
      _currentIndex = index;
    });
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    this.title,
  });

  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: title == null
          ? Image.asset(
              'asset/images/logo.png',
              height: 20,
            )
          : Text(title!),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );

    return appBar;
  }
}
