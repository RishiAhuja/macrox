import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/domain/entities/blog/blog_entity.dart';
import 'package:blog/domain/repository/blog/blog_repository.dart';
import 'package:blog/service_locator.dart';

class GetAllUsecase extends Usecase {
  @override
  Future<Map<String, BlogEntity>> call({params}) {
    return sl<BlogRepository>().getAllBlogs();
  }
}
