import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final storage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _error;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await storage.read(key: 'token');

      if (token == null) throw Exception("Token không tồn tại");

      // TODO: Gọi API đổi mật khẩu
      // Ví dụ: await AdminService().changePassword(old, new, token);

      // Xử lý thành công
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công!')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = "Lỗi: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu cũ"),
                validator: (value) =>
                value == null || value.isEmpty ? "Nhập mật khẩu cũ" : null,
              ),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu mới"),
                validator: (value) =>
                value == null || value.length < 6 ? "Mật khẩu phải từ 6 ký tự" : null,
              ),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Xác nhận mật khẩu"),
                validator: (value) =>
                value != newPasswordController.text ? "Mật khẩu không khớp" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Xác nhận"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
