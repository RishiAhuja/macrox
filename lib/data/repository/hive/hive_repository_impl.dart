import 'package:blog/data/sources/hive/hive_service.dart';
import 'package:blog/domain/entities/blog/blog_entity.dart';
import 'package:blog/domain/repository/blog/blog_repository.dart';
import 'package:blog/service_locator.dart';

class BlogRepositoryImplementation extends BlogRepository {
  final HiveService hiveService = sl<HiveService>();
  @override
  Future<void> addBlog(BlogEntity entity) {
    return hiveService.addBlog(entity);
  }

  @override
  Future<Map<String, BlogEntity>> getAllBlogs() {
    return hiveService.getAllBlogs();
  }

  @override
  Future<void> updateBlog(BlogEntity entity) {
    return hiveService.updateBlog(entity);
  }
}
