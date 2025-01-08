abstract class ProfileEvent {}

class LoadUserData extends ProfileEvent {
  final String username;
  LoadUserData({required this.username});
}
