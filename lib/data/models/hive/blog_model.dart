import 'package:hive/hive.dart';

import '../../../domain/entities/blog/blog_entity.dart';

part 'blog_model.g.dart';

@HiveType(typeId: 0)
class BlogModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String htmlPreview;

  @HiveField(3)
  final String uid;

  @HiveField(4)
  final String userUid;

  @HiveField(5)
  final bool publishedTimestamp;

  @HiveField(6) // New field
  final String authorUid;

  @HiveField(7) // New field
  final List<String> authors;

  @HiveField(8) // New field
  final List<String> likedBy;

  BlogModel({
    required this.title,
    required this.content,
    required this.htmlPreview,
    required this.uid,
    required this.userUid,
    required this.publishedTimestamp,
    this.authorUid = '',
    this.authors = const [],
    this.likedBy = const [],
  });

  BlogEntity toEntity() {
    return BlogEntity(
      title: title,
      content: content,
      htmlPreview: htmlPreview,
      uid: uid,
      userUid: userUid,
      authorUid: authorUid,
      authors: authors,
      likedBy: likedBy,
      publishedTimestamp: publishedTimestamp,
    );
  }
}
