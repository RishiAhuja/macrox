class UserEntity {
  final String email;
  final String name;
  final String id;
  final String username;

  UserEntity({
    required this.username,
    required this.email,
    required this.name,
    required this.id,
  });

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, name: $name)';
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      username: map['username']?.toString() ?? '',
      id: map['\$id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
    );
  }
}

extension UserEntityX on UserEntity {
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      '\$id': id,
      'username': username,
    };
  }
}
