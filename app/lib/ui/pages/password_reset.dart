import 'package:flutter/material.dart';
import 'package:mnmn/ui/all.dart';
import 'package:reactive_forms/reactive_forms.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({Key? key}) : super(key: key);
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: const Text(
            'ご登録いただいているメールアドレスに',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: const Text(
            'お送りするリンクより新しいパスワードの',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: const Text(
            '再設定を行ってください。',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        pt32,
        ReactiveForm(
          formGroup: ValidateFormGroup.passResetForm,
          child: ReactiveTextField(
            formControlName: 'email',
            validationMessages: (control) => {
              ValidationMessage.required: 'メールアドレスを入力してください',
              ValidationMessage.email: 'メールアドレスを正しく入力してください',
            },
            decoration: InputDecoration(
              labelText: '登録メールアドレス',
              fillColor: Colors.transparent,
            ),
          ),
        ),
        pt24,
        TextButton(
          onPressed: _onPressedResetPassword,
          child: const Text('メール送信'),
        ),
        pt24,
        RichText(
            text: TextSpan(
          text: 'ログイン画面に戻る',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.primaryColor,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Navigator.pop(context),
        )),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('パスワード再設定'),
      ),
      body: SingleChildScrollView(
        padding: scrollablePaddingWithHorizontal,
        child: body,
      ),
    );
  }

  Future<void> _onPressedResetPassword() async {
    unfocus();

    final store = Provider.of<GlobalStore>(context, listen: false);
    final formValue = ValidateFormGroup.passResetForm.value;
    final req = {
      'email': formValue['email'],
    };
    final res = await store.api.requestResetPassword(req);
    final success = (res['success'] as bool?) ?? false;
    if (success) {
      Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => const PasswordResetCompletionPage()),
      );
    } else if (res['token'] != null) {
      showErrorDialog(
        context: context,
        message: 'アカウントの登録に失敗しました',
      );
    }
  }
}
