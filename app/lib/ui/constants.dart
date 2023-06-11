import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mnmn/utils/config.dart';

const APP_NAME = 'mnmn';

class AppColors {
  static const accent = Color(0xFFE63929);
  static const darkGrey = Color(0xFF333333);
  static const praySite = Color(0xFF5346AA);
}

const DEFAULT_FONT_SIZE = 16.0;

class TextStyles {
  static const normal = TextStyle(fontSize: DEFAULT_FONT_SIZE);
  static const normalBlack =
      TextStyle(fontSize: DEFAULT_FONT_SIZE, color: Colors.black);
  static const accent = TextStyle(color: AppColors.accent);
  static const accentBold =
      TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold);
  static const accentBoldSmall = TextStyle(
      color: AppColors.accent,
      fontWeight: FontWeight.bold,
      fontSize: DEFAULT_FONT_SIZE * 0.9);
  static const bold = TextStyle(fontWeight: FontWeight.bold);
  static const weak =
      TextStyle(color: Color(0xFFB2B2B2), fontSize: DEFAULT_FONT_SIZE * 0.8);
  static const weakLarge = TextStyle(color: Color(0xFFB2B2B2));
  static const weakBold = TextStyle(
      color: Color(0xFFB2B2B2),
      fontSize: DEFAULT_FONT_SIZE * 0.8,
      fontWeight: FontWeight.bold);
  static const weakBoldLarge =
      TextStyle(color: Color(0xFFB2B2B2), fontWeight: FontWeight.bold);
}

final outlinedButtonStyleBlackBorder = OutlinedButton.styleFrom(
  side: const BorderSide(color: Colors.black),
  primary: Colors.black,
  textStyle: TextStyles.normalBlack,
);
final outlinedButtonStyleBlack = OutlinedButton.styleFrom(
  side: const BorderSide(color: Color(0xFF4D4D4D)),
  backgroundColor: const Color(0xFF4D4D4D),
  primary: Colors.white,
  textStyle: TextStyles.normalBlack.copyWith(color: Colors.white),
);

final defaultUserImage = NetworkImage(
  '${Config.API_URL}/asset/image/default-profile-image.png',
);

const defaultLocation = LatLng(35.658584, 139.7454316); // 東京タワー

void unfocus() {
  FocusManager.instance.primaryFocus?.unfocus();
}
