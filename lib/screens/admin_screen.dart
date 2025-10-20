import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/account.dart';
import '../../services/admin_service.dart';
import '../services/GlobalContext.dart';
import '../services/auth_service.dart';
import 'admin_create_account_screen.dart';
import 'ww_screen.dart';
import 'group_chat_screen.dart';
import 'private_chat_screen.dart';
import 'user_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AuthService _authService = AuthService();
  final AdminService adminService = AdminService();
  final storage = FlutterSecureStorage();
  List<Account> accounts = [];
  int selectedIndex = 0;
  String? _selectedRole;
  List<Account> _filteredAccounts = [];


  @override
  void initState() {
    super.initState();

    final username = GlobalContext.currentUsername;
    final chatService = GlobalContext.chatService;

    print("✅ AdminScreen init với username = $username");
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) return;

      final result = await adminService.getAllAccounts(token);
      setState(() {
        accounts = result;
        _applyRoleFilter();
      });
    } catch (e) {
      print('Error loading accounts: $e');
    }
  }

  void _applyRoleFilter() {
    if (_selectedRole == null) {
      _filteredAccounts = List.from(accounts);
    } else {
      _filteredAccounts = accounts
          .where((acc) => acc.role.toLowerCase() == _selectedRole!.toLowerCase())
          .toList();
    }
  }


  Future<void> handleLockToggle(Account acc) async {
    final token = await storage.read(key: 'token');
    if (token == null) return;

    if (acc.isLocked) {
      await adminService.unlockUser(acc.id, token);
    } else {
      await adminService.lockUser(acc.id, token);
    }
    await loadAccounts();
  }

  Future<void> handleDelete(Account acc) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa tài khoản ${acc.username}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Xóa')),
        ],
      ),
    );

    if (confirm == true) {
      final token = await storage.read(key: 'token');
      if (token == null) return;

      await adminService.deleteUser(acc.id, token);
      await loadAccounts();
    }
  }

  void onChatPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GroupChatScreen()),
    );
  }

  void onScreenHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserScreen()),
    );
  }

  void onWWPressed(BuildContext context) async {
    final role = await _authService.getRole();
    if (role == 'ROLE_MANAGER' || role == 'ROLE_ADMIN') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WWScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Chức năng tuyển dụng của riêng doanh nghiệp, liên hệ admin để đăng ký tài khoản doanh nghiệp ngay!",
          ),
        ),
      );
    }
  }

  void onPrivateChat(String receiverUsername) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrivateChatScreen(receiverUsername: receiverUsername),
      ),
    );
  }

  void showEditDialog(Account acc) {
    final nameController = TextEditingController(text: acc.name);
    final emailController = TextEditingController(text: acc.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chỉnh sửa tài khoản"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Tên")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy")),
          ElevatedButton(
            child: Text("Lưu"),
            onPressed: () async {
              final token = await storage.read(key: 'token');
              if (token == null) return;
              await adminService.updateUser(
                acc.id,
                nameController.text,
                emailController.text,
                acc.role,
                acc.isLocked,
                token,
              );
              Navigator.pop(context);
              await loadAccounts();
            },
          ),
        ],
      ),
    );
  }

  Widget buildAccountItem(Account acc) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent.shade100, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(acc.email, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(acc.isLocked ? Icons.lock : Icons.lock_open, color: Colors.deepPurple),
                onPressed: () => handleLockToggle(acc),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => handleDelete(acc),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => showEditDialog(acc),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: loadAccounts,
                  child: const Text("DANH SÁCH", style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Colors.indigo),
                  onSelected: (role) {
                    setState(() {
                      _selectedRole = (role == 'ALL') ? null : role;
                      _applyRoleFilter();
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'ROLE_ADMIN', child: Text('Admin')),
                    const PopupMenuItem(value: 'ROLE_MANAGER', child: Text('Manager')),
                    const PopupMenuItem(value: 'ROLE_USER', child: Text('User')),
                    const PopupMenuItem(value: 'ALL', child: Text('Tất cả')),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.group),
                  label: const Text('Group Chat'),
                  onPressed: () => onChatPressed(context),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Trang chủ'),
                  onPressed: () => onScreenHome(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: _filteredAccounts.map(buildAccountItem).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF48FB1), Color(0xFFFFC107)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.deepPurple, width: 2),
            ),
            child: FloatingActionButton(
              heroTag: 'adminBtn',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Text(
                "AD",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.pink, width: 2),
            ),
            child: FloatingActionButton(
              heroTag: 'wwBtn',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WWScreen()),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Text(
                "WW",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/'); // hoặc '/admin' nếu có route riêng cho AdminScreen
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/admin/create');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/admin/reports');
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
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Thêm'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
