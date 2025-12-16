import 'package:flutter/material.dart';
import '../services/report_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/admin_service.dart';


class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  late Future<List<Map<String, dynamic>>> _futureReports;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final AdminService _adminService = AdminService();


  @override
  void initState() {
    super.initState();
    _futureReports = ReportService.getUnresolvedReports();
  }

  Future<void> _handleLockUser(int userId, bool isLocked) async {
    final token = await _storage.read(key: 'token');
    if (token == null) return;

    try {
      if (isLocked) {
        await _adminService.unlockUser(userId, token);
      } else {
        await _adminService.lockUser(userId, token);
      }

      setState(() {
        _futureReports = ReportService.getUnresolvedReports();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLocked ? 'Đã mở khóa tài khoản' : 'Đã khóa tài khoản')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách báo cáo')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureReports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('Không có báo cáo nào.'));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text(
                            'Chi tiết báo cáo',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('👤 Người báo cáo: ${report['reporterUsername'] ?? 'Ẩn'}'),
                      Text('🙍 Người bị báo cáo: ${report['reportedUsername'] ?? 'Ẩn'}'),
                      const SizedBox(height: 6),
                      Text('📝 Lý do: ${report['reason'] ?? 'Không rõ'}'),
                      Text('🕒 Thời gian: ${report['reportedAt'] ?? 'Không rõ'}'),
                      const SizedBox(height: 6),
                      Text(
                        '📌 Trạng thái: ${report['resolved'] == true ? 'Đã xử lý' : 'Chưa xử lý'}',
                        style: TextStyle(
                          color: report['resolved'] == true ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: Icon(report['reportedLocked'] == true ? Icons.lock_open : Icons.lock),
                          label: Text(report['reportedLocked'] == true ? 'Mở khóa' : 'Khóa'),
                          onPressed: () {
                            final reportedId = report['reportedId'];
                            final isLocked = report['reportedLocked'] == true;
                            _handleLockUser(reportedId, isLocked);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: report['reportedLocked'] == true ? Colors.green : Colors.red,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
