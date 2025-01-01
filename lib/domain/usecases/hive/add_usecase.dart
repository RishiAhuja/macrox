import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/domain/repository/blog/blog_repository.dart';
import 'package:blog/service_locator.dart';

class AddUsecase extends Usecase {
  @override
  Future<void> call({params}) {
    return sl<BlogRepository>().addBlog(params!);
  }
}
