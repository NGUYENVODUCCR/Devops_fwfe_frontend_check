import 'package:flutter/material.dart';
import 'package:fwfe/screens/private_chat_screen.dart';
import 'package:fwfe/services/private_chat_service.dart';

class PrivateInboxScreen extends StatelessWidget {
  final String currentUsername;
  final PrivateChatService chatService;

  const PrivateInboxScreen({
    super.key,
    required this.currentUsername,
    required this.chatService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📥 Hộp thư riêng')),
      body: FutureBuilder<List<String>>(
        future: chatService.getPrivateSenders(currentUsername),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có tin nhắn riêng nào.'));
          }

          final senders = snapshot.data!;
          return ListView.builder(
            itemCount: senders.length,
            itemBuilder: (context, index) {
              final receiverUsername = senders[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text('Tin nhắn từ $receiverUsername'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrivateChatScreen(
                        receiverUsername: receiverUsername,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
