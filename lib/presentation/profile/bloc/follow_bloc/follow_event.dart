part of 'follow_bloc.dart';

@immutable
sealed class FollowEvent {}

class FollowUser extends FollowEvent {
  final String followerUid;
  final String followingUid;
  final String followerUsername;
  final String followingUsername;

  FollowUser({
    required this.followerUid,
    required this.followingUid,
    required this.followerUsername,
    required this.followingUsername,
  });
}
