import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/data/models/auth/create_user_request.dart';
import 'package:blog/domain/repository/auth/auth_repo.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class SignupUsecase extends Usecase<Either, CreateUserRequest> {
  @override
  Future<Either> call({CreateUserRequest? params}) {
    return sl<AuthRepository>().signUp(params!);
  }
}
