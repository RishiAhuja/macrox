import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPublishModel {
  final String userUid;
  final String blogUid;
  final String content;
  final String title;
  final List<String> authors;
  final List<String> authorUid;
  final List<String> likedBy;
  final int likes;
  final String status;
  final FieldValue publishedTimestamp;

  BlogPublishModel(
      {required this.userUid,
      required this.blogUid,
      required this.content,
      required this.title,
      required this.authors,
      required this.authorUid,
      required this.likedBy,
      required this.likes,
      required this.status,
      required this.publishedTimestamp});

  Map<String, dynamic> toJson() {
    return {
      'userUid': userUid,
      'blogUid': blogUid,
      'content': content,
      'title': title,
      'authors': authors,
      'authorUid': authorUid,
      'likedBy': likedBy,
      'likes': likes,
      'status': status,
      'publishedTimestamp': publishedTimestamp
    };
  }
}
