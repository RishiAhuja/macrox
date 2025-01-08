import 'package:flutter/foundation.dart';

@immutable
sealed class EditProfileEvent {}

class UpdateProfile extends EditProfileEvent {
  final String name;
  final String username;
  final String bio;
  final Map socials;

  UpdateProfile({
    required this.name,
    required this.username,
    required this.bio,
    required this.socials,
  });
}
