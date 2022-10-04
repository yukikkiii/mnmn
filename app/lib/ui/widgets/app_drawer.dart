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
                  title: const Text('よくある質問'),
                  onTap: () {
                    MarkdownDocumentPage.push(
                      context: context,
                      title: 'よくある質問',
                      path: 'asset/text/faq.md',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompanyProfilePage(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('会社概要'),
                ),
              ),
              InkWell(
                onTap: () {
                  MarkdownDocumentPage.push(
                    context: context,
                    title: '利用規約',
                    path: 'asset/text/terms.md',
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('利用規約'),
                ),
              ),
            ].intersperse(
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('|'),
              ),
            ),
          ),
        ].surroundWith(pt24),
      ),
    );
  }
}
