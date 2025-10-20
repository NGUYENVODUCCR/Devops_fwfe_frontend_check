import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/work_acceptance_service.dart';
import '../services/report_service.dart';


class ListWorkAcceptScreen extends StatefulWidget {
  final int workId;
  final String createdByUsername;

  const ListWorkAcceptScreen({super.key, required this.workId, required this.createdByUsername,});

  @override
  State<ListWorkAcceptScreen> createState() => _ListWorkAcceptScreenState();
}

class _ListWorkAcceptScreenState extends State<ListWorkAcceptScreen> {
  late Future<List<dynamic>> _futureAcceptances;
  String? currentUserRole;
  final AuthService _authService = AuthService();
  String? currentUsername;


  @override
  void initState() {
    super.initState();
    loadUserRole();
    loadUserInfo();
    _futureAcceptances = WorkAcceptanceService.getAcceptancesByWork(widget.workId);
  }

  Future<void> loadUserInfo() async {
    final role = await _authService.getRole();
    final username = await _authService.getUsername();

    setState(() {
      currentUserRole = role;
      currentUsername = username;
    });
  }

  Future<void> loadUserRole() async {
    final role = await _authService.getRole();
    setState(() {
      currentUserRole = role;
    });
  }

  void _showReportDialog(int reportedAccountId) {
    final TextEditingController _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Báo cáo người dùng'),
          content: TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Lý do báo cáo',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = _reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập lý do')),
                  );
                  return;
                }

                final success = await ReportService.reportUser(
                  reportedAccountId: reportedAccountId,
                  reason: reason,
                );

                Navigator.of(context).pop(); // Đóng dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Báo cáo thành công' : 'Báo cáo thất bại',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Gửi báo cáo'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus(int acceptanceId, String newStatus) async {
    try {
      final success = await WorkAcceptanceService.updateAcceptanceStatus(
        widget.workId,
        acceptanceId,
        newStatus,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật trạng thái thành công')),
        );
        setState(() {
          _futureAcceptances = WorkAcceptanceService.getAcceptancesByWork(widget.workId);
        });
      }
    } catch (e) {
      print('Lỗi cập nhật trạng thái: $e');
      // Hiển thị lỗi chi tiết từ server
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    }
  }



  final List<String> statusOptions = ['PENDING', 'COMPLETED', 'CANCELLED'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách người đã nhận việc')),
      body: FutureBuilder<List<dynamic>>(
        future: _futureAcceptances,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final acceptances = snapshot.data ?? [];

          if (acceptances.isEmpty) {
            return const Center(child: Text('Chưa có người nào nhận việc.'));
          }

          return ListView.builder(
            itemCount: acceptances.length,
            itemBuilder: (context, index) {
              final user = acceptances[index];
              final int acceptanceId = user['id'];
              final String currentStatus = user['status'] ?? 'PENDING';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user['accountUsername'] ?? 'Không rõ'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vị trí: ${user['position'] ?? ''}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('Trạng thái: '),
                          DropdownButton<String>(
                            value: currentStatus,
                            onChanged: (value) {
                              if (value != null && value != currentStatus) {
                                _updateStatus(acceptanceId, value);
                              }
                            },
                            items: statusOptions.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 4),
                          if ((currentUserRole == 'ROLE_ADMIN' || currentUserRole == 'ROLE_MANAGER') &&
                              currentUsername == widget.createdByUsername)
                          ElevatedButton.icon(
                            onPressed: () => _showReportDialog(user['accountId']),
                            icon: const Icon(Icons.report, color: Colors.white),
                            label: const Text('Báo cáo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              minimumSize: const Size(120, 36),
                            ),
                          ),
                        ],
                      ),
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
