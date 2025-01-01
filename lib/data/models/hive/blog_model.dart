import 'package:hive/hive.dart';

part 'blog_model.g.dart';

@HiveType(typeId: 0)
class BlogModel extends HiveObject {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String content;
  @HiveField(3)
  final String htmlPreview;

  BlogModel(
      {required this.title,
      required this.content,
      required this.htmlPreview,
      required this.uid});
}
