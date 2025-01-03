class FollowModel {
  final String followerUid;
  final String followerUsername;
  final String followingUid;
  final String followingUsername;

  FollowModel({
    required this.followerUid,
    required this.followingUid,
    required this.followerUsername,
    required this.followingUsername,
  });
}
