import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/account.dart';
import '../../services/admin_service.dart';
import '../services/auth_service.dart';
import 'admin_create_account_screen.dart';
import 'ww_screen.dart';
import 'admin_screen.dart';
import 'group_chat_screen.dart';
import 'private_chat_screen.dart';


class AdminCreateAccountScreen extends StatefulWidget {
  const AdminCreateAccountScreen({super.key});

  @override
  State<AdminCreateAccountScreen> createState() => _AdminCreateAccountScreenState();
}

class _AdminCreateAccountScreenState extends State<AdminCreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Company fields for ROLE_MANAGER
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyDescriptionController = TextEditingController();
  final TextEditingController companyTypeController = TextEditingController();
  final TextEditingController companyAddressController = TextEditingController();
  bool isCompanyPublic = true;

  String? selectedRole;
  bool showRoleOptions = false;

  final AdminService adminService = AdminService();

  Future<void> handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng chọn vai trò!")),
        );
        return;
      }

      final token = await storage.read(key: 'token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy token!")),
        );
        return;
      }

      try {
        await adminService.createUser(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          username: usernameController.text.trim(),
          password: passwordController.text.trim(),
          confirmPassword: confirmPasswordController.text.trim(),
          role: selectedRole!,
          token: token,
          company: selectedRole == "ROLE_MANAGER"
              ? {
            "name": companyNameController.text.trim(),
            "descriptionCompany": companyDescriptionController.text.trim(),
            "type": companyTypeController.text.trim(),
            "address": companyAddressController.text.trim(),
            "isPublic": isCompanyPublic,
          }
              : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tạo tài khoản thành công!")),
        );
        _formKey.currentState!.reset();
        setState(() {
          selectedRole = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e")),
        );
      }
    }
  }

  Widget buildRoleDropdown() {
    return Column(
      children: [
        ListTile(
          title: const Text("Bạn là ai?", style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Icon(showRoleOptions ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          onTap: () => setState(() => showRoleOptions = !showRoleOptions),
        ),
        if (showRoleOptions) ...[
          RadioListTile<String>(
            title: const Text("Tôi là cá nhân tìm việc"),
            value: "ROLE_USER",
            groupValue: selectedRole,
            onChanged: (value) => setState(() => selectedRole = value),
          ),
          RadioListTile<String>(
            title: const Text("Tôi là nhà tuyển dụng"),
            value: "ROLE_MANAGER",
            groupValue: selectedRole,
            onChanged: (value) => setState(() => selectedRole = value),
          ),
          RadioListTile<String>(
            title: const Text("Tôi là admin"),
            value: "ROLE_ADMIN",
            groupValue: selectedRole,
            onChanged: (value) => setState(() => selectedRole = value),
          ),
        ]
      ],
    );
  }

  Widget buildCompanyFields() {
    if (selectedRole != "ROLE_MANAGER") return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text("Thông tin công ty", style: TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          controller: companyNameController,
          decoration: const InputDecoration(labelText: "Tên công ty"),
          validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên công ty' : null,
        ),
        TextFormField(
          controller: companyDescriptionController,
          decoration: const InputDecoration(labelText: "Giới thiệu công ty"),
          validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập mô tả' : null,
        ),
        TextFormField(
          controller: companyTypeController,
          decoration: const InputDecoration(labelText: "Loại hình kinh doanh"),
          validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập loại hình' : null,
        ),
        TextFormField(
          controller: companyAddressController,
          decoration: const InputDecoration(labelText: "Địa chỉ"),
          validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
        ),
        SwitchListTile(
          title: const Text("Công ty công khai"),
          value: isCompanyPublic,
          onChanged: (value) => setState(() => isCompanyPublic = value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [Colors.deepPurple.shade700, Colors.deepPurpleAccent.shade400]
        : [Colors.greenAccent.shade100, Colors.lightBlueAccent];

    return Scaffold(
      appBar: AppBar(
        title: const Text("ADMIN"),
        backgroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text("Tạo tài khoản mới"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.person, size: 40),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Tên"),
                      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên' : null,
                    ),
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: "Tên đăng nhập"),
                      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: "Mật khẩu"),
                      obscureText: true,
                      validator: (value) => value == null || value.length < 6 ? 'Tối thiểu 6 ký tự' : null,
                    ),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(labelText: "Xác nhận mật khẩu"),
                      obscureText: true,
                      validator: (value) => value != passwordController.text ? 'Mật khẩu không khớp' : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (value) => value == null || !value.contains('@') ? 'Email không hợp lệ' : null,
                    ),
                    const SizedBox(height: 10),
                    buildRoleDropdown(),
                    buildCompanyFields(),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white10 : Colors.white,
                        foregroundColor: isDark ? Colors.white : Colors.black,
                        side: BorderSide(color: isDark ? Colors.white60 : Colors.black87, width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Đăng ký",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
              break;
            case 2:
              Navigator.pushNamed(context, '/admin/reports');
              break;
            case 3:
              Navigator.pushNamed(context, '/admin/me');
              break;
            case 4:
              Navigator.pushNamed(context, '/admin/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Quản lý tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Thêm tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản của tôi'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
