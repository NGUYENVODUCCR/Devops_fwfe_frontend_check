import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/account.dart';
import '../../services/admin_service.dart';
import 'admin_create_account_screen.dart';
import 'ww_screen.dart';
import 'admin_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final AdminService adminService = AdminService();
  final storage = const FlutterSecureStorage();
  Account? currentAccount;
  int selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final token = await storage.read(key: 'token');
    final idStr = await storage.read(key: 'id');
    if (token == null || idStr == null) return;

    try {
      final id = int.parse(idStr);
      final account = await adminService.getAccountById(id, token);
      setState(() => currentAccount = account);
    } catch (e) {
      print("Lỗi tải thông tin cá nhân: $e");
    }
  }

  void handleNavigation(int index) {
    setState(() => selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin/create');
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminCreateAccountScreen()),
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/admin/reports');
        break;
      case 3:
        break;
      case 4:
        Navigator.pushNamed(context, '/admin/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: currentAccount == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoTile("Họ tên", currentAccount!.name, Icons.badge),
                    _buildInfoTile("Email", currentAccount!.email, Icons.email),
                    _buildInfoTile("Username", currentAccount!.username, Icons.person),
                    _buildInfoTile(
                      "Trạng thái",
                      currentAccount!.isLocked ? "Bị khóa" : "Hoạt động",
                      currentAccount!.isLocked ? Icons.lock : Icons.lock_open,
                      currentAccount!.isLocked ? Colors.red : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Đã xóa nút đăng xuất ở đây
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: handleNavigation,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Thêm'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 60,
            height: 60,
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
            width: 60,
            height: 60,
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
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, [Color? iconColor]) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.deepPurple),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }
}
