import 'package:appwrite/appwrite.dart';
import 'package:blog/data/models/auth/create_user_request.dart';
import 'package:blog/data/models/auth/login_user_request.dart';
import 'package:blog/data/models/auth/no_params.dart';
import 'package:blog/data/sources/appwrite/appwrite.dart';
import 'package:blog/data/sources/appwrite/appwrite_constants.dart';
import 'package:blog/domain/entities/auth/user_entity.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

abstract class AuthAppwriteService {
  Future<Either<String, UserEntity>> signUp(
      CreateUserRequest createUserRequest);
  Future<Either<String, UserEntity>> signIn(LoginUserRequest loginUserRequest);
  Future<Either<String, bool>> storeUserInDatabase(UserEntity user);
  Future<void> logOut(NoParams noParms);
}

class AuthAppwriteServiceImplementation implements AuthAppwriteService {
  final Account _account;
  final Databases _databases;
  static const String databaseId = AppwriteConstants.databaseId;
  static const String collectionId = AppwriteConstants.databaseCollection;
  final Appwrite _appwrite = sl<Appwrite>();

  AuthAppwriteServiceImplementation({
    required Account account,
    required Databases databases,
  })  : _account = account,
        _databases = databases;

  @override
  Future<Either<String, bool>> storeUserInDatabase(UserEntity user) async {
    try {
      await _databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: user.id,
        data: {
          'email': user.email,
          'name': user.name,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      return const Right(true);
    } on AppwriteException catch (_) {
      return const Right(false);
    }
  }

  @override
  Future<Either<String, UserEntity>> signUp(
      CreateUserRequest createUserRequest) async {
    try {
      final account = await _appwrite.account.create(
        userId: ID.unique(),
        email: createUserRequest.email,
        password: createUserRequest.password,
        name: createUserRequest.name,
      );

      final userEntity = UserEntity(
          id: account.$id,
          email: account.email,
          name: account.name,
          username: createUserRequest.username);

      // Create session
      final sessionResult = await signIn(
        LoginUserRequest(
          email: createUserRequest.email,
          password: createUserRequest.password,
        ),
      );

      return await sessionResult.fold(
        (error) async {
          // Cleanup on session creation failure
          await _appwrite.account.deleteSession(sessionId: 'current');
          return Left('Failed to create session: $error');
        },
        (user) async {
          // Store in database
          final dbResult = await storeUserInDatabase(userEntity);

          return dbResult.fold(
            (error) async {
              // Cleanup on database storage failure
              await _account.deleteSession(sessionId: 'current');
              return Left('Failed to store user data: $error');
            },
            (success) => Right(userEntity),
          );
        },
      );
    } on AppwriteException catch (e) {
      return Left(_mapAppwriteError(e));
    } catch (e, _) {
      return Left('Unexpected error occurred: ${e.toString()}');
    }
  }

  String _mapAppwriteError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Unauthorized - Please check your credentials';
      case 409:
        return 'User already exists with this email';
      case 429:
        return 'Too many requests - Please try again later';
      case 400:
        return 'Invalid email or password format';
      case 503:
        return 'Service unavailable - Please try again later';
      default:
        return 'Connection error: ${e.message}';
    }
  }

  @override
  Future<Either<String, UserEntity>> signIn(
      LoginUserRequest loginUserRequest) async {
    try {
      // Create email session with Appwrite
      await _appwrite.account.createEmailSession(
        email: loginUserRequest.email,
        password: loginUserRequest.password,
      );

      // Get user account details after successful session
      final account = await _appwrite.account.get();

      // Create UserEntity from account data
      // Note: Using temporary placeholder for username until proper implementation
      final userEntity = UserEntity(
        id: account.$id,
        email: account.email,
        name: account.name, // Fallback if name is null
        username: account.$id, // Temporary: using ID as username
      );

      return Right(userEntity);
    } on AppwriteException catch (e) {
      // Handle Appwrite specific exceptions
      return Left(_mapAppwriteError(e));
    } catch (e, _) {
      // Handle unexpected errors
      return Left('Unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> logOut(NoParams noParms) async {
    return await _appwrite.account.deleteSession(sessionId: 'current');
  }
}
