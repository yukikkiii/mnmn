import 'package:mnmn/ui/all.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _isChecked = false;

  final _form = FormGroup(
    {
      'name': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'email': FormControl<String>(
        validators: [
          Validators.required,
          Validators.email,
        ],
      ),
      'subject': FormControl<String>(validators: [
        Validators.required,
      ]),
      'body': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
    },
  );

  @override
  void initState() {
    super.initState();

    final currentUser = context.read<GlobalStore>().currentUser;
    if (currentUser != null) {
      _form.patchValue({
        'name': currentUser.name,
        'email': currentUser.rawValues?['email'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = ReactiveForm(
      formGroup: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'お問い合わせはお気軽にどうぞ。アカウントの削除についても、こちらからお問い合わせください。',
            ),
          ),

          pt24,
          _buildLabel('お名前'),
          pt8,
          ReactiveTextField<String>(
            formControlName: 'name',
            validationMessages: ValidateFormGroup.validationMessages('お名前'),
          ),

          //tel
          pt24,
          _buildLabel('メールアドレス'),
          pt8,
          ReactiveTextField<String>(
            style: context.primaryColorTextStyle,
            formControlName: 'email',
            validationMessages: ValidateFormGroup.validationMessages('メールアドレス'),
          ),
          // TextFormField(

          //pass
          pt24,
          _buildLabel('お問い合わせタイトル'),
          pt8,
          ReactiveTextField<String>(
            formControlName: 'subject',
            validationMessages: ValidateFormGroup.validationMessages('タイトル'),
          ),
          //pass confirm
          pt24,
          _buildLabel('お問い合わせ内容'),
          pt8,
          ReactiveTextField<String>(
            formControlName: 'body',
            maxLines: 10,
            maxLength: 1000,
            validationMessages: ValidateFormGroup.validationMessages('内容'),
          ),

          //check box
          pt24,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                MarkdownDocumentPage.push(
                                  context: context,
                                  title: '利用規約',
                                  path: 'asset/text/terms.md',
                                );
                              },
                            style: TextStyle(
                              fontSize: 14.0,
                              color: AppColors.accent,
                              decoration: TextDecoration.underline,
                            ),
                            text: '利用規則',
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
            child: StreamBuilder(
              stream: _form.valueChanges,
              builder: (_, __) => TextButton(
                onPressed: _isChecked && _form.valid ? submit : null,
                child: Text(
                  '送信',
                ),
              ),
            ),
          ),
          pt32,
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('お問い合わせ'),
      ),
      body: SingleChildScrollView(
        padding: scrollablePaddingWithHorizontal,
        child: body,
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Row(
      children: [
        Text(label),
        pl4,
        Text(
          '[必須]',
          style: TextStyle(
            fontSize: 14.0,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Future<void> submit() async {
    final store = context.read<GlobalStore>();

    try {
      await store.api.postContact(_form.value);
      Navigator.pop(context);
    } catch (_) {
      store.rootContext.showTextSnackBar('お問い合わせを送信しました');
    }
  }
}
