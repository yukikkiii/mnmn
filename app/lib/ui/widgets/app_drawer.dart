import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';
import 'package:mnmn/ui/pages/contact_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer();

  @override
  Widget build(BuildContext context) {
    final store = context.read<GlobalStore>();
    final user = context.select<GlobalStore, User?>(
      (store) => store.currentUser,
    );

    return Drawer(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: IconButton(
                icon: const Icon(Icons.close, size: 30.0),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          pt8,
          Flexible(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: const Text('アカウント設定'),
                  onTap: () async {
                    Uint8List? image;
                    if (user!.profileImage !=
                        '/asset/image/default-profile-image.png') {
                      final url = Config.API_URL + user.profileImage;
                      image =
                          (await NetworkAssetBundle(Uri.parse(url)).load(url))
                              .buffer
                              .asUint8List();
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => AccountSettingsPage(image: image),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('お問い合わせ'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (_) => ContactPage()),
                    );
                  },
                ),
                ListTile(
                  title: Text('アカウント削除'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (_) => ContactPage()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('ログアウト'),
                  onTap: () async {
                    showLoadingDialog(context);

                    try {
                      await store.api.signOut();
                    } catch (_) {
                      //
                    }

                    store.signOut();
                    context.read<SharedPrefsStore>().token = null;

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          if (Config.IS_DEVELOPMENT)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('[DEBUG]', style: TextStyles.bold),
                      Text(user?.name ?? ''),
                      pt24,
                    ],
                  ),
                ],
              ),
            ),
        ].surroundWith(pt24),
      ),
    );
  }
}
