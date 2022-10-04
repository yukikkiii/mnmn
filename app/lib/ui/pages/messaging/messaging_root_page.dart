import 'dart:async';

import 'package:mnmn/model/all.dart';
import 'package:mnmn/ui/all.dart';

enum MessagingPageType {
  friend,
  location,
  receiveRadius,
  edit,
  preview,
}

// TODO: 表示順を入れ替えられるようにする
const MessagingPageStates = <int, List<MessagingPageType>>{
  1: [
    MessagingPageType.friend,
    MessagingPageType.location,
    MessagingPageType.receiveRadius,
    MessagingPageType.edit,
    MessagingPageType.preview,
  ],
  2: [
    MessagingPageType.location,
    MessagingPageType.friend,
    MessagingPageType.receiveRadius,
    MessagingPageType.edit,
    MessagingPageType.preview,
  ],
  3: [
    MessagingPageType.edit,
    MessagingPageType.location,
    MessagingPageType.friend,
    MessagingPageType.receiveRadius,
    MessagingPageType.preview,
  ],
};

class MessagingRootPageState {
  MessagingRootPageState({
    required this.currentPageIndex,
    required this.draftMessage,
    required this.storyDesignerKey,
    required this.pages,
  });

  final ValueNotifier<int> currentPageIndex;
  final DraftMessage draftMessage;
  final GlobalKey<StoryDesignerState> storyDesignerKey;
  final List<MessagingPageType> pages;
  final canSubmit = ValueNotifier(false);
  bool confirmed = false;
  bool asDraft = false;

  VoidCallback? resetHandler;

  void goBack() {
    currentPageIndex.value--;
    if (draftMessage.isPraySite &&
        pages[currentPageIndex.value] == MessagingPageType.receiveRadius) {
      currentPageIndex.value--;
    }
    if (resetHandler != null) {
      resetHandler!();
    }

    resetHandler = null;
  }

  void goForward() {
    currentPageIndex.value++;
    if (draftMessage.isPraySite &&
        pages[currentPageIndex.value] == MessagingPageType.receiveRadius) {
      currentPageIndex.value++;
    }

    resetHandler = null;
  }
}

class DraftMessage {
  int? id;
  List<StoryItem>? items;
  User? to;
  LatLng? location;
  String note = '';
  int receiveRadius = 100;
  bool isPraySite = false;
}

class MessagingRootPage extends HookWidget {
  const MessagingRootPage({
    this.pageOrder = 1,
    DraftMessage? draftMessage,
  }) : _draftMessageProp = draftMessage;

  final int pageOrder;
  final DraftMessage? _draftMessageProp;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ...MessagingPageStates[pageOrder]!,
      MessagingPageType.preview
    ];
    final currentPageIndex = useState(0);
    final currentPage = pages[currentPageIndex.value];
    final state = useState(MessagingRootPageState(
      currentPageIndex: currentPageIndex,
      draftMessage: _draftMessageProp ?? DraftMessage(),
      storyDesignerKey: GlobalKey<StoryDesignerState>(),
      pages: pages,
    ));
    final updater = useState(0);

    late Widget body;
    late String title;
    final List<Widget> actions = [];

    switch (currentPage) {
      case MessagingPageType.friend:
        body = AddressBookPage();
        title = '宛先を選ぶ';
        break;
      case MessagingPageType.location:
        body = LocationPickerPage(updater);
        title = '設置場所を選ぶ';
        actions.add(
          IconButton(
            icon: Icon(Icons.check,
                color: state.value.draftMessage.location == null
                    ? null
                    : Theme.of(context).accentColor),
            onPressed: state.value.draftMessage.location == null
                ? null
                : () {
                    state.value.goForward();
                  },
          ),
        );
        break;
      case MessagingPageType.receiveRadius:
        body = const ReceiveRadiusPage();
        title = '受け取り範囲を設定する';
        break;
      case MessagingPageType.edit:
        body = const MessageEditorPage();
        title = 'まにまにを綴る';
        actions.addAll([
          IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () async {
                final picker = ImagePicker();
                final file = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1080.0,
                  maxHeight: 1920.0,
                );
                if (file == null) {
                  return;
                }

                final imageBytes = await file.readAsBytes();
                final image = MemoryImage(imageBytes);
                final completer = Completer<Size>();
                image
                    .resolve(ImageConfiguration.empty)
                    .addListener(ImageStreamListener((ImageInfo info, bool _) {
                  completer.complete(Size(info.image.height.toDouble(),
                      info.image.width.toDouble()));
                }));
                final imageSize = await completer.future;

                final storyDesignerState =
                    state.value.storyDesignerKey.currentState!;
                storyDesignerState.stackData.add(
                  StoryItem(
                    type: StoryItemType.Image,
                    imageBytes: imageBytes,
                  )
                    ..image = image
                    ..imageSize = imageSize,
                );
                storyDesignerState.setState(() {});
              }),
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            onPressed: () async {
              final picker = ImagePicker();

              final file = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1080.0,
                maxHeight: 1920.0,
              );
              if (file == null) {
                return;
              }

              final imageBytes = await file.readAsBytes();
              final image = MemoryImage(imageBytes);
              final completer = Completer<Size>();
              image
                  .resolve(ImageConfiguration.empty)
                  .addListener(ImageStreamListener((ImageInfo info, bool _) {
                completer.complete(Size(
                    info.image.height.toDouble(), info.image.width.toDouble()));
              }));
              final imageSize = await completer.future;

              final storyDesignerState =
                  state.value.storyDesignerKey.currentState!;
              storyDesignerState.stackData.add(
                StoryItem(
                  type: StoryItemType.Image,
                  imageBytes: imageBytes,
                )
                  ..image = image
                  ..imageSize = imageSize,
              );
              storyDesignerState.setState(() {});
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: state.value.canSubmit,
            builder: (_, canSubmit, __) => IconButton(
              icon: Icon(
                Icons.check,
                color: canSubmit ? Theme.of(context).accentColor : null,
              ),
              onPressed: state.value.canSubmit.value
                  ? () {
                      final storyDesignerState =
                          state.value.storyDesignerKey.currentState!;
                      state.value.draftMessage.items =
                          storyDesignerState.stackData;
                      state.value.goForward();
                    }
                  : null,
            ),
          ),
        ]);
        break;
      case MessagingPageType.preview:
        body = Builder(
          builder: (context) => MessageConfirmationPage(context),
        );
        title = '送信確認';
        break;
    }

    final page = WillPopScope(
      onWillPop: () async {
        if (currentPageIndex.value > 0) {
          state.value.goBack();
          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
        ),
        body: body,
      ),
    );
    return Provider.value(
      value: state.value,
      child: page,
    );
  }
}
