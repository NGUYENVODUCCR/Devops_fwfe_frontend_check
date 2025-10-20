import 'package:flutter/material.dart';
import 'package:fwfe/screens/private_inbox_screen.dart';
import 'package:fwfe/services/private_chat_service.dart';
import 'package:fwfe/services/auth_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = PrivateChatService();

    final List<Map<String, dynamic>> notifications = [
      {
        'icon': Icons.remove_red_eye,
        'color': Colors.lightBlueAccent,
        'title': 'Công ty ABC đã xem hồ sơ của bạn',
        'time': '30 phút trước'
      },
      {
        'icon': Icons.check_circle,
        'color': Colors.cyan,
        'title': 'Đơn ứng tuyển của bạn vào vị trí này đã được chấp nhận',
        'time': '30 phút trước'
      },
      {
        'icon': Icons.cancel,
        'color': Colors.lightBlue,
        'title': 'Đơn ứng tuyển của bạn vào vị trí này đã bị từ chối',
        'time': '30 phút trước'
      },
      {
        'icon': Icons.work,
        'color': Colors.blue,
        'title': 'Việc làm mới: Thư ký cho giám đốc (nam giới)',
        'time': '30 phút trước'
      },
    ];

    return FutureBuilder<String?>(
      future: AuthService().getUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Không thể xác định người dùng')),
          );
        }

        final currentUsername = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9D4EDD), Color(0xFF40C9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Thông báo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Nút mở Hộp thư riêng
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrivateInboxScreen(
                          currentUsername: currentUsername,
                          chatService: chatService,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9D4EDD),
                  ),
                  icon: const Icon(Icons.mail, color: Colors.white),
                  label: const Text(
                    'Hộp thư riêng',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              // Nút đánh dấu đã đọc
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Container(
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
                    child: const Text(
                      'Đánh dấu tất cả đã đọc',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Danh sách thông báo
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item['color'],
                            ),
                            child: Icon(item['icon'], color: Colors.white),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['time'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
