import 'package:blog/domain/entities/profile/profile_entity.dart';

abstract class ProfileState {}

class UserInitial extends ProfileState {}

class UserLoading extends ProfileState {}

class UserLoaded extends ProfileState {
  final ProfileEntity userData;
  UserLoaded(this.userData);
}

class UserError extends ProfileState {
  final String message;
  UserError(this.message);
}
