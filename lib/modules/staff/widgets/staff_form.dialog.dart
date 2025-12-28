import 'package:flutter/material.dart';
import '../models/staff.model.dart';
import '../staff.service.dart';

class StaffFormDialog extends StatefulWidget {
  final Staff? staff;

  const StaffFormDialog({super.key, this.staff});

  @override
  State<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final StaffService _service = StaffService();

  String _role = 'Staff';
  String _avatar = 'person'; // Icon name as string
  bool _isLoading = false;

  final List<String> _roles = ['Admin', 'Kasir', 'Staff'];

  // Map of avatar names to icons and colors
  final Map<String, Map<String, dynamic>> _avatars = {
    'person': {'icon': Icons.person, 'color': Colors.blue},
    'account_circle': {'icon': Icons.account_circle, 'color': Colors.green},
    'face': {'icon': Icons.face, 'color': Colors.orange},
    'supervised_user_circle': {
      'icon': Icons.supervised_user_circle,
      'color': Colors.purple,
    },
  };

  @override
  void initState() {
    super.initState();
    if (widget.staff != null) {
      _nameCtrl.text = widget.staff!.name;
      _role = widget.staff!.role;
      _avatar = widget.staff!.avatar;
      // Ensure avatar is valid
      if (!_avatars.containsKey(_avatar)) {
        _avatar = 'person';
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newStaff = Staff(
        id: widget.staff?.id,
        name: _nameCtrl.text,
        role: _role,
        avatar: _avatar,
        createdAt: widget.staff?.createdAt ?? DateTime.now(),
      );

      await _service.saveStaff(newStaff);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.staff == null
                  ? 'Staf berhasil ditambahkan'
                  : 'Staf berhasil diperbarui',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.staff == null ? 'Tambah Staf' : 'Edit Staf'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar Selection (Icon-based)
                const Text(
                  'Pilih Avatar',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                // Use Row instead of ListView to avoid viewport constraints
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _avatars.entries.map((entry) {
                    final avatarName = entry.key;
                    final avatarData = entry.value;
                    final isSelected = _avatar == avatarName;

                    return GestureDetector(
                      onTap: () => setState(() => _avatar = avatarName),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: isSelected
                            ? Colors.orange
                            : Colors.grey[200],
                        child: Icon(
                          avatarData['icon'] as IconData,
                          color: isSelected
                              ? Colors.white
                              : avatarData['color'] as Color,
                          size: 30,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Jabatan',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => _role = v!),
                ),
              ],
            ),
          ),
        ),
      ), // Added missing closing parenthesis here
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
