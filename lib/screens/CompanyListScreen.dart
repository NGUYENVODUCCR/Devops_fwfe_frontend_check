import 'package:flutter/material.dart';
import 'package:fwfe/services/company_service.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  List<Map<String, dynamic>> allCompanies = [];
  List<Map<String, dynamic>> filteredCompanies = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    try {
      final data = await CompanyService.getAllCompanies();
      setState(() {
        allCompanies = data;
        filteredCompanies = List.from(allCompanies);
        _isLoading = false;
      });
    } catch (e) {
      print('[ERROR] $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCompanies(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredCompanies = allCompanies.where((company) {
        final name = company['name']?.toLowerCase() ?? '';
        final type = company['type']?.toLowerCase() ?? '';
        return name.contains(lowerQuery) || type.contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _showCompanyDetails(int companyId) async {
    try {
      final detail = await CompanyService.getCompanyById(companyId);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(detail['name'] ?? 'Chi tiết công ty'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Loại hình: ${detail['type'] ?? 'Không có'}'),
              const SizedBox(height: 8),
              Text('Người tạo: ${detail['createdByUsername'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Địa chỉ: ${detail['address'] ?? 'Không có'}'),
              const SizedBox(height: 8),
              Text('Mô tả: ${detail['descriptionCompany'] ?? 'Không có'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('[ERROR] Lỗi khi tải chi tiết công ty: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải chi tiết công ty.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công ty'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCompanies,
              decoration: InputDecoration(
                hintText: 'Tìm công ty...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (filteredCompanies.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("Không có công ty nào phù hợp"),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredCompanies.length,
                itemBuilder: (context, index) {
                  final company = filteredCompanies[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(company['name'] ?? ''),
                      subtitle: Text(company['type'] ?? ''),
                      leading: const Icon(Icons.business),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        final companyId = company['id'];
                        if (companyId != null) {
                          _showCompanyDetails(companyId);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}


