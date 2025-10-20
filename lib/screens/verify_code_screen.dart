import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_input_decoration.dart';
import 'new_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _error;
  bool _isLoading = false;

  void _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() => _error = 'Vui lòng nhập mã xác nhận');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final isValid = await _authService.verifyCode(widget.email, code);

    setState(() => _isLoading = false);

    if (isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewPasswordScreen(email: widget.email, code: code),
        ),
      );
    } else {
      setState(() => _error = 'Mã xác nhận không đúng hoặc đã hết hạn');
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
                children: [
                  const Text(
                    "Xác minh mã OTP",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _codeController,
                    decoration: customInputDecoration("Nhập mã xác nhận"),
                  ),
                  const SizedBox(height: 10),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9D4EDD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Tiếp tục",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
