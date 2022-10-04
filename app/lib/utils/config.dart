import 'package:flutter/foundation.dart';

class Config {
  static const configs = {
    'API_URL': API_URL,
    'HIDE_DEBUG_BANNER': HIDE_DEBUG_BANNER,
    'IS_DEVELOPMENT': IS_DEVELOPMENT,
  };

  static const API_URL = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://mnmn.gstate.dev',
  );
  static const HIDE_DEBUG_BANNER = bool.fromEnvironment(
    'HIDE_DEBUG_BANNER',
    defaultValue: false,
  );
  static const IS_DEVELOPMENT = bool.fromEnvironment(
    'IS_DEVELOPMENT',
    defaultValue: !kReleaseMode,
  );
}
