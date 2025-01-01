import 'package:blog/domain/entities/blog/blog_entity.dart';

abstract class BlogRepository {
  Future<void> addBlog(BlogEntity entity);
  Future<void> updateBlog(BlogEntity entity);
  Future<Map<String, BlogEntity>> getAllBlogs();
}
