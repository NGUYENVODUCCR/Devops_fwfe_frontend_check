class LoginResponse {
  final String token;
  final String role;
  final String message;

  LoginResponse({required this.token, required this.role, required this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      role: json['role'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
