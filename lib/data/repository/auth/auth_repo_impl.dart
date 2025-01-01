import 'package:blog/data/models/auth/create_user_request.dart';
import 'package:blog/data/models/auth/login_user_request.dart';
import 'package:blog/data/models/auth/no_params.dart';
// import 'package:blog/data/sources/auth/auth_appwrite_service.dart';
import 'package:blog/data/sources/auth/auth_firebase_service.dart';
import 'package:blog/domain/repository/auth/auth_repo.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImplementation extends AuthRepository {
  // final AuthAppwriteService _authAppwriteService = sl<AuthAppwriteService>();
  final AuthFirebaseService _authFirebaseService = sl<AuthFirebaseService>();
  @override
  Future<Either> signIn(LoginUserRequest loginUserRequest) {
    return _authFirebaseService.signIn(loginUserRequest);
  }

  @override
  Future<Either> signUp(CreateUserRequest createUserRequest) {
    return _authFirebaseService.signUp(createUserRequest);
  }

  @override
  Future<void> logOut(NoParams noParams) async {
    return _authFirebaseService.logOut(noParams);
  }
}
