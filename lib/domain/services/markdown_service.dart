import 'package:markdown/markdown.dart';

abstract class MarkdownService {
  String parseMarkdown(String content);
}

class MarkdownServiceImpl implements MarkdownService {
  @override
  String parseMarkdown(String content) {
    return markdownToHtml(
      content,
      extensionSet: ExtensionSet.gitHubWeb,
    );
  }
}
