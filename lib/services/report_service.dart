import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReportService {
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://fwfe.duckdns.org/api');
  static const String baseUrl = '$apiBaseUrl/reports';
 
  static final storage = FlutterSecureStorage();

  // Gửi báo cáo người dùng
  static Future<bool> reportUser({
    required int reportedAccountId,
    required String reason,
  }) async {
    final token = await storage.read(key: 'token');
    final username = await storage.read(key: 'username');

    final url = Uri.parse('$baseUrl');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Username': username ?? '',
    };
    final body = jsonEncode({
      'reportedAccountId': reportedAccountId,
      'reason': reason,
    });

    final response = await http.post(url, headers: headers, body: body);
    return response.statusCode == 200;
  }

  // Lấy danh sách báo cáo chưa xử lý (chỉ ADMIN)
  static Future<List<Map<String, dynamic>>> getUnresolvedReports() async {
    final token = await storage.read(key: 'token');

    final url = Uri.parse('$baseUrl/unresolved');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Không thể tải danh sách báo cáo');
    }
  }
}
