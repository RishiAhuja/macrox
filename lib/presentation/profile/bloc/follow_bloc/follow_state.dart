part of 'follow_bloc.dart';

@immutable
sealed class FollowState {}

final class FollowInitial extends FollowState {}

final class FollowLoading extends FollowState {}

final class FollowError extends FollowState {
  final String message;

  FollowError(this.message);
}

final class FollowSuccess extends FollowState {}
