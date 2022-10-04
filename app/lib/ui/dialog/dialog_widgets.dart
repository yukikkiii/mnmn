import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.children,
    this.user,
    this.actions,
  });

  final List<Widget> children;
  final User? user;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 36.0,
                    height: 36.0,
                    child: Icon(Icons.close, color: AppColors.darkGrey),
                  ),
                ),
              ),
            ],
          ),
          if (user != null) ...<Widget>[UserDialogHeader(user!), pt32],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: children,
            ),
          ),
          if (actions != null) ...<Widget>[pt32, actions!],
          pt32,
        ],
      ),
    );
  }
}

class UserDialogHeader extends StatelessWidget {
  const UserDialogHeader(this.user);

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: uploadedImage(
            user.profileImage,
          ),
        ),
        pt16,
        Text(
          user.name,
          style: TextStyles.bold,
        ),
      ],
    );
  }
}
