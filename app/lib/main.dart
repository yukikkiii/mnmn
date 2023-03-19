import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';
import 'package:mnmn/ui/stores/all.dart';
import 'package:mnmn/utils/config.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  // Allow static Provider
  Provider.debugCheckInvalidValueType = null;

  print('Running app with following configurations:');
  print(Config.configs.entries
      .map((entry) => '${entry.key}=${entry.value}')
      .join('\n'));

  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsStore.load();
  final prefs = SharedPrefsStore();

  String? fcmToken;
  await Firebase.initializeApp();
  final authorized = await FirebaseMessaging.instance.requestPermission();
  if (authorized.authorizationStatus == AuthorizationStatus.authorized) {
    fcmToken = await FirebaseMessaging.instance.getToken();
  }
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(prefs, fcmToken));
}

class MyApp extends StatelessWidget {
  const MyApp(this.prefsStore, this.fcmToken);

  final SharedPrefsStore prefsStore;
  final String? fcmToken;

  @override
  Widget build(BuildContext context) {
    const locale = Locale('ja', 'JP');
    Intl.systemLocale = locale.toString();
    const shadowColor = Color(0xFFF0F0F0);
    const accentColor = AppColors.accent;

    final outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.transparent),
    );

    final app = MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: prefsStore),
        ChangeNotifierProvider(
          create: (_) {
            final store = GlobalStore(
              deviceName: '*',
              token: prefsStore.token,
              fcmToken: fcmToken,
            );

            store.createGlobalKey<HomePageState>();
            return store;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: !Config.HIDE_DEBUG_BANNER,
        locale: locale,
        supportedLocales: const <Locale>[locale],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: APP_NAME,
        theme: ThemeData(
          primaryColor: Colors.black,
          primaryColorDark: Colors.black,
          primaryColorLight: Colors.grey[500],
          accentColor: accentColor,
          backgroundColor: Colors.white,
          buttonColor: accentColor,
          shadowColor: shadowColor,
          appBarTheme: const AppBarTheme(
            color: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            actionsIconTheme: IconThemeData(color: Colors.black),
            elevation: 0.0,
            centerTitle: true,
          ),
          primaryTextTheme: const TextTheme(
            headline6: TextStyle(color: Colors.black),
          ),
          scaffoldBackgroundColor: Colors.white,
          tabBarTheme: TabBarTheme(
            unselectedLabelColor: Colors.grey[700],
            labelColor: accentColor,
            unselectedLabelStyle: const TextStyle(
              fontSize: 18,
            ),
            labelStyle: const TextStyle(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            indicator: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: accentColor, width: 4),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            isDense: true,
            border: outlineInputBorder,
            focusedBorder: outlineInputBorder,
            enabledBorder: outlineInputBorder,
            disabledBorder: outlineInputBorder,
            errorBorder: outlineInputBorder.copyWith(
              borderSide: const BorderSide(color: Colors.red),
            ),
            fillColor: shadowColor,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              minimumSize: const Size(180, 56),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              backgroundColor: accentColor,
              primary: Colors.white,
              onSurface: Colors.white,
              textStyle: TextStyles.bold.copyWith(
                fontSize: DEFAULT_FONT_SIZE * 1.2,
              ),
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey[500]!;
              } else if (states.contains(MaterialState.selected)) {
                return accentColor;
              }
              return Colors.grey[500]!;
            }),
            checkColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.white;
              } else if (states.contains(MaterialState.disabled)) {
                return Colors.grey;
              }
              return accentColor;
            }),
          ),
        ),
        home: const RootPage(),
      ),
    );

    return GestureDetector(
      // Automatically unfocus when touching outside of TextField
      onTap: unfocus,
      child: app,
    );
  }
}

class RootPage extends HookWidget {
  const RootPage();

  @override
  Widget build(BuildContext context) {
    final store = context.read<GlobalStore>();
    store.rootContext = context;
    final token = context.select<GlobalStore, String?>((store) => store.token);
    final currentUser =
        context.select<GlobalStore, User?>((store) => store.currentUser);

    Future<void> updateBadge() async {
      if (store.token != null) {
        final res = await store.api.getUnreadMessageCount();
        final count = res['count'] as int;
        store.availableMessagesCount = count;
        store.messagesAvailable = (res['items'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .toList();
        store.praySiteMessages = res['pray_site_messages'] as int;
      }
    }

    // Callbacks
    final updateLocation = useCallback((BuildContext context) async {
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // ユーザーに位置情報を許可してもらうよう促す
        permission = await Geolocator.requestPermission();
      }
      try {
        final location = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final store = context.read<GlobalStore>();
        store.currentLocation = LatLng(location.latitude, location.longitude);
        store.api.updateLocation(<String, dynamic>{
          'lat': location.latitude,
          'long': location.longitude,
        });
      } catch (_) {}
    }, const []);

    // トークン検証、ユーザ情報設定
    useEffect(() {
      if (store.token != null) {
        store.api.getMyProfile().then((res) {
          store.currentUser = User.fromMap(res['user'] as Map<String, dynamic>);
        }).catchError((dynamic _) {
          store.signOut();
        });
      }
    }, [token]);

    // ログイン時の初期化処理
    useEffect(() {
      if (store.currentUser != null) {
        updateBadge();

        // 位置情報を取得・登録する
        updateLocation(context);

        // イノリドコロを取得する
        store.praySites.clear();
        store.api.listPraySites().then((res) {
          final praySites = (res['items'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map((item) => UserLocation.fromMap(item))
              .toList();
          store.praySites.addAll(praySites);
        });

        // サーバにFCMトークンを登録する
        if (store.fcmToken != null) {
          print('Registering FCM token: ${store.fcmToken}');

          final req = <String, dynamic>{
            'fcm_token': store.fcmToken,
          };
          store.api.updateFcmToken(req);
        }
      }
    }, [store.currentUser?.id]);

    // アプリ起動時に1回限り実行される
    useEffect(() {
      // ログイン中、一定時間おきに未取得メッセージ件数を更新する
      final timer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => updateBadge(),
      );
      return () {
        timer.cancel();
      };
    }, const []);

    if (token == null) {
      return const SignInPage();
    } else if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return HomePage(key: store.getGlobalKey<HomePageState>());
  }
}
