import 'package:blog/data/models/hive/blog_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogEntity {
  final String uid;
  final String userUid;
  final String authorUid; // Added authorUid
  final List<String> authors; // Added authors list
  final List<String> likedBy; // Added likedBy list
  final String content;
  final String htmlPreview;
  final String title;
  final bool publishedTimestamp;

  BlogEntity({
    required this.uid,
    required this.content,
    required this.htmlPreview,
    this.title = '',
    required this.userUid,
    this.authorUid = '', // Default value
    this.authors = const [], // Default empty list
    this.likedBy = const [], // Default empty list
    required this.publishedTimestamp,
  });

  factory BlogEntity.fromJson(Map<String, dynamic> json) {
    // Handle authors list
    List<String> authorsList = [];
    if (json['authors'] != null) {
      if (json['authors'] is List) {
        authorsList = List<String>.from(json['authors']);
      } else if (json['authors'] is String) {
        // If somehow authors is a single string
        authorsList = [json['authors'] as String];
      }
    }

    // Handle likedBy list
    List<String> likedByList = [];
    if (json['likedBy'] != null) {
      if (json['likedBy'] is List) {
        likedByList = List<String>.from(json['likedBy']);
      } else if (json['likedBy'] is String) {
        // If somehow likedBy is a single string
        likedByList = [json['likedBy'] as String];
      }
    }

    return BlogEntity(
      userUid: json['userUid']?.toString() ?? '',
      uid: json['uid']?.toString() ?? '',
      authorUid: json['authorUid']?.toString() ?? '', // Add authorUid
      authors: authorsList, // Add authors
      likedBy: likedByList, // Add likedBy
      content: json['content']?.toString() ?? '',
      htmlPreview: json['htmlPreview']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      publishedTimestamp: json['publishedTimestamp'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'htmlPreview': htmlPreview,
      'title': title,
      'uid': uid,
      'userUid': userUid,
      'authorUid': authorUid, // Add authorUid
      'authors': authors, // Add authors
      'likedBy': likedBy, // Add likedBy
      'published': publishedTimestamp,
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
      authorUid: authorUid, // Add authorUid
      authors: authors, // Add authors
      likedBy: likedBy, // Add likedBy
      publishedTimestamp: publishedTimestamp,
    );
  }
}

extension BlogEntityFirestoreX on BlogEntity {
  // Convert Firestore data to BlogEntity
  static BlogEntity fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Handle authors list
    List<String> authorsList = [];
    if (data['authors'] != null) {
      if (data['authors'] is List) {
        authorsList = List<String>.from(data['authors']);
      } else if (data['authors'] is String) {
        // If somehow authors is a single string
        authorsList = [data['authors'] as String];
      }
    }

    // Handle likedBy list
    List<String> likedByList = [];
    if (data['likedBy'] != null) {
      if (data['likedBy'] is List) {
        likedByList = List<String>.from(data['likedBy']);
      } else if (data['likedBy'] is Map) {
        // Sometimes Firebase stores maps for keys with true values
        likedByList = (data['likedBy'] as Map).keys.cast<String>().toList();
      } else if (data['likedBy'] is String) {
        // If somehow likedBy is a single string
        likedByList = [data['likedBy'] as String];
      }
    }

    return BlogEntity(
      uid: doc.id,
      userUid: data['userUid']?.toString() ?? '',
      authorUid: data['authorUid']?.toString() ?? '', // Add authorUid
      authors: authorsList, // Add authors
      likedBy: likedByList, // Add likedBy
      content: data['content']?.toString() ?? '',
      htmlPreview: data['htmlPreview']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      publishedTimestamp: data['publishedTimestamp'] as bool? ?? false,
    );
  }
}
