import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPreviewEntity {
  final String userUid;
  final String blogUid;
  final String content;
  final String title;
  final List authors;
  final List authorUid;
  final List likedBy;
  final int likes;
  final String status;
  final Timestamp publishedTimestamp;

  BlogPreviewEntity(
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
}
