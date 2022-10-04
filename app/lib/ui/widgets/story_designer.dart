import 'dart:math' as math;
import 'dart:typed_data';

import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';

class StoryDesigner extends StatefulWidget {
  const StoryDesigner({
    Key? key,
    this.readMode = false,
    this.items,
  }) : super(key: key);

  final bool readMode;

  bool get asEditor {
    return !readMode;
  }

  final List<StoryItem>? items;

  @override
  StoryDesignerState createState() => StoryDesignerState();

  static void openReader(BuildContext context, Story story) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: StoryDesigner(
            readMode: true,
            items: story.items,
          ),
        ),
      ),
    );
  }
}

class StoryDesignerState extends State<StoryDesigner> {
  static GlobalKey previewContainer = GlobalKey();

  // ActiceItem
  StoryItem? _activeItem;

  // item initial position
  late Offset _initPos;

  // item current position
  late Offset _currentPos;

  // item current scale
  late double _currentScale;

  // item current rotation
  late double _currentRotation;

  // is item in action
  bool _inAction = false;

  // List of all editableitems
  final List<StoryItem> stackData = [];

  // is textfield shown
  bool isTextInput = false;

  bool isTextEdit = false;

  final _inputController = TextEditingController();

  String get currentText => _inputController.text;

  set currentText(String currentText) {
    _inputController.text = currentText;
  }

  // current textfield color
  Color currentColor = Colors.black;

  // current textfield colorpicker color
  Color pickerColor = Colors.black;

  // current textfield style
  int currentTextStyle = 0;

  // current textfield fontsize
  double currentFontSize = 26.0;

  List<Color> colorList = const [
    Colors.white,
    Colors.grey,
    Colors.black,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.pinkAccent,
    Colors.pink,
    Colors.purple,
  ];

  // current textfield fontfamily list
  List<String?> fontFamilyList = [
    null,
    'kiloji_p',
    'mamelon',
    'Lato',
    'Montserrat',
    'Lobster',
    'Spectral SC',
    'Dancing Script',
    'Oswald',
    'Turret Road',
    'Anton',
  ];

  // current textfield fontfamily
  int currentFontFamily = 0;

  // is activeitem moved to delete position
  bool isDeletePosition = false;

