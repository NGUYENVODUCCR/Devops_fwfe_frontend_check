import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:http/http.dart' as http;

class PrivateChatService {
  final _storage = const FlutterSecureStorage();
  StompClient? _stompClient;
  bool _isConnected = false;

  String? _token;
  String? _username;
  final _messages = <Map<String, dynamic>>[];

  List<Map<String, dynamic>> get messages => _messages;

  Future<void> connect({
    required Function(Map<String, dynamic>) onMessageReceived,
    Function()? onConnect,
    Function(dynamic error)? onError,
  }) async {
    _token = await _storage.read(key: 'token');
    _username = await _storage.read(key: 'username');

    if (_token == null || _username == null) {
      print('❌ Không thể kết nối WS: token hoặc username null');
      return;
    }

    print('🔐 Kết nối WS (PRIVATE) với token: $_token, username: $_username');

    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'https://findwork.duckdns.org/ws',
        stompConnectHeaders: {'Authorization': 'Bearer $_token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $_token'},
        onConnect: (StompFrame frame) {
          _isConnected = true;
          print('✅ WS Private Connected');

          _stompClient?.subscribe(
              destination: '/user/${_username}/queue/messages',
          callback: (StompFrame frame) {
              if (frame.body != null) {
                final data = jsonDecode(frame.body!);
                print('📥 Private WS nhận được: ${jsonEncode(data)}');

                final type = data['type']?.toString().toUpperCase().trim();
                final sender = data['sender']?.toString().trim();
                final receiver = data['receiver']?.toString().trim();
                final localUser = _username?.trim();

                print('🔎 Loại tin: $type');
                print('👤 Người gửi: $sender');
                print('👤 Người nhận: $receiver');
                print('👤 Người dùng hiện tại: $localUser');

                final isRelated = sender == localUser || receiver == localUser;

                if (type == 'PRIVATE' && isRelated) {
                  data['isSender'] = sender == localUser;
                  data['readByUsers'] = List<String>.from(data['readByUsers'] ?? []);
                  updateMessage(data, onMessageReceived);
                } else {
                  print('⚠️ Tin nhắn không liên quan hoặc không phải PRIVATE');
                }
              }
            },
          );
          print('🌀 Subscribed to /user/{_username}/queue/messages with id=private-sub');

          onConnect?.call();
        },
        beforeConnect: () async {
          print('⏳ Đang kết nối đến WS private...');
          await Future.delayed(const Duration(milliseconds: 300));
        },
        onWebSocketError:
        onError ?? (error) => print('❌ Private WebSocket error: $error'),
        onDisconnect: (_) {
          _isConnected = false;
          print("❌ Private WS Disconnected");
        },
      ),
    );

    _stompClient?.activate();
  }

  void updateMessage(Map<String, dynamic> data, Function(Map<String, dynamic>) cb) {
    final idx = _messages.indexWhere((m) => m['id'] == data['id']);
    if (idx != -1) {
      _messages[idx] = data;
    } else {
      _messages.insert(0, data);
    }
    cb(data);
  }


  void sendPrivateMessage(String content, String receiverUsername) {
    if (!_isConnected || _stompClient == null) {
      print('⚠️ Không thể gửi: WebSocket chưa kết nối');
      return;
    }

    final message = {
      'content': content.trim(),
      'type': 'PRIVATE',
      'receiver': receiverUsername.trim(),
    };

    print('📤 Gửi private message: ${jsonEncode(message)}');

    _stompClient?.send(
      destination: '/app/chat.private',
      body: jsonEncode(message),
    );
  }

  void markAsReadWebSocket(int messageId) {
    if (!_isConnected || _stompClient == null) {
      print('⚠️ Không thể markRead: WS chưa kết nối');
      return;
    }

    print('📤 markAsReadWebSocket gửi ID: $messageId');

    _stompClient?.send(
      destination: '/app/chat.markRead',
      body: messageId.toString(),
      headers: {'Authorization': 'Bearer $_token'},
    );
  }

  Future<void> markAsReadRest(int messageId) async {
    final String? token = await _storage.read(key: 'token');

    if (token == null) {
      print("❌ Token is null. Chưa đăng nhập hoặc token hết hạn.");
      return;
    }

    final url =
    Uri.parse('https://findwork.duckdns.org/api/chat/mark-read/$messageId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("✅ Tin nhắn $messageId đã đánh dấu (REST)");
    } else {
      print("❌ REST lỗi: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchPrivateMessageHistory(
      String receiverUsername) async {
    final String? token = await _storage.read(key: 'token');

    if (token == null) {
      print("❌ Token is null. Chưa đăng nhập hoặc token hết hạn.");
      return [];
    }

    final url = Uri.parse(
        'https://findwork.duckdns.org/api/chat/chat/history/private?user=$receiverUsername&limit=50');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print("❌ Lỗi khi lấy lịch sử tin nhắn: ${response.body}");
      return [];
    }
  }

  Future<List<String>> getPrivateSenders(String myUsername) async {
    final String? token = await _storage.read(key: 'token');

    if (token == null) {
      print("❌ Token is null. Chưa đăng nhập hoặc token hết hạn.");
      return [];
    }

    print("📦 Username gửi đi tại getPrivateSenders: $myUsername");
    print("📦 Token gửi đi tại getPrivateSenders: $token");

    final String encodedUsername = Uri.encodeComponent(myUsername);

    final uri = Uri.parse(
        'https://findwork.duckdns.org/api/chat/chat/private/inbox?myUsername=$encodedUsername');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<String>();
    } else {
      print(
          "❌ Lỗi khi lấy danh sách người gửi: ${response.statusCode} - ${response.body}");
      return [];
    }
  }

  void disconnect() {
    _stompClient?.deactivate();
    _isConnected = false;
    print('👋 WS Private Disconnected thủ công');
  }

  bool get isConnected => _isConnected;
}
