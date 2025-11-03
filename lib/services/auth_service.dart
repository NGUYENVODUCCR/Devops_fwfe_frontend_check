import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthService {
  // Nếu không build với --dart-define, dùng giá trị mặc định
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://fwfe.duckdns.org/api'
  );

  static const String baseUrl = '$apiBaseUrl/auth';
  
  final storage = const FlutterSecureStorage();

  // ====================== REGISTER ======================
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

  // ====================== LOGIN ======================
  Future<String?> login(LoginRequest request, Function(String role) onSuccess) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Kiểm tra null trước khi lưu vào storage
        final token = jsonData['token'] as String?;
        final role = jsonData['role'] as String?;
        final username = jsonData['username'] as String?;
        final id = jsonData['id'];

        print("DEBUG LOGIN RESPONSE: $jsonData");

        if (token == null || role == null || username == null || id == null) {
          return 'Dữ liệu đăng nhập không đầy đủ từ server';
        }

        // Lưu vào storage
        await storage.write(key: 'token', value: token);
        await storage.write(key: 'role', value: role);
        await storage.write(key: 'username', value: username);
        await storage.write(key: 'id', value: id.toString());

        onSuccess(role);
        return null;
      } else {
        final jsonData = jsonDecode(response.body);
        return jsonData['message'] ?? 'Đăng nhập thất bại';
      }
    } catch (e) {
      return 'Lỗi đăng nhập: $e';
    }
  }

  // ====================== FORGOT PASSWORD ======================
  Future<String?> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) return null;

      final error = jsonDecode(response.body);
      return error['message'] ?? 'Không thể gửi email khôi phục';
    } catch (e) {
      return 'Lỗi gửi email: $e';
    }
  }

  // ====================== VERIFY CODE ======================
  Future<bool> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ====================== RESET PASSWORD ======================
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
      if (response.statusCode == 200) return null;

      final error = jsonDecode(response.body);
      return error['message'] ?? 'Không thể đặt lại mật khẩu';
    } catch (e) {
      return 'Lỗi đặt lại mật khẩu: $e';
    }
  }

  // ====================== GET ACCOUNT ID ======================
  Future<int?> getAccountId() async {
    final idStr = await storage.read(key: 'id');
    if (idStr == null) return null;

    final id = int.tryParse(idStr);
    return id;
  }

  // ====================== LOGOUT ======================
  Future<bool> logout() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        await storage.delete(key: 'token');
        await storage.delete(key: 'role');
        await storage.delete(key: 'username');
        await storage.delete(key: 'id');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ====================== STORAGE HELPERS ======================
  Future<String?> getToken() async => await storage.read(key: 'token');
  Future<String?> getRole() async => await storage.read(key: 'role');
  Future<String?> getUsername() async => await storage.read(key: 'username');
  Future<bool> isLoggedIn() async => (await getToken()) != null;
}
