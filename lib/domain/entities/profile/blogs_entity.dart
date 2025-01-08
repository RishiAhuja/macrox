class ProfileBlogEntity {
  final List authors;
  final String blogUid;
  final String title;
  final String content;
  ProfileBlogEntity(
      {required this.title,
      required this.content,
      required this.authors,
      required this.blogUid});
}
