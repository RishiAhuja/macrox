import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/data/models/firestore/profile_blog_model.dart';
import 'package:blog/domain/repository/firestore/firestore_repository.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class GetProfileBlogsUsecase extends Usecase<Either, ProfileBlogModel> {
  @override
  Future<Either> call({ProfileBlogModel? params}) {
    return sl<FirestoreRepository>().getProfileBlogs(params!);
  }
}
