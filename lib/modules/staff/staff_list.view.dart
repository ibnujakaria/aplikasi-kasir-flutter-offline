import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/staff.model.dart';
import 'staff.service.dart';
import 'widgets/staff_form.dialog.dart';

class StaffListView extends StatefulWidget {
  const StaffListView({super.key});

  @override
  State<StaffListView> createState() => _StaffListViewState();
}

class _StaffListViewState extends State<StaffListView> {
  final StaffService _service = StaffService();
  List<Staff> _staffList = [];
  bool _isLoading = true;

  // Map of avatar names to icons and colors (matching dialog)
  final Map<String, Map<String, dynamic>> _avatarMap = {
    'person': {'icon': Icons.person, 'color': Colors.blue},
    'account_circle': {'icon': Icons.account_circle, 'color': Colors.green},
    'face': {'icon': Icons.face, 'color': Colors.orange},
    'supervised_user_circle': {
      'icon': Icons.supervised_user_circle,
      'color': Colors.purple,
    },
  };

  IconData _getIconForAvatar(String avatarName) {
    return _avatarMap[avatarName]?['icon'] ?? Icons.person;
  }

  Color _getColorForAvatar(String avatarName) {
    return _avatarMap[avatarName]?['color'] ?? Colors.blue;
  }

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    final list = await _service.getAllStaff();
    setState(() {
      _staffList = list;
      _isLoading = false;
    });
  }

  Future<void> _showFormDialog([Staff? staff]) async {
    final result = await showDialog(
      context: context,
      builder: (context) => StaffFormDialog(staff: staff),
    );

    if (result == true) {
      _loadStaff();
    }
  }

  void _confirmDelete(Staff staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Staf?'),
        content: Text('Apakah Anda yakin ingin menghapus "${staff.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _service.deleteStaff(staff.id!);
              _loadStaff();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Staf berhasil dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Staf'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStaff),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _staffList.isEmpty
          ? const Center(child: Text('Belum ada data staf'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _staffList.length,
              itemBuilder: (context, index) {
                final staff = _staffList[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getColorForAvatar(
                        staff.avatar,
                      ).withOpacity(0.2),
                      child: Icon(
                        _getIconForAvatar(staff.avatar),
                        color: _getColorForAvatar(staff.avatar),
                      ),
                    ),
                    title: Text(
                      staff.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(staff.role),
                        Text(
                          'Bergabung: ${DateFormat('dd MMM yyyy').format(staff.createdAt ?? DateTime.now())}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showFormDialog(staff),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(staff),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        tooltip: 'Tambah Staf',
        child: const Icon(Icons.add),
      ),
    );
  }
}
