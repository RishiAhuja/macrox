import 'package:blog/data/models/hive/blog_model.dart';

class BlogEntity {
  final String uid;
  final String userUid;
  final String content;
  final String htmlPreview;
  final String title;
  final bool published;

  BlogEntity(
      {required this.uid,
      required this.content,
      required this.htmlPreview,
      this.title = '',
      required this.userUid,
      required this.published});

  factory BlogEntity.fromJson(Map<String, dynamic> json) {
    return BlogEntity(
      userUid: json['userUid']?.toString() ?? '',
      uid: json['uid']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      htmlPreview: json['htmlPreview']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      published: json['published'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'htmlPreview': htmlPreview,
      'title': title,
      'uid': uid,
      'userUid': userUid,
      'published': published,
    };
  }
}

extension BlogEntityX on BlogEntity {
  BlogModel toModel() {
    return BlogModel(
      title: title,
      content: content,
      htmlPreview: htmlPreview,
      uid: uid,
      userUid: userUid,
      published: published,
    );
  }
}
