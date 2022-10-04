import 'package:flutter/foundation.dart';
import 'package:mnmn/ui/all.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '空間にメッセージを送って、\n気持ちの交換をしよう。',
          style: TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
        pt32,
        ReactiveForm(
          formGroup: ValidateFormGroup.topLoginForm,
          child: ReactiveTextField(
            formControlName: 'email',
            validationMessages: (control) => {
              ValidationMessage.required: 'Emailアドレスを入力してください',
              ValidationMessage.email: 'Emailアドレスを正しく入力してください',
            },
            decoration: InputDecoration(
              labelText: 'メールアドレス',
            ),
          ),
        ),
        pt16,
        ReactiveForm(
          formGroup: ValidateFormGroup.topLoginForm,
          child: ReactiveTextField(
            formControlName: 'password',
            obscureText: true,
            validationMessages: (control) => {
              ValidationMessage.required: 'パスワードを入力してください',
            },
            decoration: InputDecoration(
              labelText: 'パスワード',
            ),
          ),
        ),
        pt24,
        TextButton(
          onPressed: _onPressSignIn,
          child: const Text('ログイン'),
        ),
        if (Config.IS_DEVELOPMENT) ...<Widget>[
          pt12,
          TextButton(
            onPressed: () => _onPressDebugEnterCredential(context),
            child: const Text('[DEBUG] ログイン情報入力'),
          ),
        ],
        pt48,
        RichText(
          text: TextSpan(
            text: 'パスワードを忘れた方は',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: context.primaryColor,
            ),
            children: [
              TextSpan(
                text: 'こちら',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const PasswordResetPage(),
                        ),
                      ),
              )
            ],
          ),
        ),
        pt16,
        RichText(
          text: TextSpan(
            text: 'アカウントをお持ちでない場合は、',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: context.primaryColor,
            ),
            children: [
              TextSpan(
                text: '登録',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const SignUpPage(),
                        ),
                      ),
              ),
              const TextSpan(text: 'してください。'),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(APP_NAME),
      ),
      body: CenteredSingleChildScrollView(
        padding: scrollablePaddingWithHorizontal,
        child: body,
      ),
    );
  }

  Future<void> _onPressSignIn() async {
    unfocus();

    final store = context.read<GlobalStore>();
    final req = {
      ...ValidateFormGroup.topLoginForm.value,
      'device_name': store.deviceName,
    };

    showLoadingDialog(context);

    try {
      final res = await store.api.signIn(req);
      if (res['token'] != null) {
        final token = res['token'] as String;
        store.token = token;

        final prefs = context.read<SharedPrefsStore>();
        prefs.token = token;
      } else {
        throw Error();
      }

      Navigator.pop(context);
    } catch (_) {
      Navigator.pop(context);

      await showErrorDialog(
        context: context,
        message: 'ログインに失敗しました',
      );
    }
  }

  void _onPressDebugEnterCredential(BuildContext context) {
    final form = ValidateFormGroup.topLoginForm;
    const fakeIds = [1, 2, 3, 4];

    var found = false;
    for (final e in fakeIds.asMap().entries) {
      final i = e.key;
      final userId = e.value;
      final next = userId == fakeIds.last ? fakeIds.first : fakeIds[i + 1];
      if (form.value['email'] == 'dev$userId@example.com') {
        form.value = {
          ...form.value,
          'email': 'dev$next@example.com',
          'password': 'password$next',
        };
        found = true;
        break;
      }
    }
    if (!found) {
      form.value = {
        ...form.value,
        'email': 'dev1@example.com',
        'password': 'password1',
      };
    }
  }
}