  // pointsの取得
  late Offset _position;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);

    if (widget.asEditor) {
      final messagingState = context.read<MessagingRootPageState>();
      messagingState.canSubmit.value = stackData.isNotEmpty;
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.items != null) {
      stackData.addAll(widget.items!);
      if (widget.asEditor) {
        final messagingState = context.read<MessagingRootPageState>();
        messagingState.canSubmit.value = stackData.isNotEmpty;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    final pages = _makeChunks(colorList, 5);
    for (final page in pages) {
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in page.asMap().entries)
            GestureDetector(
              onTap: () {
                setState(() {
                  currentColor = colorList[entry.key];
                });
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: entry.value,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // each item has size of 40 + space of 8
    const double pickerContainerSize = 40 * 6 + 8 * 5 - 20;

    return Scaffold(
      body: GestureDetector(
        onScaleStart: (details) {
          if (widget.readMode) {
            return;
          }
          if (_activeItem == null) {
            return;
          }

          _initPos = details.focalPoint;
          _currentPos = _activeItem!.position;
          _currentScale = _activeItem!.scale;
          _currentRotation = _activeItem!.rotation;
        },
        onScaleUpdate: (details) {
          if (widget.readMode) {
            return;
          }
          if (_activeItem == null) {
            return;
          }
          final delta = details.focalPoint - _initPos;
          final left = (delta.dx / screen.width) + _currentPos.dx;
          final top = (delta.dy / screen.height) + _currentPos.dy;

          if (_activeItem != null)
            setState(() {
              _activeItem!.position = Offset(left, top);
              _activeItem!.rotation = details.rotation + _currentRotation;
              _activeItem!.scale = details.scale * _currentScale;
            });
        },
        // tap位置取得
        onTapDown: _onTapDown,
        onTap: () => _onInputComplete(),
        child: Stack(
          children: [
            RepaintBoundary(
              key: previewContainer,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xffffffff).withOpacity(0.6),
                          const Color(0xffe7e7e7).withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  ...stackData.map(_buildItemWidget),
                  Visibility(
                    visible: isTextInput,
                    child: Container(
                      height: screen.height,
                      width: screen.width,
                      color: Colors.black.withOpacity(0.4),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              width: screen.width / 1.5,
                              padding: currentTextStyle != 0
                                  ? const EdgeInsets.only(
                                      left: 7,
                                      right: 7,
                                      top: 5,
                                      bottom: 5,
                                    )
                                  : EdgeInsets.zero,
                              decoration: currentTextStyle != 0
                                  ? BoxDecoration(
                                      color: currentTextStyle == 1
                                          ? Colors.black.withOpacity(1.0)
                                          : Colors.white.withOpacity(1.0),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                    )
                                  : null,
                              child: TextField(
                                controller: _inputController,
                                autofocus: true,
                                textAlign: TextAlign.center,
                                style: _getFont(currentFontFamily).copyWith(
                                  color: currentColor,
                                  fontSize: currentFontSize,
                                ),
                                cursorColor: currentColor,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white38,
                                ),
                                onSubmitted: (_) => _onInputComplete(),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 40,
                            child: Container(
                              width: screen.width,
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Container(
                                      padding: currentTextStyle == 0
                                          ? EdgeInsets.zero
                                          : const EdgeInsets.only(
                                              left: 7,
                                              right: 7,
                                              top: 5,
                                              bottom: 5,
                                            ),
                                      decoration: currentTextStyle != 0
                                          ? BoxDecoration(
                                              color: currentTextStyle == 1
                                                  ? Colors.black
                                                      .withOpacity(1.0)
                                                  : Colors.white
                                                      .withOpacity(1.0),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(4),
                                              ),
                                            )
                                          : null,
                                      child: Icon(Icons.auto_awesome,
                                          color: currentTextStyle != 2
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    onPressed: () {
                                      if (currentTextStyle < 2) {
                                        setState(() {
                                          currentTextStyle++;
                                        });
                                      } else {
                                        setState(() {
                                          currentTextStyle = 0;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: screen.height / 2 - 100,
                            left: -120,
                            child: Transform(
                              alignment: FractionalOffset.center,

                              // Rotate sliders by 90 degrees
                              transform: Matrix4.identity()
                                ..rotateZ(270 * math.pi / 180),

                              child: SizedBox(
                                width: 300,
                                child: Slider(
                                  value: currentFontSize,
                                  min: 14,
                                  max: 74,
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white.withOpacity(0.4),
                                  onChanged: (input) {
                                    setState(() {
                                      currentFontSize = input;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          AlignPositioned(
                            alignment: Alignment.topCenter,
                            dy: 100,
                            child: SizedBox(
                              height: 40,
                              width: pickerContainerSize,
                              child: ListView.separated(
                                itemCount: colorList.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                separatorBuilder: (_, __) => const Padding(
                                    padding: EdgeInsets.only(left: 8.0)),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        currentColor = colorList[index];
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: colorList[index],
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.0,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          AlignPositioned(
                            alignment: Alignment.bottomCenter,
                            dy: -50,
                            child: SizedBox(
                              width: pickerContainerSize,
                              height: 40,
                              child: ListView.separated(
                                  itemCount: fontFamilyList.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  separatorBuilder: (_, __) => const Padding(
                                      padding: EdgeInsets.only(left: 8.0)),
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          currentFontFamily = index;
                                        });
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: index == currentFontFamily
                                              ? Colors.white
                                              : Colors.black,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          index <= 2 ? 'あァ' : 'Aa',
                                          style: _getFont(index).copyWith(
                                            color: index == currentFontFamily
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: !isTextInput && _activeItem != null,
              child: Positioned(
                bottom: 50,
                child: SizedBox(
                  width: screen.width,
                  child: Center(
                    child: Container(
                      height: !isDeletePosition ? 60.0 : 100,
                      width: !isDeletePosition ? 60.0 : 100,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.all(
                          Radius.circular(!isDeletePosition ? 30 : 50),
                        ),
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: !isDeletePosition ? 30 : 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    final screen = MediaQuery.of(context).size;
    if (isTextInput) {
      return;
    }
    _position = Offset(details.globalPosition.dx / screen.width,
        details.globalPosition.dy / screen.height);
  }

  Widget _buildItemWidget(StoryItem e) {
    final screen = MediaQuery.of(context).size;
    // double centerHeightPosition = screen.height/2;
    // double centerWidthPosition = screen.width/2;

    late Widget widget;

    switch (e.type) {
      case StoryItemType.Text:
        if (e.textStyle == 0) {
          widget = GestureDetector(
            onTap: () {
              if (this.widget.readMode) {
                return;
              }

              _log('You tapped the text');
              setState(() {
                _activeItem = e;
                currentTextStyle = e.textStyle!;
                currentColor = e.color!;
                currentFontFamily = e.fontFamily!;
                currentFontSize = e.fontSize!;
                isTextInput = true;
                isTextEdit = true;
                currentText = e.value!;
              });
            },
            child: Text(
              e.value!,
              style: _getFont(e.fontFamily!).copyWith(
                color: e.color,
                fontSize: e.fontSize,
              ),
            ),
          );
        } else if (e.textStyle == 1) {
          widget = Container(
            padding:
                const EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(1.0),
              borderRadius: const BorderRadius.all(
                Radius.circular(4),
              ),
            ),
            child: Text(
              e.value!,
              style: _getFont(e.fontFamily!).copyWith(
                color: e.color,
                fontSize: e.fontSize,
              ),
            ),
          );
        } else if (e.textStyle == 2) {
          widget = Container(
            padding:
                const EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(1.0),
              borderRadius: const BorderRadius.all(
                Radius.circular(4),
              ),
            ),
            child: Text(
              e.value!,
              style: _getFont(e.fontFamily!).copyWith(
                color: e.color,
                fontSize: e.fontSize,
              ),
            ),
          );
        } else {
          widget = Text(
            e.value!,
            style: _getFont(e.fontFamily!).copyWith(
              color: e.color,
              fontSize: e.fontSize,
            ),
          );
        }
        break;
      case StoryItemType.Image:
        widget = Image(
          image: e.image!,
          width: e.scale * screen.width,
        );
    }

    final scale = e.type == StoryItemType.Image ? 1.0 : e.scale;
    final top = e.position.dy * screen.height;
    final itemWidget = Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: e.rotation,
        child: Listener(
          onPointerDown: (details) {
            if (_inAction || this.widget.readMode) {
              return;
            }

            _log('onPointerDown');
            _inAction = true;
            _activeItem = e;
            _initPos = details.position;
            _currentPos = e.position;
            _currentScale = e.scale;
            _currentRotation = e.rotation;
          },
          onPointerUp: (details) {
            if (this.widget.readMode) {
              return;
            }

            _inAction = false;
            _log('onPointerUp');
            _log(['e.position:', e.position.dx, e.position.dy]);
            if (isDeletePosition) {
              _log('Delete the Item');

              setState(() {
                stackData.removeAt(stackData.indexOf(e));
                _activeItem = null;
              });
            }

            setState(() {
              _activeItem = null;
            });
          },
          onPointerCancel: (details) {},
          onPointerMove: (details) {
            _log(['e.position:', e.position.dx, e.position.dy]);
            if (e.position.dy >= 0.7 &&
                e.position.dx >= 0.0 &&
                e.position.dx <= 1.0) {
              _log('Delete the Item');

              setState(() {
                isDeletePosition = true;
              });
            } else {
              setState(() {
                isDeletePosition = false;
              });
            }
          },
          child: widget,
        ),
      ),
    );

    return Positioned(
      top: top,
      left: e.position.dx * screen.width,
      child: itemWidget,
    );
  }

  TextStyle _getFont(int fontId) {
    if (fontId <= 2) {
      return TextStyle(fontFamily: fontFamilyList[fontId]);
    }
    return GoogleFonts.getFont(fontFamilyList[fontId]!);
  }

  void _log(Object object) {
    print(object);
  }

  void _onInputComplete() {
    if (widget.readMode) {
      return;
    }

    if (isTextEdit) {
      setState(() {});
      isTextEdit = false;
      isTextInput = false;

      final index = stackData.indexOf(_activeItem!);
      stackData[index] = _activeItem!.copyWith(
        value: currentText,
        color: currentColor,
        fontFamily: currentFontFamily,
        textStyle: currentTextStyle,
        fontSize: currentFontSize,
      );
      currentText = '';
      return;
    }

    isTextInput = !isTextInput;
    _activeItem = null;

    if (currentText.isNotEmpty) {
      final item = StoryItem(
        type: StoryItemType.Text,
        value: currentText,
        position: _position,
      )
        ..color = currentColor
        ..textStyle = currentTextStyle
        ..fontSize = currentFontSize
        ..fontFamily = currentFontFamily;
      stackData.add(item);
      currentText = '';
    }
    setState(() {});
  }
}

enum StoryItemType { Image, Text }

extension StoryItemTypeStringExtension on StoryItemType {
  static StoryItemType fromString(String value) {
    switch (value) {
      case 'Image':
        return StoryItemType.Image;
      case 'Text':
      default:
        return StoryItemType.Text;
    }
  }

  String asString() {
    switch (this) {
      case StoryItemType.Image:
        return 'Image';
      case StoryItemType.Text:
        return 'Text';
    }
  }
}

class StoryItem {
  StoryItem({
    required this.type,
    Offset? position,
    this.value,
    this.imageBytes,
    this.imageUrl,
  }) : position = position ?? Offset.zero;

  Offset position;
  double scale = 1.0;
  double rotation = 0.0;
  StoryItemType type;
  String? imageUrl;
  String? value;
  Uint8List? imageBytes;
  Color? color;
  int? textStyle;
  double? fontSize;
  int? fontFamily;

  ImageProvider? image;
  Size? imageSize;

  StoryItem copyWith({
    String? value,
    Color? color,
    int? fontFamily,
    int? textStyle,
    double? fontSize,
  }) {
    return StoryItem(
      type: type,
      value: value,
      imageBytes: imageBytes,
    )
      ..position = position
      ..scale = scale
      ..rotation = rotation
      ..color = color ?? this.color
      ..textStyle = textStyle ?? this.textStyle
      ..fontSize = fontSize ?? this.fontSize
      ..fontFamily = fontFamily ?? this.fontFamily
      ..image = image
      ..imageSize = imageSize
      ..imageUrl = imageUrl;
  }
}

Iterable<List<E>> _makeChunks<E>(List<E> list, int chunkSize) sync* {
  if (list.isEmpty) {
    yield [];
    return;
  }
  int skip = 0;
  while (skip < list.length) {
    final chunk = list.skip(skip).take(chunkSize);
    yield chunk.toList(growable: false);
    skip += chunkSize;
    if (chunk.length < chunkSize) {
      return;
    }
  }
}
