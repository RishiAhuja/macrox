abstract class PreviewEvent {}

class LoadBlogPreview extends PreviewEvent {
  final String userUid;
  LoadBlogPreview(this.userUid);
}
