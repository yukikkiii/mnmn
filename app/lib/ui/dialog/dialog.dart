import 'package:flutter/widgets.dart';
import 'package:mnmn/ui/all.dart';

// TODO(refactor): separate isOkOnly into showAlertMessage
// TODO(refactor): make showConfirmationDialog (search for confirmationDialogTitle)

bool _makeBoolNonNullable(bool? maybeBool) {
  return maybeBool ?? false;
}

Future<bool> showDialogMessage({
  required BuildContext context,
  Widget? content,
  required String title,
  String? message,
  bool isOkOnly = false,
  bool useYesNo = false,
  bool noAction = false,
}) {
  assert((content ?? message) != null);

  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) => _buildDialog(
      context,
      title: title,
      widget: content ?? Text(message!),
      isOkOnly: isOkOnly,
      useYesNo: useYesNo,
      noAction: noAction,
    ),
  ).then(_makeBoolNonNullable);
}

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  required String title,
}) {
  return showDialog<T>(
    context: context,
    builder: (BuildContext context) => _buildDialog(
      context,
      widget: builder(context),
      title: title,
      noAction: true,
      isOkOnly: false,
    ),
  );
}

Future<void> showErrorDialog({
  required BuildContext context,
  required String message,
}) =>
    showDialogMessage(
      context: context,
      title: 'エラー',
      message: message,
      isOkOnly: true,
    );

Widget _buildDialog(
  BuildContext context, {
  String? title,
  Widget? widget,
  bool isOkOnly = false,
  bool useYesNo = false,
  bool noAction = false,
}) {
  assert((title ?? widget) != null);

  final List<Widget> actions = <Widget>[
    if (!isOkOnly)
      FlatButton(
        child: Text(useYesNo ? 'いいえ' : 'キャンセル'),
        onPressed: () {
          Navigator.pop(context, false);
        },
      ),
    FlatButton(
      child: Text(useYesNo ? 'はい' : 'OK'),
      onPressed: () {
        Navigator.pop(context, true);
      },
    ),
  ];

  return AlertDialog(
    title: title == null ? null : Text(title),
    content: widget,
    actions: noAction ? null : actions,
  );
}

// Note: You can close the dialog by `Navigator.pop(context)`.
// Usually you can ignore the return value of this function.
Future<void> showLoadingDialog(BuildContext context) {
  return showDialog<void>(
    barrierDismissible: false,
    builder: (ctx) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    },
    context: context,
  );
}
