class RegisterRequest {
  final String username;
  final String password;
  final String confirmPassword;
  final String name;
  final String email;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'confirmPassword': confirmPassword,
    'name': name,
    'email': email,
  };
}
