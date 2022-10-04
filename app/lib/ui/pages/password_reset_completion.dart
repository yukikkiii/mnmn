import 'package:mnmn/ui/all.dart';

class PasswordResetCompletionPage extends StatefulWidget {
  const PasswordResetCompletionPage({Key? key}) : super(key: key);

  @override
  _PasswordResetCompletionPageState createState() => _PasswordResetCompletionPageState();
}

class _PasswordResetCompletionPageState extends State<PasswordResetCompletionPage> {
  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        const Text(
          'パスワード再設定画面へのリンクをご登録メールアドレスにお送りしました。',
        ),
        pt8,
        const Text(
          '万が一メールが届かない場合は、mnmn運営サポートまでお問い合わせください。',
        ),
        pt32,
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Text(
            'ログイン画面に戻る',
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('パスワード再設定'),
      ),
      body: CenteredSingleChildScrollView(
        padding: scrollablePaddingWithHorizontal,
        child: body,
      ),
    );
  }
}
