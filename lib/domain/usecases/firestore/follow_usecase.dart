import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/data/models/firestore/follow_model.dart';
import 'package:blog/domain/repository/firestore/firestore_repository.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class FollowUsecase extends Usecase<Either, FollowModel> {
  @override
  Future<Either> call({FollowModel? params}) {
    return sl<FirestoreRepository>().follow(params!);
  }
}
