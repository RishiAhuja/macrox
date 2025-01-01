abstract class AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String username;

  SignUpRequested({
    required this.username,
    required this.name,
    required this.email,
    required this.password,
  });
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({
    required this.email,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {}
