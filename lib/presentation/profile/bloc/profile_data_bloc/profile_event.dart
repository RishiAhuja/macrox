abstract class ProfileEvent {}

class LoadUserData extends ProfileEvent {
  final String userUid;
  LoadUserData(this.userUid);
}
