import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await _authService.getUsername();
    setState(() {
      _username = name;
    });
  }

  Widget buildInfoTile(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                'Hồ sơ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Avatar
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            child: Text(
              'ảnh',
              style: TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 12),

          // Hiển thị username
          Text(
            _username ?? 'Đang tải...',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // Các ô thông tin (có thể load từ API)
          buildInfoTile(Icons.email, 'email@example.com'),
          buildInfoTile(Icons.phone, '0123456789'),
          buildInfoTile(Icons.calendar_today, '01/01/2000'),
          buildInfoTile(Icons.male, 'Nam'),
          buildInfoTile(Icons.location_on, '123 Đường ABC, TP XYZ'),

          const SizedBox(height: 20),

          // Nút chỉnh sửa
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chỉnh sửa thông tin')),
                );
              },
              child: const Text(
                'chỉnh sửa thông tin',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
