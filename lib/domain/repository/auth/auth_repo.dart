import 'package:blog/data/models/auth/create_user_request.dart';
import 'package:blog/data/models/auth/login_user_request.dart';
import 'package:blog/data/models/auth/no_params.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either> signUp(CreateUserRequest createUserRequest);
  Future<Either> signIn(LoginUserRequest loginUserRequest);
  Future<void> logOut(NoParams noParams);
}
