import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEntity {
  final String name;
  final String email;
  final String? bio;
  final Timestamp createdAt;
  final Timestamp? lastLogin;
  final bool emailVerified;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final List? followers;
  final List? following;
  final String? profilePic;
  final String? coverPic;
  final Map? socials;
  final String uid;
  final String username;

  ProfileEntity({
    required this.name,
    required this.email,
    this.bio,
    this.lastLogin,
    required this.createdAt,
    required this.emailVerified,
    required this.followerCount,
    required this.followingCount,
    required this.postCount,
    this.followers,
    this.following,
    this.profilePic,
    this.coverPic,
    this.socials,
    required this.uid,
    required this.username,
  });
}
