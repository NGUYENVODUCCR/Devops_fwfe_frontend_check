import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/private_chat_service.dart';

class PrivateChatScreen extends StatefulWidget {
  final String receiverUsername;

  const PrivateChatScreen({super.key, required this.receiverUsername});

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final PrivateChatService _chatService = PrivateChatService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _username = await _storage.read(key: 'username');
    await _fetchHistory();

    _chatService.connect(
      onMessageReceived: (msg) async {
        msg['isSender'] = msg['sender'] == _username;

        if (msg['type'] == 'PRIVATE' &&
            (_username != null &&
                (msg['sender']?.toString().trim() == _username!.trim() ||
                    msg['receiver']?.toString().trim() == _username!.trim()) &&
                (msg['sender']?.toString().trim() == widget.receiverUsername.trim() ||
                    msg['receiver']?.toString().trim() == widget.receiverUsername.trim()))) {
          final messageId = msg['id'];
          final isMe = msg['sender'] == _username;
          final readByUsers = (msg['readByUsers'] is List)
              ? List<String>.from(msg['readByUsers'] ?? [])
              : <String>[];

          if (!isMe && !readByUsers.contains(_username)) {
            print('📤 Gửi markAsRead PRIVATE cho messageId: $messageId');
            _chatService.markAsReadWebSocket(messageId);
          }

          setState(() {
            // Xóa bản tạm (giả ID)
            _messages.removeWhere((m) =>
            m['id'] == msg['id'] || // Trùng ID chính xác
                (m['content'] == msg['content'] && // Nội dung giống nhau
                    m['sender'] == msg['sender'] &&
                    m['receiver'] == msg['receiver'] &&
                    (m['id'] as int?)?.toString().length == 13)); // ID giả = timestamp ms

            // Chèn bản chính xác
            _messages.insert(0, msg);
          });

          await Future.delayed(Duration(milliseconds: 100));
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  Future<void> _fetchHistory() async {
    final history = await _chatService.fetchPrivateMessageHistory(widget.receiverUsername);
    _username = await _storage.read(key: 'username');

    for (var msg in history) {
      msg['isSender'] = msg['sender'] == _username;
    }

    setState(() {
      _messages.clear();
      _messages.addAll(history.reversed);
      _isLoading = false;
    });
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _username == null) return;

    final tempMessage = {
      'id': DateTime.now().millisecondsSinceEpoch, // Fake ID for temporary UI
      'content': content,
      'sender': _username,
      'receiver': widget.receiverUsername,
      'timestamp': DateTime.now().toIso8601String(),
      'readByUsers': [_username],
      'type': 'PRIVATE',
      'isSender': true,
    };

    _chatService.sendPrivateMessage(content, widget.receiverUsername);
    _messageController.clear();

    setState(() {
      _messages.insert(0, tempMessage);
    });

    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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
      appBar: AppBar(title: Text('Chat với ${widget.receiverUsername}')),
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (_, index) {
                    final msg = _messages[index];
                    final isSender = msg['isSender'] == true;
                    final timestamp = DateTime.tryParse(msg['timestamp'] ?? '')?.toLocal();
                    final readBy = (msg['readByUsers'] as List).join(", ");

                    return Align(
                      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSender ? Colors.blue[200]?.withOpacity(0.9) : Colors.grey[300]?.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(msg['content'] ?? '', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 4),
                            if (timestamp != null)
                              Text(
                                '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.day}/${timestamp.month}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (readBy.isNotEmpty)
                              Text(
                                'Đã đọc bởi: $readBy',
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _sendMessage,
                      child: const Icon(Icons.send),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
