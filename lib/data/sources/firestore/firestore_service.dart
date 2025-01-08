import 'package:blog/data/models/firestore/follow_model.dart';
import 'package:blog/data/models/firestore/profile_blog_model.dart';
import 'package:blog/data/models/firestore/profile_model.dart';
import 'package:blog/domain/entities/blog/blog_preview_entity.dart';
import 'package:blog/domain/entities/profile/blogs_entity.dart';
import 'package:blog/domain/entities/profile/profile_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

abstract class FirestoreService {
  Future<Either<String, ProfileEntity>> getProfileData(
      ProfileModel profileModel);
  Future<Either<String, BlogPreviewEntity>> getBlogData(String blogUid);
  Future<Either> follow(FollowModel followModel);
  Future<Either<String, List<ProfileBlogEntity>>> getUserBlogs(
      ProfileBlogModel profileBlogModel);
}

class FirestoreServiceImplementation extends FirestoreService {
  @override
  Future<Either<String, ProfileEntity>> getProfileData(
      ProfileModel model) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: model.username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Left('User not found');
      }

      final doc = querySnapshot.docs.first;
      final user = doc.data();

      try {
        final profileEntity = ProfileEntity(
            name: user['name'],
            email: user['email'],
            bio: user['bio'] ?? "",
            createdAt: user['createdAt'] as Timestamp,
            emailVerified: user['emailVerified'] ?? false,
            followerCount: user['followerCount'],
            followingCount: user['followingCount'],
            postCount: user['postCount'],
            followers: user['followers'] ?? [],
            following: user['following'] ?? [],
            profilePic: user['profilePic'] ?? '',
            coverPic: user['coverPic'] ?? '',
            socials: user['socials'] ?? {},
            uid: user['uid'],
            lastLogin: user['lastLogin'] as Timestamp,
            username: user['username']);
        print('entity created successfully');
        return Right(profileEntity);
      } catch (e) {
        return Left('Error parsing user data: ${e.toString()}');
      }
    } catch (e) {
      return Left('Firestore Error: ${e.toString()}');
    }
  }

  @override
  Future<Either> follow(FollowModel followModel) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      final followerDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(followModel.followerUid)
          .get();

      final followingDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(followModel.followingUid)
          .get();

      if (!followerDoc.exists || !followingDoc.exists) {
        return const Left('One or both profiles not found');
      }

      final followerData = followerDoc.data() as Map<String, dynamic>;
      final followingData = followingDoc.data() as Map<String, dynamic>;

      List following = followerData['following'] ?? [];
      List followers = followingData['followers'] ?? [];

      if (following.contains(followModel.followingUsername)) {
        return const Left('Already following this user');
      }

      batch.update(
        FirebaseFirestore.instance
            .collection('Users')
            .doc(followModel.followerUid),
        {
          'following': [...following, followModel.followingUsername],
          'followingCount': FieldValue.increment(1),
        },
      );

      batch.update(
        FirebaseFirestore.instance
            .collection('Users')
            .doc(followModel.followingUid),
        {
          'followers': [...followers, followModel.followerUsername],
          'followerCount': FieldValue.increment(1),
        },
      );

      await batch.commit();
      print('followed @${followModel.followingUsername} successfully');
      return const Right('Followed Successfully');
    } catch (e) {
      return Left('Firestore Error: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, BlogPreviewEntity>> getBlogData(String blogUid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Blogs')
          .doc(blogUid)
          .get();
      if (doc.exists) {
        final user = doc.data() as Map<String, dynamic>;
        print(doc.data());
        try {
          final profileEntity = BlogPreviewEntity(
              userUid: user['userUid'],
              blogUid: user['blogUid'],
              content: user['content'],
              title: user['title'],
              authors: user['authors'],
              authorUid: user['authorUid'],
              likedBy: (user['likedBy']),
              likes: user['likes'],
              status: user['status'],
              publishedTimestamp: user['publishedTimestamp']);
          print('blog preview entity created successfully');
          return Right(profileEntity);
        } catch (e) {
          print(e);
          return Left('failed to create entity, ${e.toString()}');
        }
      } else {
        return const Left('Blog not found');
      }
    } catch (e) {
      return Left('Firestore Error ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<ProfileBlogEntity>>> getUserBlogs(
      ProfileBlogModel profileBlogModel) async {
    List<ProfileBlogEntity> blogs = [];
    try {
      final value = await FirebaseFirestore.instance
          .collection('Blogs')
          .where('authors', arrayContains: profileBlogModel.author)
          .get();
      for (var element in value.docs) {
        blogs.add(ProfileBlogEntity(
            title: (element.data())['title'],
            authors: (element.data())['authors'],
            blogUid: (element.data())['blogUid'],
            content: (element.data())['content']));
      }
      return Right(blogs);
    } catch (error) {
      return Left('Firestore Error: ${error.toString()}');
    }
  }
}
