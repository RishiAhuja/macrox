import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/data/models/auth/login_user_request.dart';
import 'package:blog/domain/repository/auth/auth_repo.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class SigninUsecase extends Usecase<Either, LoginUserRequest> {
  @override
  Future<Either> call({LoginUserRequest? params}) {
    return sl<AuthRepository>().signIn(params!);
  }
}
