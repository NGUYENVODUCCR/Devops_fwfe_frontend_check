class Account {
  final int id;
  final String username;
  final String name;
  final String email;
  final String role;
  final bool isLocked;

  Account({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    required this.isLocked,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isLocked: json['locked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'role': role,
      'locked': isLocked,
    };
  }
}
