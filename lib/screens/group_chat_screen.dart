import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/group_chat_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final GroupChatService _chatService = GroupChatService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final storage = const FlutterSecureStorage();
  String? _username;

  @override
  void initState() {
    super.initState();
    _initUsernameAndConnect();
  }

  Future<void> _initUsernameAndConnect() async {
    _username = await storage.read(key: 'username');
    if (_username == null) {
      print('⚠️ _username bị null, không thể kết nối chat.');
      return;
    }

    print('🧑 Tên người dùng: $_username');

    await _chatService.connect(
      onMessageReceived: (data) {
        print('📨 Nhận message: ${jsonEncode(data)}');

        setState(() {
          final index = _messages.indexWhere((m) => m['id'] == data['id']);
          if (index != -1) {
            _messages[index] = data;
          } else {
            _messages.add(data);
          }
        });

        final isMe = data['sender'] == _username;
        final readByUsers = (data['readByUsers'] is List)
            ? List<String>.from(data['readByUsers'] ?? [])
            : <String>[];

        if (!isMe && !readByUsers.contains(_username)) {
          final messageId = data['id'];
          if (messageId != null) {
            print('📤 Gửi markAsRead cho messageId: $messageId');
            _chatService.markAsReadWebSocket(messageId);
          }
        }
      },
      onConnect: () => print("✅ Đã kết nối group chat"),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    _chatService.sendGroupMessage(content);
    _messageController.clear();
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Chat')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/chat.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (_, index) {
                    final msg = _messages[index];
                    final isMe = msg['sender'] == _username;
                    final timestamp = DateTime.tryParse(msg['timestamp'] ?? '')?.toLocal();

                    final readByUsers = (msg['readByUsers'] is List)
                        ? List<String>.from(msg['readByUsers'] ?? [])
                        : <String>[];

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent.withOpacity(0.8) : Colors.grey[300]!.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${msg['sender']}: ${msg['content']}',
                              style: TextStyle(color: isMe ? Colors.white : Colors.black),
                            ),
                            if (timestamp != null)
                              Text(
                                '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.day}/${timestamp.month}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            if (readByUsers.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '✓ Đã đọc bởi: ${readByUsers.join(', ')}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isMe ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
