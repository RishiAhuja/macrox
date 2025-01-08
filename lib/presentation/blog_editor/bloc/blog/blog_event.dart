abstract class BlogEvent {}

class ContentChanged extends BlogEvent {
  final String content;
  final String title;
  ContentChanged({required this.content, required this.title});
}

class SaveDraft extends BlogEvent {
  final String uid;
  final String content;
  final String title;
  final String htmlPreview;
  final String userUid;
  final bool published;
  SaveDraft(
      {required this.uid,
      required this.content,
      required this.title,
      required this.htmlPreview,
      required this.userUid,
      required this.published});
}
