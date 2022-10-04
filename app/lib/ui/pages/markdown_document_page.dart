import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mnmn/ui/all.dart';

class MarkdownDocumentPage extends HookWidget {
  const MarkdownDocumentPage({
    required this.path,
    required this.title,
  });

  final String path;
  final String title;

  static Future<void> push({
    required BuildContext context,
    required String path,
    required String title,
  }) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MarkdownDocumentPage(
          path: path,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final future = useMemoized(() {
      return DefaultAssetBundle.of(context).loadString(path);
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<String>(
        future: future,
        builder: (_, content) {
          if (!content.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Markdown(
            styleSheet: MarkdownStyleSheet(
              h2Padding: pt16.asEdgeInsets(),
            ),
            data: content.data!,
          );
        },
      ),
    );
  }
}
