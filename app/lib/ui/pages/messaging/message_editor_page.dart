import 'package:mnmn/ui/all.dart';

class MessageEditorPage extends HookWidget {
  const MessageEditorPage();

  @override
  Widget build(BuildContext context) {
    final messagingState = context.read<MessagingRootPageState>();
    return StoryDesigner(
      key: messagingState.storyDesignerKey,
      items: messagingState.draftMessage.items,
    );
  }
}
