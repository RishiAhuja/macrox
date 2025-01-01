import 'package:blog/data/models/hive/blog_model.dart';

class BlogEntity {
  final String uid;
  final String content;
  final String htmlPreview;
  final String title;

  BlogEntity(
      {required this.uid,
      required this.content,
      required this.htmlPreview,
      this.title = ''});

  factory BlogEntity.fromJson(Map<String, dynamic> json) {
    return BlogEntity(
      uid: json['uid']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      htmlPreview: json['htmlPreview']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'htmlPreview': htmlPreview,
      'title': title,
      'uid': uid
    };
  }
}

extension BlogEntityX on BlogEntity {
  BlogModel toModel() {
    return BlogModel(
        title: title, content: content, htmlPreview: htmlPreview, uid: uid);
  }
}
