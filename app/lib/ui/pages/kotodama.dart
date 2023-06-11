import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:mnmn/ui/all.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

final _kotodamaKey = GlobalKey();

class KotodamaPage extends StatefulWidget {
  @override
  _KotodamaPageState createState() => _KotodamaPageState();
}

class _KotodamaPageState extends State<KotodamaPage> {
  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Expanded(
          flex: 6,
          child: Container(),
        ),
        Expanded(
          flex: 2,
          child: InkResponse(
            onTap: () {
              _showMnmnHintDialog(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.solidQuestionCircle,
                  size: 18,
                  color: Theme.of(context).primaryColorLight,
                ),
                pl4,
                Text(
                  'コトダマとは',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Stack(
      children: [
        Align(
          alignment: const Alignment(0.3, -0.4),
          child: RepaintBoundary(
            key: _kotodamaKey,
            child: SizedBox(
              width: 360,
              height: 360,
              child: Center(child: AnimationDemo()),
            ),
          ),
        ),
        body,
      ],
    );
  }

  Future<void> _showMnmnHintDialog(BuildContext context) {
    return Navigator.push(
      context,
      ModalOverlay(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 1.9,
                width: MediaQuery.of(context).size.width / 1.3,
                padding: const EdgeInsets.only(
                  top: 30,
                  right: 30,
                  left: 30,
                  bottom: 30,
                ),
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: BubbleBorder(
                    usePadding: true,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'コトダマとは',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          pt32,
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                'コトダマは、あなたが送ったmnmmの数をはじめ、世界中で送られたmnmnや、'
                                '天候、時間、移動した距離などによって自動生成されるあなただけのカミサマです。'
                                'mnmnが綴る、想いと空間を可視化したもので、全てが異なるかたちをしています。'
                                '時間と共に変化するため、同じカタチが生じることはありません。'
                                '変化と共に、想いをのせてmnmnしてください。',
                                style: TextStyle(
                                  height: 1.9,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                        ),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        isAndroidBackEnable: true,
      ),
    );
  }
}

class TwitterShareWidget extends StatelessWidget {
  const TwitterShareWidget(
      {this.text = '',
      this.url = '',
      this.hashtags = const [],
      this.via = '',
      this.related = ''});

  final String text;
  final String url;
  final List<String> hashtags;
  final String via;
  final String related;

  Future<void> _tweet() async {
    final tweetQuery = {
      'text': text,
      'url': url,
      'hashtags': hashtags.join(','),
      'via': via,
      'related': related,
    };

    final Uri tweetScheme =
        Uri(scheme: 'twitter', host: 'post', queryParameters: tweetQuery);

    final Uri tweetIntentUrl =
        Uri.https('twitter.com', '/intent/tweet', tweetQuery);

    await canLaunch(tweetScheme.toString())
        ? await launch(tweetScheme.toString())
        : await launch(tweetIntentUrl.toString());
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const FaIcon(FontAwesomeIcons.twitter),
      iconSize: 30,
      color: Theme.of(context).primaryColorLight,
      onPressed: () {
        _tweet();
      },
    );
  }
}

class AnimationDemo extends StatefulWidget {
  const AnimationDemo({Key? key}) : super(key: key);

  @override
  _AnimationDemoState createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo> {
  static const _animationDuration = Duration(seconds: 2, milliseconds: 500);

  double _width = 50;
  double _height = 50;
  Color _color = Colors.transparent;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(8);
  late Timer _timer;
  double _rotation = 0;
  double _x = 0;
  double _y = 0;

  @override
  void initState() {
    super.initState();

    animate();
    _timer = Timer.periodic(
      _animationDuration,
      (_) {
        setState(animate);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();

    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: AnimatedContainer(
            // Use the properties stored in the State class.
            width: _width,
            height: _height,
            transform: Matrix4.rotationZ(_rotation),
            decoration: BoxDecoration(
              color: _color,
              borderRadius: _borderRadius,
            ),
            duration: _animationDuration,
            curve: Curves.linear,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Image.asset(
            'asset/images/kotodama_base.png',
            height: 300,
          ),
        ),
      ],
    );
  }

  void animate() {
    // Create a random number generator.
    final random = Random();

    // Generate a random width and height.
    _width = (random.nextInt(100).toDouble() + 200) / 5 * 5;
    _height = (random.nextInt(100).toDouble() + 200) / 5 * 5;

    const colors = [
      Color(0xffffffba),
      Color(0xffbaffc9),
      Color(0xffbae1ff),
      Color(0xFFE0BBE4),
      Color(0xFF957DAD),
      Color(0xFFD291BC),
      Color(0xFFFEC8D8),
      Color(0xFFFFDFD3),
    ];
    _color = colors[random.nextInt(colors.length)].withAlpha(64);
    _rotation = random.nextDouble() * 2 * pi * 0.05;

    _x = random.nextDouble() * 2 - 1;
    _y = random.nextDouble() * 2 - 1;

    // Generate a random border radius.
    _borderRadius = BorderRadius.only(
      topLeft: Radius.circular((50 + random.nextInt(50).toDouble()) * 5),
      topRight: Radius.circular((50 + random.nextInt(50).toDouble()) * 5),
      bottomLeft: Radius.circular((50 + random.nextInt(50).toDouble()) * 5),
      bottomRight: Radius.circular((50 + random.nextInt(50).toDouble()) * 5),
    );
  }
}
