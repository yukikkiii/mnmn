import 'dart:typed_data';

import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';

const _dummyPassword = '********';

class AccountSettingsPage extends HookWidget {
  const AccountSettingsPage({this.image});

  final Uint8List? image;

  @override
  Widget build(BuildContext context) {
    final store = context.read<GlobalStore>();
    const passwordKeys = [
      'old_password',
      'new_password',
      'new_password_confirmation'
    ];

    // States
    var imageExt = '';
    final user = useState(store.currentUser!);
    final updatingPassword = useState(false);
    final nameChanged = useState(false);
    final emailChanged = useState(false);
    final selfIntroductionChanged = useState(false);
    final image = useState<Uint8List?>(this.image);
    final passwordValidators = [
      Validators.minLength(8),
      CustomValidators.password,
    ];
    final formGroupState = useState(
      FormGroup(
        {
          'name': FormControl<String>(
            value: user.value.name,
            validators: [
              Validators.required,
            ],
          ),
          'email': FormControl<String>(
            value: user.value.rawValues?['email'] as String? ?? '',
            validators: [
              Validators.required,
              Validators.email,
            ],
          ),
          'password_dummy': FormControl<String>(
            value: _dummyPassword,
          ),
          'old_password': FormControl<String>(value: ''),
          'new_password': FormControl<String>(value: ''),
          'new_password_confirmation': FormControl<String>(value: ''),
          'self_introduction': FormControl<String>(
            value: user.value.selfIntroduction,
          ),
        },
      ),
    );
    final formGroup = formGroupState.value;

    // Callbacks
    final cancelUpdatePassword = useCallback(() {
      updatingPassword.value = false;
      for (final key in passwordKeys) {
        final control = formGroup.control(key);
        control.setValidators([]);
        control.patchValue('');
      }
    }, const []);
    final startUpdatePassword = useCallback(() {
      updatingPassword.value = true;
      for (final key in passwordKeys) {
        final control = formGroup.control(key);
        if (key != 'old_password') {
          control.setValidators(passwordValidators, autoValidate: true);
        }
      }
    }, const []);
    final updateFormValues = useCallback(() {
      final name = formGroup.value['name']! as String;
      final email = formGroup.value['email']! as String;
      final selfIntroduction = formGroup.value['self_introduction']! as String;
      nameChanged.value = user.value.name != name;
      emailChanged.value = user.value.rawValues?['email'] != email;
      selfIntroductionChanged.value =
          user.value.selfIntroduction != selfIntroduction;

      // forcing rebuild
      updatingPassword.value = !updatingPassword.value;
      updatingPassword.value = !updatingPassword.value;
    }, const []);
    final pickImage = useCallback(() async {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        imageExt = file.path.split('.').last;
        image.value = await file.readAsBytes();
        updateFormValues();
      }
    }, const []);

    // Lifecycle
    useEffect(() {
      formGroup.valueChanges.forEach((element) {
        updateFormValues();
      });
      return formGroup.dispose;
    }, const []);

    // Layout
    final rowDivider = _buildRow('', const Divider());
    final isImageSelected = image.value != null;
    final canSubmit = formGroup.valid &&
        (nameChanged.value ||
            emailChanged.value ||
            selfIntroductionChanged.value ||
            updatingPassword.value ||
            isImageSelected);

    final submit = useCallback(() {
      Future<void> f() async {
        unfocus();

        final req = Map<String, dynamic>.from(formGroup.value);
        ['password_dummy', 'new_password_confirmation'].forEach(req.remove);
        if (updatingPassword.value) {
          if (formGroup.value['old_password'] ==
              formGroup.value['new_password']) {
            context.showTextSnackBar('新しいパスワードは古いパスワードと異なっている必要があります。');
            return;
          } else if (formGroup.value['new_password'] !=
              formGroup.value['new_password_confirmation']) {
            context.showTextSnackBar('新しいパスワードの確認が一致しません。');
          }
        } else {
          passwordKeys.forEach(req.remove);
        }

        req['self_introduction'] = (req['self_introduction']! as String).trim();

        if (isImageSelected) {
          final res = await store.api.uploadImage(
            image.value!,
            imageExt,
          );
          req['profile_image'] = res['path'] as String;
        }

        try {
          final res = await store.api.updateProfile(req);
          if (res['error'] != null &&
              res['error']['code'] == 'incorrect_password') {
            context.showTextSnackBar('現在のパスワードを正しく入力してください。');
            return;
          }

          if (emailChanged.value) {
            await showDialog<void>(
              context: context,
              builder: (_) => AppDialog(
                actions: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
                children: [
                  Text(
                    'メールアドレスの変更を反映するには、送信したメールに記載の確認リンクを開いてください。',
                  ),
                ],
              ),
            );
          }

          store.currentUser = User.fromMap(res['user'] as Map<String, dynamic>);
          Navigator.pop(context);
        } catch (_) {
          context.showTextSnackBar('その名前はすでに利用されています。');
        }
      }

      f();
    }, [isImageSelected]);

