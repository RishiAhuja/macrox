import 'package:blog/domain/entities/profile/blogs_entity.dart';

abstract class LoadBlogsState {}

class BlogsInitial extends LoadBlogsState {}

class BlogsLoading extends LoadBlogsState {}

class BlogsLoaded extends LoadBlogsState {
  final List<ProfileBlogEntity> blogs;

  BlogsLoaded(this.blogs);
}

class BlogsError extends LoadBlogsState {
  final String message;
  BlogsError(this.message);
}
