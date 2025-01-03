import 'package:blog/data/models/profile/profile_model.dart';
import 'package:blog/domain/entities/profile/profile_entity.dart';
import 'package:dartz/dartz.dart';

abstract class FirestoreRepository {
  Future<Either<String, ProfileEntity>> getProfileData(
      ProfileModel profileModel);
}
