import 'package:flutter/material.dart';
import '../models/register_request.dart';
import '../services/auth_service.dart';
import '../widgets/custom_input_decoration.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _errorMessage;

  void _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        name.isEmpty ||
        email.isEmpty) {
      setState(() {
        _errorMessage = "Vui lòng nhập đầy đủ thông tin";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Mật khẩu xác nhận không khớp";
      });
      return;
    }

    setState(() {
      _errorMessage = null; // Clear error if any
    });

    final request = RegisterRequest(
      username: username,
      password: password,
      confirmPassword: confirmPassword,
      name: name,
      email: email,
    );

    final result = await _authService.register(request);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công!")),
      );
      Navigator.pop(context); // Quay lại login
    } else {
      setState(() {
        _errorMessage = "Lỗi: $result";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9D4EDD), Color(0xFF00B4D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Tạo tài khoản",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: customInputDecoration("Họ tên"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: customInputDecoration("Email"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _usernameController,
                    decoration: customInputDecoration("Username"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: customInputDecoration("Password"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: customInputDecoration("Xác nhận Password"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered)) {
                              return const Color(0xFF7B82E0); // Hover
                            }
                            return const Color(0xFF9D4EDD); // Default
                          },
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      onPressed: _register,
                      child: const Text("Đăng ký"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Đã có tài khoản? Đăng nhập",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
