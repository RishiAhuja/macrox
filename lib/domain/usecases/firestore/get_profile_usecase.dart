import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/data/models/firestore/profile_model.dart';
import 'package:blog/domain/repository/firestore/firestore_repository.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class GetProfileUsecase extends Usecase<Either, ProfileModel> {
  @override
  Future<Either> call({ProfileModel? params}) {
    return sl<FirestoreRepository>().getProfileData(params!);
  }
}
