import 'package:flutter/material.dart';
import '../services/work_acceptance_service.dart';
import '../services/work_service.dart';

class AcceptedJobsScreen extends StatefulWidget {
  final int accountId;

  const AcceptedJobsScreen({super.key, required this.accountId});

  @override
  State<AcceptedJobsScreen> createState() => _AcceptedJobsScreenState();
}

class _AcceptedJobsScreenState extends State<AcceptedJobsScreen> {
  List<dynamic> acceptedJobs = [];
  String selectedStatus = 'PENDING';
  final List<String> statusOptions = ['PENDING', 'COMPLETED', 'CANCELLED'];


  @override
  void initState() {
    super.initState();
    loadAcceptedJobs();
  }

  Future<void> loadAcceptedJobs() async {
    try {
      final List<dynamic> allAccepted = [];

      final allJobs = await WorkService.getAllWorks();

      for (var job in allJobs) {
        final accepted = await WorkAcceptanceService.getAcceptedJobsByStatus(
          job['id'], widget.accountId, selectedStatus,
        );
        if (accepted.isNotEmpty) {
          final jobCopy = {...job};
          jobCopy['status'] = accepted.first['status'];
          jobCopy['companyName'] = accepted.first['companyName'];
          allAccepted.add(jobCopy);
        } else {
          print('Không có dữ liệu trạng thái "$selectedStatus" cho job ID: ${job['id']}');
        }
      }

      if (allAccepted.isEmpty) {
        print('Không có công việc nào với trạng thái: $selectedStatus');
      }

      setState(() {
        acceptedJobs = allAccepted;
      });
    } catch (e) {
      print('Lỗi khi loadAcceptedJobs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Công việc đã nhận')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lọc theo trạng thái:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                    loadAcceptedJobs();
                  },
                  items: statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),


          Expanded(
            child: acceptedJobs.isEmpty
                ? Center(
              child: Text(
                'Không có công việc nào với trạng thái: $selectedStatus',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              itemCount: acceptedJobs.length,
              itemBuilder: (context, index) {
                final job = acceptedJobs[index];
                return ListTile(
                  title: Text(job['position'] ?? 'Không rõ'),
                  subtitle: Text('Trạng thái: ${job['status'] ?? '...'}'),
                  trailing: Text('Công ty: ${job['companyName'] ?? ''}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
