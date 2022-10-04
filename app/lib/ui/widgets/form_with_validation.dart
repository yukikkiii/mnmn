import 'package:reactive_forms/reactive_forms.dart';

class ValidateFormGroup {
  final hoge = 'hoge';

  static Pattern phonePattern = r'^0';
  static Pattern passPattern = r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z\d]{8,100}$';

  static FormGroup topLoginForm = FormGroup({
    'email': FormControl<String>(
      validators: [
        Validators.required,
        Validators.email,
      ],
    ),

    'password': FormControl<String>(
        validators: [
          Validators.required,
        ]),
  },
  );

  static FormGroup signupForm = FormGroup({
    'username': FormControl<String>(
      validators: [
        Validators.required,
      ],
    ),
    'phone': FormControl<String>(
      validators: [
          Validators.required,
          Validators.pattern(phonePattern),
      ],
    ),
    'password': FormControl<String>(validators: [
      Validators.required,
      Validators.minLength(8),
      Validators.pattern(passPattern),
    ]),
    'passwordConfirmation': FormControl<String>(),
  }, validators: [
    Validators.mustMatch('password', 'passwordConfirmation')
  ]);

  static FormGroup passResetForm = FormGroup(
      {
        'email': FormControl<String>(
          validators: [
            Validators.required,
            Validators.email,
          ],
        ),
      }
  );
}