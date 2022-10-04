import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsStore with ChangeNotifier {
  static late SharedPreferences _s;

  static Future<void> load() async {
    _s = await SharedPreferences.getInstance();
  }

  Future<bool> _setValue<T>(String key, T? value) {
    late Future<bool> future;

    if (value == null) {
      future = _s.remove(key);
    } else if (T == String) {
      future = _s.setString(key, value as String);
    } else {
      future = Future.value(false);
    }

    return future.then((value) {
      notifyListeners();
      return value;
    });
  }

  static const _TOKEN_KEY = 'token';

  String? get token => _s.getString(_TOKEN_KEY);

  set token(String? value) {
    _setValue(_TOKEN_KEY, value);
  }
}
