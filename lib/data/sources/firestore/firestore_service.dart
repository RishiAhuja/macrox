import 'package:blog/data/models/firestore/follow_model.dart';
import 'package:blog/data/models/firestore/profile_model.dart';
import 'package:blog/domain/entities/profile/profile_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

abstract class FirestoreService {
  Future<Either<String, ProfileEntity>> getProfileData(
      ProfileModel profileModel);
  Future<Either> follow(FollowModel followModel);
}

class FirestoreServiceImplementation extends FirestoreService {
  @override
  Future<Either<String, ProfileEntity>> getProfileData(
      ProfileModel profileModel) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(profileModel.uid)
          .get();
      if (doc.exists) {
        final user = doc.data() as Map<String, dynamic>;
        print(doc.data());
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
          print(e);
          return Left('failed to create entity, ${e.toString()}');
        }
      } else {
        return const Left('Profile not found');
      }
    } catch (e) {
      return Left('Firestore Error ${e.toString()}');
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
}
