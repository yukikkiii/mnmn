import 'package:flutter/material.dart';
import 'package:mnmn/main.dart';

class NewPasswordTop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        backgroundColor: Colors.white,
        primaryColor: Colors.black,
        primaryColorLight: Colors.grey[500],
        primaryColorDark: Colors.black,
        shadowColor: const Color(0xFFF0F0F0),
        buttonColor: Colors.grey[700],
        appBarTheme: const AppBarTheme(color: Color(0xFFFFFFFF)),
        primaryTextTheme:
            const TextTheme(headline6: TextStyle(color: Colors.black)),
        unselectedWidgetColor: const Color(0xFFF0F0F0),
      ),
      home: const NewPassword(title: 'mnmn'),
    );
  }
}

class NewPassword extends StatefulWidget {
  const NewPassword({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 35),

            Container(
              padding: const EdgeInsets.only(bottom: 8),
              width: MediaQuery.of(context).size.width / 1.2,
              child: const Text(
                'パスワード再設定画面へのリンクをご登録メールアドレスにお送りしました。',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height / 35),

            Container(
              padding: const EdgeInsets.only(bottom: 8),
              width: MediaQuery.of(context).size.width / 1.2,
              child: const Text(
                '万が一メールが届かない場合は、mnmn運営サポートまでお問い合わせください。',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height / 15),

            // ignore: sized_box_for_whitespace
            Container(
              width: 200,
              height: 45,
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: Theme.of(context).backgroundColor,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('ログイン画面に戻る',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height / 35),
          ],
        ),
      ),
    );
  }
}
