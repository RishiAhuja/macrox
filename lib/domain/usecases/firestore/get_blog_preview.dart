import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/domain/repository/firestore/firestore_repository.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class GetBlogUsecase extends Usecase<Either, String> {
  @override
  Future<Either> call({String? params}) {
    return sl<FirestoreRepository>().getBlogPreview(params!);
  }
}
