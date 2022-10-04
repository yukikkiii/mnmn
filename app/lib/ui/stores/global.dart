import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mnmn/model/all.dart';
import 'package:mnmn/model/user.dart';
import 'package:mnmn/repository/api_repository.dart';

Type typeOf<T>() => T;

class GlobalStore with ChangeNotifier {
  GlobalStore({
    required this.deviceName,
    String? token,
    this.fcmToken,
    this.currentLocation,
  }) {
    _token = token;
    _api = ApiRepository(ApiClient(token: token));
  }

  GlobalKey<T> getGlobalKey<T extends State<StatefulWidget>>() {
    return _globalKeys[typeOf<T>()]! as GlobalKey<T>;
  }

  void createGlobalKey<T extends State<StatefulWidget>>() {
    _globalKeys[T] = GlobalKey<T>(debugLabel: T.toString());
  }

  late BuildContext rootContext;

  // States
  String? fcmToken;
  String? _token;
  late ApiRepository _api;
  final _globalKeys = <Type, GlobalKey>{};
  final List<UserLocation> praySites = [];

  final String deviceName; // TODO
  int updateAddressBookCount = 0;
  User? _currentUser;
  List<Map<String, dynamic>>? _messagesAvailable;
  int _availableMessagesCount = 0;
  int messageHistoryCount = 0;
  LatLng? currentLocation;
  LatLng? _retrievePageCamera;
  int _praySiteMessages = 0;

  ApiRepository get api => _api;

  void signOut() {
    token = null;
    currentUser = null;
    availableMessagesCount = 0;
  }

  String? get token => _token;

  set token(String? newValue) {
    _token = newValue;
    _api = ApiRepository(ApiClient(token: newValue));
    notifyListeners();
  }

  void updateMessageHistory() {
    messageHistoryCount++;
    notifyListeners();
  }

  void updateAddressBook() {
    updateAddressBookCount++;
    notifyListeners();
  }

  int get availableMessagesCount => _availableMessagesCount;

  set availableMessagesCount(int value) {
    _availableMessagesCount = math.max(0, value);
    notifyListeners();
  }

  List<Map<String, dynamic>>? get messagesAvailable => _messagesAvailable;

  set messagesAvailable(List<Map<String, dynamic>>? value) {
    _messagesAvailable = value;
    notifyListeners();
  }

  int get praySiteMessages => _praySiteMessages;

  set praySiteMessages(int praySiteMessages) {
    _praySiteMessages = praySiteMessages;
    notifyListeners();
  }

  User? get currentUser => _currentUser;

  set currentUser(User? currentUser) {
    _currentUser = currentUser;
    notifyListeners();
  }

  LatLng? get retrievePageCamera => _retrievePageCamera;

  set retrievePageCamera(LatLng? retrievePageCamera) {
    _retrievePageCamera = retrievePageCamera;
    notifyListeners();
  }
}
