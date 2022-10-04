import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mnmn/ui/all.dart';

class CustomMapMarkerFutureBuilder extends HookWidget {
  CustomMapMarkerFutureBuilder({
    required this.builder,
  });

  final AsyncWidgetBuilder<List<BitmapDescriptor>> builder;

  Future<Uint8List> resizeImageAsset(
    String path,
    int height,
    int width,
  ) async {
    final ByteData byteData = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetHeight: height,
      targetWidth: width,
    );
    final ui.FrameInfo uiFI = await codec.getNextFrame();
    return (await uiFI.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // final _globalKey = GlobalKey();
  // // RepaintBoundary の key を渡す
  // Future<Uint8List> convertWidgetToImage(GlobalKey widgetGlobalKey) async {
  //   // RenderObjectを取得
  //   RenderRepaintBoundary? boundary = widgetGlobalKey.currentContext!
  //       .findRenderObject() as RenderRepaintBoundary?;
  //   // RenderObject を dart:ui の Image に変換する
  //   ui.Image image = await boundary!.toImage();
  //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   return byteData!.buffer.asUint8List();
  // }

  GlobalKey _globalKey = GlobalKey(); // 1. GlobalKey生成

  // 4. ボタンが押された際の処理
  // Future<BitmapDescriptor> _exportToImage() async {
  //   // 現在描画されているWidgetを取得する
  //   RenderRepaintBoundary? boundary =
  //       _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
  //
  //   // 取得したWidgetからイメージファイルをキャプチャする
  //   ui.Image image = await boundary!.toImage(
  //     pixelRatio: 3.0,
  //   );
  //
  //   // 以下はお好みで
  //   // PNG形式化
  //   ByteData? byteData = await image.toByteData(
  //     format: ui.ImageByteFormat.png,
  //   );
  //   // バイトデータ化
  //   final _pngBytes = byteData!.buffer.asUint8List();
  //   // BASE64形式化
  //   final _base64 = base64Encode(_pngBytes);
  //   print(_base64);
  //
  //   return resizeImageAsset(_base64, 163, 129)
  //       .then((imageBytes) => BitmapDescriptor.fromBytes(imageBytes));
  // }

  @override
  Widget build(BuildContext context) {
    final mapMarkerFuture = useMemoized(
      // () async {
      //   RepaintBoundary(
      //     key: _globalKey,
      //     child: Stack(
      //       children: [
      //         Image.asset('asset/images/map_pin.png'),
      //         Image.asset('asset/images/pen.png'),
      //       ],
      //     ),
      //   );
      //   // 現在描画されているWidgetを取得する
      //   RenderRepaintBoundary? boundary = _globalKey.currentContext!
      //       .findRenderObject() as RenderRepaintBoundary?;

      //   // 取得したWidgetからイメージファイルをキャプチャする
      //   final ui.Image image = await boundary!.toImage(
      //     pixelRatio: 3.0,
      //   );

      //   // 以下はお好みで
      //   // PNG形式化
      //   final ByteData? byteData = await image.toByteData(
      //     format: ui.ImageByteFormat.png,
      //   );
      //   // バイトデータ化
      //   final _pngBytes = byteData!.buffer.asUint8List();
      //   // BASE64形式化
      //   final _base64 = base64Encode(_pngBytes);
      //   print(_base64);

      //   return resizeImageAsset(_base64, 163, 129)
      //       .then((imageBytes) => BitmapDescriptor.fromBytes(imageBytes));
      () {
        return Future.wait(
          [
            resizeImageAsset(
              'asset/images/map_pin.png',
              163,
              129,
            ).then(
              (imageBytes) => BitmapDescriptor.fromBytes(imageBytes),
            ),
            resizeImageAsset(
              'asset/images/pray_place.png',
              163,
              129,
            ).then(
              (imageBytes) => BitmapDescriptor.fromBytes(imageBytes),
            ),
          ],
        );
      },
      const [],
    );

    return FutureBuilder<List<BitmapDescriptor>>(
      future: mapMarkerFuture,
      builder: builder,
    );
  }
}
