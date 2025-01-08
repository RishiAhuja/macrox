abstract class LoadBlogsEvent {}

class LoadUserBlogs extends LoadBlogsEvent {
  final String username;
  LoadUserBlogs({required this.username});
}
