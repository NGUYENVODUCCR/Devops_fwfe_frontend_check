import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthService {
  static const baseUrl = 'http://localhost:8080/api/auth';
  final storage = const FlutterSecureStorage();


  Future<String?> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200) {
        return null;
      } else {
        final error = jsonDecode(response.body);
        return error['message'] ?? response.body;
      }
    } catch (e) {
      return 'Đã xảy ra lỗi khi đăng ký: $e';
    }
  }


  Future<String?> login(LoginRequest request, Function(String role) onSuccess) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final token = json['token'];
        final role = json['role'];
        final username = json['username'];
        final id = json['id'];

        // ✅ Lưu đầy đủ vào storage
        await storage.write(key: 'token', value: token);
        await storage.write(key: 'role', value: role);
        await storage.write(key: 'username', value: username);
        await storage.write(key: 'id', value: id.toString());

        onSuccess(role);
        return null;
      } else {
        final json = jsonDecode(response.body);
        return json['message'] ?? 'Đăng nhập thất bại';
      }
    } catch (e) {
      return 'Lỗi đăng nhập: $e';
    }
  }

  Future<String?> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final error = jsonDecode(response.body);
        return error['message'] ?? 'Không thể gửi email khôi phục';
      }
    } catch (e) {
      return 'Lỗi gửi email: $e';
    }
  }


  Future<bool> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  Future<String?> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final error = jsonDecode(response.body);
        return error['message'] ?? 'Không thể đặt lại mật khẩu';
      }
    } catch (e) {
      return 'Lỗi đặt lại mật khẩu: $e';
    }
  }

  Future<int?> getAccountId() async {
    final idStr = await storage.read(key: 'id');
    return idStr != null ? int.tryParse(idStr) : null;
  }

  Future<bool> logout() async {
    final token = await getToken();

    if (token == null) return false;

    final url = Uri.parse('$baseUrl/logout');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await storage.delete(key: 'token');
        await storage.delete(key: 'role');
        await storage.delete(key: 'username');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }


  Future<String?> getRole() async {
    return await storage.read(key: 'role');
  }


  Future<String?> getUsername() async {
    return await storage.read(key: 'username');
  }


  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
