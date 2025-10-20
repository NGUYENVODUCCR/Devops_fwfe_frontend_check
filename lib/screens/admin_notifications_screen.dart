import 'package:flutter/material.dart';
import '../services/GlobalContext.dart';
import 'ww_screen.dart';
import 'admin_screen.dart';
import '../services/private_chat_service.dart';
import 'private_inbox_screen.dart';
import '../services/auth_service.dart';
import 'report_list_screen.dart';


class AdminNotificationsScreen extends StatefulWidget {
  final PrivateChatService chatService;

  const AdminNotificationsScreen({
    super.key,
    required this.chatService,
  });

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  String _username = '';

  List<Map<String, String>> notifications = [
    {
      'title': 'Tài khoản mới',
      'message': 'Người dùng Nguyễn Văn A vừa đăng ký tài khoản.',
      'time': '5 phút trước'
    },
    {
      'title': 'Báo cáo lỗi',
      'message': 'Người dùng đã báo cáo lỗi hệ thống.',
      'time': '1 giờ trước'
    },
    {
      'title': 'Xác minh email',
      'message': 'Tài khoản user123 đã xác minh email thành công.',
      'time': 'Hôm qua'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final authService = AuthService();
    final name = await authService.getUsername();
    if (name != null && name.isNotEmpty) {
      setState(() {
        _username = name;
      });
      GlobalContext.currentUsername = name;
      GlobalContext.chatService = widget.chatService;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("THÔNG BÁO"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _username.isEmpty
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrivateInboxScreen(
                      currentUsername: _username,
                      chatService: widget.chatService,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9D4EDD),
              ),
              icon: const Icon(Icons.mail, color: Colors.white),
              label: const Text('Hộp thư riêng', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportListScreen(), // gọi màn hình vừa tạo
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              icon: const Icon(Icons.report, color: Colors.white),
              label: const Text('Xem báo cáo', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đánh dấu tất cả đã đọc')),
                  );
                },
                child: const Text('Đánh dấu tất cả đã đọc', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.deepPurple),
                      title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item['message'] ?? ''),
                      trailing: Text(item['time'] ?? '', style: const TextStyle(fontSize: 12)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/admin/create');
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/admin/profile');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/admin/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Quản lý tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Thêm tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản của tôi'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildCircleButton(
            label: "AD",
            gradientColors: [Color(0xFFF48FB1), Color(0xFFFFC107)],
            borderColor: Colors.deepPurple,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          buildCircleButton(
            label: "WW",
            gradientColors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
            borderColor: Colors.pink,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WWScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildCircleButton({
    required String label,
    required List<Color> gradientColors,
    required Color borderColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: FloatingActionButton(
        heroTag: label,
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