    final form = ReactiveForm(
      formGroup: formGroup,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          pt24,
          Center(
            child: CircleAvatar(
              backgroundImage: image.value == null
                  ? defaultUserImage
                  : MemoryImage(image.value!) as ImageProvider,
              radius: 48.0,
            ),
          ),
          pt12,
          SizedBox(
            width: 120,
            child: OutlinedButton(
              style: outlinedButtonStyleBlackBorder,
              onPressed: pickImage,
              child: const Text('画像を編集'),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: [
                _buildRow(
                  '名前',
                  ReactiveTextField<String>(
                    formControlName: 'name',
                    validationMessages: (control) => {
                      ValidationMessage.required: 'ユーザー名を入力してください',
                      ValidationMessage.pattern: 'ユーザー名に空白を含めることはできません',
                    },
                  ),
                ),
                rowDivider,
                _buildRow(
                  'メールアドレス',
                  ReactiveTextField<String>(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    formControlName: 'email',
                    validationMessages:
                        ValidateFormGroup.validationMessages('メールアドレス'),
                  ),
                ),
                rowDivider,
                Visibility(
                  visible: updatingPassword.value,
                  child: _buildRow(
                    'パスワード',
                    Row(
                      children: [
                        Expanded(
                          child: ReactiveTextField<String>(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '現在のパスワード',
                            ),
                            formControlName: 'old_password',
                            obscureText: true,
                            obscuringCharacter: '*',
                            validationMessages:
                                ValidateFormGroup.validationMessages(
                              'パスワード',
                              messages: {
                                ValidationMessage.minLength:
                                    'パスワードは8文字以上で入力してください',
                              },
                              password: true,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: cancelUpdatePassword,
                          style: outlinedButtonStyleBlack,
                          child: Text('キャンセル'),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: updatingPassword.value,
                  child: rowDivider,
                ),
                Visibility(
                  visible: updatingPassword.value,
                  child: _buildRow(
                    '',
                    ReactiveTextField<String>(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '新しいパスワード',
                      ),
                      formControlName: 'new_password',
                      obscureText: true,
                      obscuringCharacter: '*',
                      validationMessages: ValidateFormGroup.validationMessages(
                        'パスワード',
                        messages: {
                          ValidationMessage.minLength: 'パスワードは8文字以上で入力してください',
                        },
                        password: true,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: updatingPassword.value,
                  child: rowDivider,
                ),
                Visibility(
                  visible: updatingPassword.value,
                  child: _buildRow(
                    '',
                    ReactiveTextField<String>(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '新しいパスワード (確認)',
                      ),
                      formControlName: 'new_password_confirmation',
                      obscureText: true,
                      obscuringCharacter: '*',
                      validationMessages: ValidateFormGroup.validationMessages(
                        'パスワード',
                        messages: {
                          ValidationMessage.minLength: 'パスワードは8文字以上で入力してください',
                          ValidationMessage.compare: 'パスワードと一致しません',
                        },
                        password: true,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !updatingPassword.value,
                  child: _buildRow(
                    'パスワード',
                    Row(
                      children: [
                        Expanded(
                          child: ReactiveTextField<String>(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            style: TextStyles.weakLarge,
                            formControlName: 'password_dummy',
                            obscureText: true,
                            obscuringCharacter: '*',
                          ),
                        ),
                        OutlinedButton(
                          onPressed: startUpdatePassword,
                          style: outlinedButtonStyleBlackBorder,
                          child: Text('変更'),
                        ),
                      ],
                    ),
                  ),
                ),
                rowDivider,
                _buildRow(
                  '自己紹介',
                  ReactiveTextField<String>(
                    formControlName: 'self_introduction',
                    minLines: 5,
                    maxLines: 8,
                    maxLength: 200,
                    validationMessages:
                        ValidateFormGroup.validationMessages('自己紹介'),
                  ),
                ),
              ],
            ),
          ),
          pt24,
          const Divider(),
          pt24,
          Center(
            child: TextButton(
              onPressed: canSubmit ? submit : null,
              child: Text('保存'),
            ),
          ),
        ],
      ),
    );

    final body = Scaffold(
      appBar: AppBar(
        title: const Text('アカウント設定'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: form,
        ),
      ),
    );

    return Theme(
      data: context.theme.copyWith(
        dividerColor: Colors.black,
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
        ),
      ),
      child: body,
    );
  }

  Widget _buildRow(String label, Widget formField) {
    return Row(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 120),
          child: Text(label),
        ),
        Expanded(
          child: Container(
            margin: formField is Divider
                ? EdgeInsets.zero
                : EdgeInsets.only(right: 16.0),
            padding: formField is Divider
                ? EdgeInsets.zero
                : EdgeInsets.only(right: 16.0),
            child: formField,
          ),
        ),
      ],
    );
  }
}
