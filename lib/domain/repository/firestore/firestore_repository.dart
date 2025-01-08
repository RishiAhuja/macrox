import 'package:blog/data/models/firestore/follow_model.dart';
import 'package:blog/data/models/firestore/profile_blog_model.dart';
import 'package:blog/data/models/firestore/profile_model.dart';
import 'package:blog/domain/entities/blog/blog_preview_entity.dart';
import 'package:blog/domain/entities/profile/blogs_entity.dart';
import 'package:blog/domain/entities/profile/profile_entity.dart';
import 'package:dartz/dartz.dart';

abstract class FirestoreRepository {
  Future<Either<String, ProfileEntity>> getProfileData(
      ProfileModel profileModel);
  Future<Either> follow(FollowModel followModel);

  Future<Either<String, BlogPreviewEntity>> getBlogPreview(String uid);
  Future<Either<String, List<ProfileBlogEntity>>> getProfileBlogs(
      ProfileBlogModel profileBlogModel);
}
