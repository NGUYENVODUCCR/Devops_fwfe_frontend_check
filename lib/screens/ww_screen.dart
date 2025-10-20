import 'package:flutter/material.dart';

import '../services/company_service.dart';
import '../services/work_service.dart';

class WWScreen extends StatefulWidget {
  const WWScreen({super.key});

  @override
  State<WWScreen> createState() => _WWScreenState();
}

class _WWScreenState extends State<WWScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> myCompanies = [];
  List<Map<String, dynamic>> works = [];

  late TabController _tabController;

  final _companyNameController = TextEditingController();
  final _companyDescController = TextEditingController();
  final _companyTypeController = TextEditingController();
  final _companyAddressController = TextEditingController();

  final _positionController = TextEditingController();
  final _descController = TextEditingController();
  final _maxAcceptedController = TextEditingController();
  final _maxReceiverController = TextEditingController();
  final _salaryController = TextEditingController();

  int? selectedCompanyId;

  Map<String, dynamic>? editingCompany;
  Map<String, dynamic>? editingWork;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyCompanies();
    _loadWorks();
  }

  void _loadMyCompanies() async {
    try {
      final data = await CompanyService.getMyCompanies();
      setState(() => myCompanies = data);
    } catch (e) {
      _showError('Lỗi tải công ty: $e');
    }
  }

  void _loadWorks() async {
    try {
      final data = await WorkService.getAllWorks();
      setState(() => works = data);
    } catch (e) {
      _showError('Lỗi tải công việc: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // === Công ty ===
  void _showCompanyDialog({Map<String, dynamic>? company}) {
    editingCompany = company;
    if (company != null) {
      _companyNameController.text = company['name'] ?? '';
      _companyDescController.text = company['descriptionCompany'] ?? '';
      _companyTypeController.text = company['type'] ?? '';
      _companyAddressController.text = company['address'] ?? '';
    } else {
      _companyNameController.clear();
      _companyDescController.clear();
      _companyTypeController.clear();
      _companyAddressController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(company != null ? 'Cập nhật công ty' : 'Tạo công ty mới'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_companyNameController, 'Tên công ty'),
              _buildTextField(_companyDescController, 'Mô tả'),
              _buildTextField(_companyTypeController, 'Loại hình'),
              _buildTextField(_companyAddressController, 'Địa chỉ'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              company != null
                  ? _updateCompany(company['id'] as int)
                  : _createCompany();
              Navigator.pop(context);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _createCompany() async {
    try {
      final result = await CompanyService.createCompany(
        name: _companyNameController.text,
        descriptionCompany: _companyDescController.text,
        type: _companyTypeController.text,
        address: _companyAddressController.text,
      );
      setState(() => myCompanies.add(result));
    } catch (e) {
      _showError('Tạo công ty thất bại: $e');
    }
  }

  void _updateCompany(int id) async {
    try {
      final result = await CompanyService.updateCompany(
        id: id,
        name: _companyNameController.text,
        descriptionCompany: _companyDescController.text,
        type: _companyTypeController.text,
        address: _companyAddressController.text,
      );
      setState(() {
        final index = myCompanies.indexWhere((c) => c['id'] == result['id']);
        if (index != -1) {
          myCompanies[index] = result;
        }
      });
    } catch (e) {
      _showError('Cập nhật thất bại: $e');
    }
  }

  void _deleteCompany(int id) async {
    try {
      await CompanyService.deleteCompany(id);
      setState(() => myCompanies.removeWhere((c) => c['id'] == id));
    } catch (e) {
      _showError('Xóa thất bại: $e');
    }
  }

  Widget _buildCompanyCard(Map<String, dynamic> company) {
    return _buildCard(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(company['name'], style: _titleStyle),
          Text('Mô tả: ${company['descriptionCompany']}', style: _textStyle),
          Text('Loại hình: ${company['type']}', style: _textStyle),
          Text('Địa chỉ: ${company['address']}', style: _textStyle),
        ],
      ),
      onEdit: () => _showCompanyDialog(company: company),
      onDelete: () => _deleteCompany(company['id']),
    );
  }

  // === Công việc ===
  void _showWorkDialog({Map<String, dynamic>? work}) {
    editingWork = work;
    if (work != null) {
      _positionController.text = work['position'] ?? '';
      _descController.text = work['descriptionWork'] ?? '';
      _maxAcceptedController.text = work['maxAccepted'].toString();
      _maxReceiverController.text = work['maxReceiver'].toString();
      _salaryController.text = work['salary'].toString();
      selectedCompanyId = work['companyId'];
    } else {
      _positionController.clear();
      _descController.clear();
      _maxAcceptedController.clear();
      _maxReceiverController.clear();
      _salaryController.clear();
      selectedCompanyId = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(work != null ? 'Cập nhật công việc' : 'Tạo công việc mới'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_positionController, 'Vị trí'),
              _buildTextField(_descController, 'Mô tả'),
              DropdownButtonFormField<int>(
                value: selectedCompanyId,
                decoration: const InputDecoration(labelText: 'Chọn công ty'),
                items: myCompanies
                    .map((company) => DropdownMenuItem<int>(
                  value: company['id'],
                  child: Text(company['name']),
                ))
                    .toList(),
                onChanged: (value) => setState(() => selectedCompanyId = value),
              ),
              _buildTextField(_maxAcceptedController, 'Số người nhận', inputType: TextInputType.number),
              _buildTextField(_maxReceiverController, 'Số người nhận CV', inputType: TextInputType.number),
              _buildTextField(_salaryController, 'Lương', inputType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              work != null ? _updateWork(work['id']) : _createWork();
              Navigator.pop(context);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _createWork() async {
    try {
      final result = await WorkService.createWork(
        position: _positionController.text,
        descriptionWork: _descController.text,
        maxAccepted: int.parse(_maxAcceptedController.text),
        maxReceiver: int.parse(_maxReceiverController.text),
        salary: double.parse(_salaryController.text),
        companyId: selectedCompanyId!,
      );
      setState(() => works.add(result));
    } catch (e) {
      _showError('Tạo công việc thất bại: $e');
    }
  }

  void _updateWork(int id) async {
    try {
      final result = await WorkService.updateWork(
        id: id,
        position: _positionController.text,
        descriptionWork: _descController.text,
        maxAccepted: int.parse(_maxAcceptedController.text),
        maxReceiver: int.parse(_maxReceiverController.text),
        salary: double.parse(_salaryController.text),
        companyId: selectedCompanyId!,
      );
      setState(() {
        final index = works.indexWhere((w) => w['id'] == id);
        if (index != -1) works[index] = result;
      });
    } catch (e) {
      _showError('Cập nhật thất bại: $e');
    }
  }

  void _deleteWork(int id) async {
    try {
      await WorkService.deleteWork(id);
      setState(() => works.removeWhere((w) => w['id'] == id));
    } catch (e) {
      _showError('Xóa thất bại: $e');
    }
  }

  Widget _buildWorkCard(Map<String, dynamic> work) {
    final companyName = work['companyName'] ?? work['company'] ?? 'Không rõ';
    return _buildCard(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(work['position'], style: _titleStyle),
          Text('Mô tả: ${work['descriptionWork']}', style: _textStyle),
          Text('Công ty: $companyName', style: _textStyle),
          Text('Số người nhận: ${work['maxAccepted']}', style: _textStyle),
          Text('Số người nhận CV: ${work['maxReceiver']}', style: _textStyle),
          Text('Lương: ${work['salary']} VNĐ', style: _textStyle),
        ],
      ),
      onEdit: () => _showWorkDialog(work: work),
      onDelete: () => _deleteWork(work['id']),
    );
  }

  // === UI chung ===
  final _titleStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white);
  final _textStyle = const TextStyle(color: Colors.white);

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _buildCard({required Widget content, required VoidCallback onEdit, required VoidCallback onDelete}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [Color(0xFF9D4EDD), Color(0xFF40C9FF)]),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: content),
          Column(
            children: [
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, color: Colors.white)),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String title, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)]),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Nhà tuyển dụng'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Công ty'),
              Tab(text: 'Công việc'),
            ],
          ),
          backgroundColor: const Color(0xFFB84DF1),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildGradientButton('Tạo công ty mới', Icons.add_business, () => _showCompanyDialog()),
                  ...myCompanies.map(_buildCompanyCard),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildGradientButton('Tạo công việc mới', Icons.work, () => _showWorkDialog()),
                  ...works.map(_buildWorkCard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
