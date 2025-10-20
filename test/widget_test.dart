import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fwfe/main.dart';
import 'package:fwfe/services/private_chat_service.dart';

class FakeChatService extends PrivateChatService {
  @override
  Future<void> connect({
    required Function(Map<String, dynamic>) onMessageReceived,
    Function()? onConnect,
    Function(dynamic error)? onError,
  }) async {
    onConnect?.call(); // giả lập đã kết nối
  }

  @override
  void sendPrivateMessage(String content, String receiverUsername) {}

  @override
  void disconnect() {}

  @override
  Future<List<Map<String, dynamic>>> fetchPrivateMessageHistory(String receiverUsername) async {
    return [];
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {}

  @override
  Future<List<dynamic>> getPrivateInbox() async {
    return [];
  }

  @override
  Future<int> getUnreadCount() async {
    return 0;
  }

  @override
  Future<void> subscribeToPrivateMessages(
      Function(Map<String, dynamic>) onMessageReceived) async {}
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final fakeService = FakeChatService();

    await tester.pumpWidget(
      MaterialApp(
        home: MyApp(
          chatService: fakeService, // Chỉ còn truyền chatService
        ),
      ),
    );

    // Đây là phần kiểm thử đơn giản, bạn có thể mở rộng thêm
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
