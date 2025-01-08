import 'package:flutter/foundation.dart';

@immutable
sealed class EditProfileState {}

final class EditProfileInitial extends EditProfileState {}

final class EditProfileLoading extends EditProfileState {}

final class EditProfileError extends EditProfileState {
  final String message;

  EditProfileError(this.message);
}

final class EditProfileSuccess extends EditProfileState {}
