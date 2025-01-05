import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/domain/repository/blog/blog_repository.dart';
import 'package:blog/service_locator.dart';

class ClearDataUsecase extends Usecase {
  @override
  Future<int> call({params}) {
    return sl<BlogRepository>().clearBox();
  }
}
