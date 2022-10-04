import 'dart:typed_data';

import 'package:mnmn/ui/all.dart';

class AddFriendPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final store = context.read<GlobalStore>();

    // States
    final searchNameController = useTextEditingController();
    final isSearching = useState(false);
    final searchResult = useState<List<dynamic>?>(null);
    final checked = useState(<int>{});
    final alreadyFriends = useState(<int>{});

    // Callbacks
    final searchUsers = useCallback(() async {
      final name = searchNameController.text.trim();
      if (name.isEmpty) {
        return;
      }

      unfocus();

      checked.value.clear();
      isSearching.value = true;
      final req = <String, String>{
        'name': name,
      };

      final res = await store.api.searchUsers(req);
      searchResult.value = res['items'] as List<dynamic>;
      alreadyFriends.value = (searchResult.value!
          .where((dynamic user) => user['is_following'] as bool)
          .map((dynamic user) => user['id'] as int)).toSet();
      isSearching.value = false;
    }, []);

    // UI
    final content = <Widget>[];
    if (searchResult.value == null && !isSearching.value) {
    } else {
      content.addAll([
        const Text('検索結果'),
        pt32,
      ]);

      if (isSearching.value) {
        content.add(const CircularProgressIndicator());
      } else {
        if (searchResult.value!.isEmpty) {
          content.addAll([
            const Text('友達になれるユーザーが見つかりませんでした。'),
          ]);
        } else {
          content
            ..addAll(
              searchResult.value!.whereType<Map<String, dynamic>>().map((user) {
                final id = user['id'] as int;
                final alreadyFriend = alreadyFriends.value.contains(id);

                void toggleCheck() {
                  if (checked.value.contains(id)) {
                    checked.value =
                        checked.value.where((it) => id != it).toSet();
                  } else {
                    checked.value = <int>{...checked.value, id};
                  }
                }

                return InkWell(
                  onTap: alreadyFriend ? null : toggleCheck,
                  child: Row(
                    children: [
                      Checkbox(
                        onChanged: alreadyFriend ? null : (_) => toggleCheck(),
                        value: alreadyFriend || checked.value.contains(id),
                      ),
                      CircleAvatar(
                        backgroundImage:
                            uploadedImage(user['profile_image'] as String),
                      ),
                      pl8,
                      Text(user['name'] as String,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              }),
            )
            ..addAll([
              pt16,
              TextButton(
                onPressed: checked.value.isEmpty
                    ? null
                    : () async {
                        final req = <String, dynamic>{
                          'user_id': checked.value.toList(),
                        };

                        await store.api.addFriends(req);
                        store.updateAddressBook();
                        Navigator.pop(context);

                        store.rootContext.showTextSnackBar(
                          '${checked.value.length}人のユーザーと友達になりました',
                        );
                      },
                child: const Text('友達になる'),
              ),
            ]);
        }

        content.addAll([
          pt16,
          TextButton(
            onPressed: () {
              searchNameController.clear();
              searchResult.value = null;
            },
            child: const Text('検索結果をリセットする'),
          ),
        ]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('友達追加'),
      ),
      body: SingleChildScrollView(
        padding: scrollablePaddingWithHorizontal,
        child: Column(
          children: [
            TextField(
              onEditingComplete: searchUsers,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppColors.darkGrey),
                hintText: 'ユーザー名または ID',
              ),
              controller: searchNameController,
            ),
            pt32,
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => _AddFriendDialog(),
                  fullscreenDialog: true,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Icon(Icons.person_add_alt, size: 48.0),
                    Text(
                      '宛先を追加する',
                      style: context.textStyle.copyWith(
                        fontSize: context.textStyle.fontSize! * 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pt24,
            ...content,
          ],
        ),
      ),
    );
  }
}

class _AddFriendDialog extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final store = context.read<GlobalStore>();

    // States
    final createNameController = useTextEditingController();
    final createProfileController = useTextEditingController();
    final imageExt = useState('');
    final image = useState<Uint8List?>(null);

    // Callbacks
    final pickImage = useCallback(() async {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        imageExt.value = file.path.split('.').last;
        image.value = await file.readAsBytes();
      }
    }, []);
    final createFriend = useCallback(() async {
      final name = createNameController.text.trim();
      final profile = createProfileController.text.trim();
      if (name.isEmpty) {
        context.showTextSnackBar('友達の名前を入力してください。');
        return;
      } else if (name.contains(RegExp(r'\s'))) {
        context.showTextSnackBar('友達の名前に空白を含めることはできません。');
        return;
      }

      String? profileImage;
      if (image.value != null) {
        final res = await store.api.uploadImage(
          image.value!,
          imageExt.value,
        );
        profileImage = res['path'] as String;
      }

      final req = <String, dynamic>{
        'user': <String, String>{
          'name': name,
          'self_introduction': profile,
          if (profileImage != null) 'profile_image': profileImage,
        },
      };
      final res = await store.api.addFriends(req);
      context.showTextSnackBar(
        (res['success'] as bool? ?? false) ? '友達を追加しました。' : '友達の追加に失敗しました。',
      );
      store.updateAddressBook();

      Navigator.of(context).pop();
    }, []);

    final body = Column(
      children: [
        const Text('架空の人等、何でも追加できます！'),
        pt32,
        CircleAvatar(
          backgroundImage: image.value == null
              ? defaultUserImage
              : MemoryImage(image.value!) as ImageProvider,
          radius: 48.0,
        ),
        pt12,
        SizedBox(
          width: 120,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
            ),
            onPressed: pickImage,
            child: const Text(
              '画像を編集',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
        pt12,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TextField(
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '名前を入力してください'),
            controller: createNameController,
          ),
        ),
        pt12,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TextField(
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: 'コメントを入力できます'),
            controller: createProfileController,
            minLines: 5,
            maxLines: 8,
          ),
        ),
        pt60,
        TextButton(
          onPressed: createFriend,
          child: const Text('追加する'),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('宛先を追加する'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: scrollablePaddingWithHorizontal,
          child: body,
        ),
      ),
    );
  }
}
