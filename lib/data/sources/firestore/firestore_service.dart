import 'package:blog/data/models/profile/profile_model.dart';
import 'package:blog/domain/entities/profile/profile_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

abstract class FirestoreService {
  Future<Either<String, ProfileEntity>> getProfileData(
      ProfileModel profileModel);
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
}
