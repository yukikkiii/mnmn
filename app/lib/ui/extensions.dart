import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension BuildContextExtension on BuildContext {
  Color get primaryColor {
    return Theme.of(this).primaryColor;
  }

  TextStyle get primaryColorTextStyle {
    return TextStyle(color: primaryColor);
  }

  ThemeData get theme {
    return Theme.of(this);
  }

  TextTheme get textTheme {
    return theme.textTheme;
  }

  TextStyle get textStyle {
    return textTheme.bodyText2!;
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showTextSnackBar(
      String text) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}

extension ColorHexExtension on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension IterableExtension<E> on Iterable<E> {
  List<E> intersperse(E value) {
    final List<E> result = <E>[];
    if (isEmpty) return result;

    for (final E element in this) {
      result..add(element)..add(value);
    }

    return result..removeLast();
  }

  List<E> surroundWith(E value) {
    final List<E> result = <E>[];
    if (isEmpty) return result;

    return [
      value,
      ...this,
      value,
    ];
  }
}

extension DateTimeExtension on DateTime {
  static DateTime parseLocal(String formattedString) {
    return DateTime.parse(formattedString).toLocal();
  }
}

extension PaddingExtension on Padding {
  EdgeInsets asEdgeInsets() {
    return padding.resolve(TextDirection.ltr);
  }
}
