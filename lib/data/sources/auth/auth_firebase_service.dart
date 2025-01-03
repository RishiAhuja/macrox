import 'package:blog/data/models/auth/login_user_request.dart';
import 'package:blog/data/models/auth/no_params.dart';
import 'package:blog/domain/entities/auth/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blog/data/models/auth/create_user_request.dart';

abstract class AuthFirebaseService {
  Future<Either> signIn(LoginUserRequest signinUserRequest);
  Future<Either> signUp(CreateUserRequest createUserRequest);
  Future<void> logOut(NoParams noParams);
}

class AuthFirebaseServiceImplementation extends AuthFirebaseService {
  @override
  Future<void> logOut(NoParams noParams) async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      print('Logout Error: ${e.message}');
      throw Exception('Failed to logout: ${e.message}');
    }
  }

  @override
  Future<Either> signIn(LoginUserRequest signinUserRequest) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: signinUserRequest.email, password: signinUserRequest.password);

      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final userEntity = UserEntity(
          username: (docSnapshot.data())!['username'],
          email: signinUserRequest.email,
          name: (docSnapshot.data())!['name'],
          id: FirebaseAuth.instance.currentUser!.uid);
      return Right(userEntity);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'User not found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided, please try again.';
      }
      return Left(message);
    }
  }

  @override
  Future<Either<String, UserEntity>> signUp(CreateUserRequest request) async {
    try {
      // Check if username is available
      final usernameDoc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(request.username)
          .get();

      if (usernameDoc.exists) {
        return const Left('Username already taken');
      }

      // Create user
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );

      // Store user data
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set({
        'email': request.email,
        'name': request.name,
        'username': request.username,
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'followerCount': 0,
        'followingCount': 0,
        'followers': [],
        'following': [],
        'postCount': 0,
        'bio': '',
        'profilePic': '',
        'coverPic': '',
        'socials': {
          'twitter': 'https://x.com/',
          'instagram': 'https://instagram.com/',
          'github': 'https://github.com/',
          'linkedin': 'https://linkedin.com/',
        },
        'emailVerified': false,
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Reserve username
      await FirebaseFirestore.instance
          .collection('usernames')
          .doc(request.username)
          .set({
        'uid': userCredential.user!.uid,
      });

      return Right(UserEntity(
        id: userCredential.user!.uid,
        email: request.email,
        name: request.name,
        username: request.username,
      ));
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Sign up failed');
    }
  }
}
