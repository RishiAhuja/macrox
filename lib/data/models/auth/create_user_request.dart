class CreateUserRequest {
  final String email;
  final String password;
  final String name;
  final String username;

  CreateUserRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.username,
  });
}
