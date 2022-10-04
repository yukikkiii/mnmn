import 'package:reactive_forms/reactive_forms.dart';

class CustomValidators {
  static final noSpaces = Validators.pattern(RegExp(r'^[^\s]+$'));
  static final password = Validators.pattern(
      RegExp(r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z\d]{8,100}$'));
  static final phoneNumber = Validators.pattern(RegExp(r'^0'));
}

class ValidateFormGroup {
  static FormGroup topLoginForm = FormGroup(
    {
      'email': FormControl<String>(
        validators: [
          Validators.required,
          Validators.email,
        ],
      ),
      'password': FormControl<String>(validators: [
        Validators.required,
      ]),
    },
  );

  static FormGroup signUpForm = FormGroup(
    {
      'username': FormControl<String>(
        validators: [
          Validators.required,
          CustomValidators.noSpaces,
        ],
      ),
      'email': FormControl<String>(
        validators: [
          Validators.required,
          Validators.email,
          // Validators.pattern(phonePattern),
        ],
      ),
      'password': FormControl<String>(validators: [
        Validators.required,
        Validators.minLength(8),
        CustomValidators.password,
      ]),
      'passwordConfirmation': FormControl<String>(),
    },
    validators: [Validators.mustMatch('password', 'passwordConfirmation')],
  );

  static FormGroup passResetForm = FormGroup({
    'email': FormControl<String>(
      validators: [
        Validators.required,
        Validators.email,
      ],
    ),
  });

  static Map<String, String> Function(FormControl) validationMessages(
    String formName, {
    Map<String, String>? messages,
    bool password = false,
  }) {
    return (_) => {
          ValidationMessage.required: '$formNameを入力してください',
          ValidationMessage.email: 'メールアドレスは正しく入力してください',
          if (messages != null) ...messages,
          if (password) ValidationMessage.pattern: '半角英数、大小文字のそれぞれを最低1つ含めてください',
        };
  }
}
