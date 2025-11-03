import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class CompanyService {
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://fwfe.duckdns.org/api');

  static const String baseUrl = '$apiBaseUrl/companies';

  static const _storage = FlutterSecureStorage();


  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'token');

    if (token == null) {
      print('[DEBUG] Không tìm thấy token trong FlutterSecureStorage');
      throw Exception('Không tìm thấy token.');
    }

    final decodedToken = JwtDecoder.decode(token);
    final username = decodedToken['sub'];
    final role = decodedToken['role'];

    print('[DEBUG] Token: $token');
    print('[DEBUG] Username: $username');
    print('[DEBUG] Role: $role');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Username': username,
      'X-Role': role,
    };
  }


  static Future<Map<String, dynamic>> createCompany({
    required String name,
    required String descriptionCompany,
    required String type,
    required String address,
  }) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'descriptionCompany': descriptionCompany,
        'type': type,
        'address': address,
      }),
    );

    print('[DEBUG] Create company response: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Tạo công ty thất bại: ${response.statusCode}');
    }
  }


  static Future<List<Map<String, dynamic>>> getMyCompanies() async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/my'),
      headers: headers,
    );

    print('[DEBUG] Get my companies response: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Không thể tải công ty của bạn: ${response.statusCode}');
    }
  }


  static Future<List<Map<String, dynamic>>> getAllCompanies() async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: headers,
    );

    print('[DEBUG] Get all companies response: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Không thể tải danh sách công ty: ${response.statusCode}');
    }
  }


  static Future<Map<String, dynamic>> getCompanyById(int id) async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    print('[DEBUG] Get company by ID response: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể tải chi tiết công ty: ${response.statusCode}');
    }
  }


  static Future<Map<String, dynamic>> updateCompany({
    required int id,
    required String name,
    required String descriptionCompany,
    required String type,
    required String address,
  }) async {
    final headers = await _getAuthHeaders();

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'descriptionCompany': descriptionCompany,
        'type': type,
        'address': address,
      }),
    );

    print('[DEBUG] Update company response: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Cập nhật công ty thất bại: ${response.statusCode}');
    }
  }


  static Future<void> deleteCompany(int id) async {
    final headers = await _getAuthHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    print('[DEBUG] Delete company response: ${response.statusCode}');

    if (response.statusCode != 204) {
      throw Exception('Xóa công ty thất bại: ${response.statusCode}');
    }
  }
}
