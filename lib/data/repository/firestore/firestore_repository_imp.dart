import 'package:blog/data/models/profile/profile_model.dart';
import 'package:blog/data/sources/firestore/firestore_service.dart';
import 'package:blog/domain/entities/profile/profile_entity.dart';
import 'package:blog/domain/repository/firestore/firestore_repository.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class FirestoreRepositoryImp extends FirestoreRepository {
  @override
  Future<Either<String, ProfileEntity>> getProfileData(
      ProfileModel profileModel) {
    return sl<FirestoreService>().getProfileData(profileModel);
  }
}
