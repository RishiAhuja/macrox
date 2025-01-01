import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/data/models/auth/no_params.dart';
import 'package:blog/domain/repository/auth/auth_repo.dart';
import 'package:blog/service_locator.dart';

class LogoutUsecase extends Usecase<void, NoParams> {
  @override
  Future<void> call({params}) {
    return sl<AuthRepository>().logOut(params!);
  }
}
