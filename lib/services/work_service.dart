import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'company_service.dart';

class WorkService {
 static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://fwfe.duckdns.org/api'
);

  static const String baseUrl = '$apiBaseUrl/works-posted';
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

  static Future<Map<String, dynamic>> createWork({
    required String position,
    required String descriptionWork,
    required int maxAccepted,
    required int maxReceiver,
    required double salary,
    required int companyId, // <-- truyền từ UI
  }) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode({
        'position': position,
        'descriptionWork': descriptionWork,
        'maxAccepted': maxAccepted,
        'maxReceiver': maxReceiver,
        'salary': salary,
        'companyId': companyId, // <-- dùng đúng id
      }),
    );

    print('[DEBUG] Create work response: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Tạo công việc thất bại: ${response.statusCode}');
    }
  }

//
  // static Future<List<Map<String, dynamic>>> getAllWorks() async {
  //   final headers = await _getAuthHeaders();
  //
  //   final response = await http.get(
  //     Uri.parse(baseUrl),
  //     headers: headers,
  //   );
  //
  //   print('[DEBUG] Get works response: ${response.statusCode}');
  //   print('[DEBUG] Response body: ${response.body}');
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = jsonDecode(response.body);
  //     return data.cast<Map<String, dynamic>>();
  //   } else {
  //     throw Exception('Không thể tải danh sách công việc: ${response.statusCode}');
  //   }
  // }

  static Future<List<Map<String, dynamic>>> getAllWorks() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    print('[DEBUG] Get works response: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map<Map<String, dynamic>>((e) {
        return {
          'id': e['id'],
          'position': e['position'],
          'descriptionWork': e['descriptionWork'],
          'salary': e['salary'],
          'companyId': e['companyId'],
          'company': e['companyName'],
          'createdByUsername': e['createdByUsername']
        };
      }).toList();
    } else {
      throw Exception('Không thể tải danh sách công việc: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> updateWork({
    required int id,
    required String position,
    required String descriptionWork,
    required int maxAccepted,
    required int maxReceiver,
    required double salary,
    required int companyId, // <-- truyền từ UI
  }) async {
    final headers = await _getAuthHeaders();

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: jsonEncode({
        'position': position,
        'descriptionWork': descriptionWork,
        'maxAccepted': maxAccepted,
        'maxReceiver': maxReceiver,
        'salary': salary,
        'companyId': companyId, // <-- truyền đúng công ty
      }),
    );

    print('[DEBUG] Update work response: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Bạn không có quyền cập nhật công việc này: ${response.statusCode}');
    }
  }

  static Future<void> deleteWork(int id) async {
    final headers = await _getAuthHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    print('[DEBUG] Delete work response: ${response.statusCode}');

    if (response.statusCode != 204) {
      throw Exception('Bạn không có quyền xóa công việc này: ${response.statusCode}');
    }
  }
}
