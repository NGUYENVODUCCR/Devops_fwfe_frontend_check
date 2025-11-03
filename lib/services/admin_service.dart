import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account.dart';

class AdminService {
  final String apiBaseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://fwfe.duckdns.org/api');
  
  late final String baseUrl = '$apiBaseUrl/admin';

  Future<List<Account>> getAllAccounts(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Account.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load accounts');
    }
  }

  Future<void> lockUser(int id, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/lock/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('Lock response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to lock user');
    }
  }

  Future<void> unlockUser(int id, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/unlock/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('Unlock response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to unlock user');
    }
  }

  Future<void> deleteUser(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('Delete response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  Future<void> updateUser(
      int id,
      String name,
      String email,
      String role,     // ← thêm role
      bool locked,
      String token,
      {String updatedBy = "admin"}
      ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'role': role,          // ← thêm vào JSON
        'locked': locked,
        'updatedBy': updatedBy,
      }),
    );

    print('Update user response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }



  Future<Account> getAccountById(int id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200 && response.body.isNotEmpty &&
        response.body != 'null') {
      return Account.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load account info: ${response.body}');
    }
  }

  Future<void> changePassword(String oldPass, String newPass, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPass,
        'newPassword': newPass,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Đổi mật khẩu thất bại');
    }
  }



  Future<void> createUser({
    required String name,
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    required String role,
    required String token,
    Map<String, dynamic>? company,
  }) async {
    final Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'confirmPassword': confirmPassword,
      'role': role,
    };

    if (role == "ROLE_MANAGER" && company != null) {
      body['company'] = company;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/create-account'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('Create user response: ${response.statusCode} - ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Tạo tài khoản thất bại: ${response.body}');
    }
  }
}


