import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final supportItems = [
      {
        'icon': Icons.email_outlined,
        'title': 'Trung tâm trợ giúp',
        'subtitle': 'Tìm kiếm hướng dẫn',
        'gradient': LinearGradient(colors: isDarkMode
            ? [Colors.deepPurple.shade700, Colors.blueGrey.shade700]
            : [const Color(0xFFB2F7EF), const Color(0xFFADE8F4)])
      },
      {
        'icon': Icons.edit_note_outlined,
        'title': 'Phản hồi',
        'subtitle': 'Gửi ý kiến của bạn',
        'gradient': LinearGradient(colors: isDarkMode
            ? [Colors.indigo.shade700, Colors.teal.shade700]
            : [const Color(0xFF9BE7FF), const Color(0xFFB8C0FF)])
      },
      {
        'icon': Icons.chat_bubble_outline,
        'title': 'Trò chuyện với chúng tôi',
        'subtitle': 'Nhận hỗ trợ trực tiếp từ chúng tôi',
        'gradient': LinearGradient(colors: isDarkMode
            ? [Colors.blueGrey.shade800, Colors.deepPurple.shade600]
            : [const Color(0xFFA0F1EA), const Color(0xFFBDB2FF)])
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: const Center(
              child: Text(
                'HỖ TRỢ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: supportItems.length,
              itemBuilder: (context, index) {
                final item = supportItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: item['gradient'] as LinearGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.black : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: isDarkMode ? Colors.white70 : Colors.blueAccent,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      item['subtitle'] as String,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      if (index == 0) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Theme.of(context).cardColor,
                            title: const Text('Liên hệ với chúng tôi'),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('📞 Số điện thoại: 0768471834'),
                                SizedBox(height: 8),
                                Text('📧 Email: nguyenvoduc2k4@gmail.com'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Đóng'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
