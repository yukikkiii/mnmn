import 'package:mnmn/ui/all.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規登録'),
      ),
      body: SingleChildScrollView(
        padding: scrollablePaddingWithHorizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'mnmnを利用するには会員登録が必要です。',
              ),
            ),

            pt24,
            const Text(
              'ユーザーネーム',
            ),
            pt8,
            ReactiveForm(
              formGroup: ValidateFormGroup.signUpForm,
              child: ReactiveTextField(
                formControlName: 'username',
                validationMessages: (control) => {
                  ValidationMessage.required: 'ユーザー名を入力してください',
                  ValidationMessage.pattern: 'ユーザー名に空白を含めることはできません',
                },
                decoration: InputDecoration(
                  labelText: 'ユーザー名',
                ),
              ),
            ),

            //tel
            pt24,
            const Text(
              'メールアドレス',
            ),
            pt8,
            ReactiveForm(
              formGroup: ValidateFormGroup.signUpForm,
              child: ReactiveTextField(
                style: context.primaryColorTextStyle,
                formControlName: 'email',
                validationMessages: (control) => {
                  ValidationMessage.required: 'メールアドレスを入力してください',
                  ValidationMessage.email: 'メールアドレスは正しく入力してください'
                },
                decoration: InputDecoration(
                  labelText: 'メールアドレス',
                ),
              ),
            ),
            // TextFormField(

            //pass
            pt24,
            const Text(
              'パスワード',
            ),
            pt8,
            ReactiveForm(
              formGroup: ValidateFormGroup.signUpForm,
              child: ReactiveTextField(
                formControlName: 'password',
                obscureText: true,
                validationMessages: (control) => {
                  ValidationMessage.required: 'パスワードを入力してください',
                  ValidationMessage.minLength: 'パスワードは8文字以上で入力してください',
                  ValidationMessage.pattern: '半角英数、大小文字のそれぞれを最低1つ含めてください',
                },
                decoration: InputDecoration(
                  labelText: 'パスワード',
                ),
              ),
            ),

            //pass confirm
            pt24,
            const Text(
              'パスワード(確認)',
            ),
            pt8,
            ReactiveForm(
              formGroup: ValidateFormGroup.signUpForm,
              child: ReactiveTextField(
                formControlName: 'passwordConfirmation',
                obscureText: true,
                validationMessages: (control) => {
                  ValidationMessage.mustMatch: 'パスワードが一致しません',
                },
                decoration: InputDecoration(
                  labelText: 'パスワード(確認)',
                ),
              ),
            ),

            //check box
            pt24,
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value!;
                    });
                  },
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isChecked = !_isChecked;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: '会員規約',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: AppColors.accent,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.pop(context),
                            ),
                            TextSpan(text: '・'),
                            TextSpan(
                                text: 'プライバシーポリシー',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: AppColors.accent,
                                  decoration: TextDecoration.underline,
                                ),
                                  recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.pop(context),
                                ),
                            TextSpan(text: 'に同意する'),
                          ]),
                    ),
                  ),
                ),
              ],
            ),

            pt24,
            Center(
              child: TextButton(
                onPressed: ValidateFormGroup.signUpForm.valid && _isChecked
                    ? _onPressedSignUp
                    : null,
                child: Text(
                  '登録',
                ),
              ),
            ),

            pt32,
            Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(text: 'すでにアカウントをお持ちの方は'),
                  ],
                ),
              ),
            ),
            Center(
              child: RichText(
                  text: TextSpan(
                text: 'こちら',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.pop(context),
              )),
            ),

            if (Config.IS_DEVELOPMENT) ...<Widget>[
              pt24,
              Center(
                child: TextButton(
                  onPressed: () {
                    ValidateFormGroup.signUpForm.updateValue({
                      ...ValidateFormGroup.signUpForm.value,
                      'password': 'Password1',
                      'passwordConfirmation': 'Password1',
                    });
                  },
                  child: const Text('[DEBUG] Use `Password1`'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onPressedSignUp() async {
    unfocus();

    final store = Provider.of<GlobalStore>(context, listen: false);
    final formValue = ValidateFormGroup.signUpForm.value;
    final req = {
      'name': formValue['username'],
      'email': formValue['email'],
      'password': formValue['password'],
      'device_name': store.deviceName,
    };
    final res = await store.api.signUp(req);
    if (res['errors'] != null) {
      showErrorDialog(
        context: context,
        message: 'アカウントの登録に失敗しました',
      );
    } else if (res['token'] != null) {
      Provider.of<GlobalStore>(context, listen: false).token =
          res['token'] as String;
      Navigator.pop(context);
    }
  }
}
