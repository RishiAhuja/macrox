abstract class BlogState {}

class BlogInitial extends BlogState {}

class BlogEditing extends BlogState {
  final String content;
  final String htmlPreview;
  final String title;

  BlogEditing(
      {required this.content, required this.htmlPreview, required this.title});
}

class BlogSaving extends BlogState {}

class BlogSaved extends BlogState {}
