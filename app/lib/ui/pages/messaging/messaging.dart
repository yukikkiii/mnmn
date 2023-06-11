import 'package:mnmn/ui/all.dart';

class MessagingPage extends StatefulWidget {
  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _MessagingPage();
  }
}

class _MessagingPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Callbacks
    final openEditor = useCallback((int pageOrder) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MessagingRootPage(pageOrder: pageOrder),
        ),
      );
    }, const []);

    final body = Stack(
      children: [
        Container(
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
        ),
        Center(
          child: Container(
            width: 250,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('asset/images/only-earth.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              flex: 2,
              child: SizedBox(
                height: 100,
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _EdgeSwipeIndicatorLeft(openEditor: openEditor),
                  const Text(
                    '誰かを、自分を、\n想って\n綴ってください',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.transparent,
                      fontSize: 18,
                      letterSpacing: 5,
                      height: 2,
                    ),
                  ),
                  _EdgeSwipeIndicatorRight(openEditor: openEditor),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  const Positioned(
                    bottom: 1,
                    right: 0,
                    child: Image(
                      width: 150,
                      image: AssetImage('asset/images/page-turn.png'),
                    ),
                  ),
                  Positioned(
                    bottom: 40.0,
                    right: 35.0,
                    child: IconButton(
                      icon: const Image(
                        image: AssetImage('asset/images/pen.png'),
                      ),
                      onPressed: () => openEditor(3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );

    return body;
  }
}

class _EdgeSwipeIndicatorLeft extends StatelessWidget {
  const _EdgeSwipeIndicatorLeft({
    required this.openEditor,
  });

  final Function(int) openEditor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const RotatedBox(
          quarterTurns: 2,
          child: Image(
            height: 250,
            image: AssetImage('asset/images/page-side.png'),
          ),
        ),
        IconButton(
          icon: const Image(
            width: 30,
            image: AssetImage('asset/images/person.png'),
          ),
          onPressed: () => openEditor(1),
        ),
      ],
    );
  }
}

class _EdgeSwipeIndicatorRight extends StatelessWidget {
  const _EdgeSwipeIndicatorRight({
    required this.openEditor,
  });

  final Function(int) openEditor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Image(
            width: 30,
            image: AssetImage('asset/images/pin.png'),
          ),
          onPressed: () => openEditor(2),
        ),
        const Image(
          height: 250,
          image: AssetImage('asset/images/page-side.png'),
        ),
      ],
    );
  }
}
