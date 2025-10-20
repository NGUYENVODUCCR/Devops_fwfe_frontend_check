import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final authService = AuthService();
    final success = await authService.logout();
    if (context.mounted) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng xuất thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
              ),
            ),
            width: double.infinity,
            child: const Center(
              child: Text(
                'Cài đặt',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Cài Đặt Việc Làm',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          _buildListTileOption(
            context,
            icon: Icons.history,
            text: 'Lịch sử ứng tuyển',
            onTap: () => _showMessage(context, 'Lịch sử ứng tuyển'),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Cài Đặt Ứng Dụng',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          _buildListTileOption(
            context,
            icon: Icons.language,
            text: 'Ngôn ngữ ứng dụng',
            onTap: () => _showMessage(context, 'Ngôn ngữ ứng dụng'),
          ),

          // Sử dụng Obx để phản ứng với thay đổi từ ThemeController
          Obx(() => _buildThemeToggleTile(
            context,
            themeController.isDarkMode.value,
                (value) => themeController.toggleTheme(),
          )),

          _buildListTileOption(
            context,
            icon: Icons.logout,
            text: 'Đăng xuất',
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildListTileOption(BuildContext context,
      {required IconData icon,
        required String text,
        required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          text,
          style:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildThemeToggleTile(
      BuildContext context, bool isDarkMode, Function(bool) onToggle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.brightness_6, color: Colors.white),
        title: const Text(
          'Chế độ giao diện',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        trailing: Switch(
          value: isDarkMode,
          activeColor: Colors.white,
          onChanged: (value) {
            onToggle(value); // Gọi toggleTheme từ controller
          },
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Bạn đã chọn: $msg')));
  }
}
