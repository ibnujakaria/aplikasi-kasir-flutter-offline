import 'package:flutter/material.dart';

class SetupForm extends StatefulWidget {
  final Function(String name, String phone, String staffName) onSave;

  const SetupForm({super.key, required this.onSave});

  @override
  State<SetupForm> createState() => _SetupFormState();
}

class _SetupFormState extends State<SetupForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  final _resNameController = TextEditingController();
  final _resPhoneController = TextEditingController();
  final _staffNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Pengaturan Awal',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Lengkapi data berikut untuk mulai menggunakan aplikasi.'),
          const SizedBox(height: 32),

          // RESTAURANT SECTION
          _buildSectionTitle(Icons.storefront, 'Info Restoran'),
          TextFormField(
            controller: _resNameController,
            decoration: const InputDecoration(labelText: 'Nama Restoran'),
            validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
          ),
          TextFormField(
            controller: _resPhoneController,
            decoration: const InputDecoration(labelText: 'Nomor Telepon'),
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 32),

          // STAFF SECTION
          _buildSectionTitle(Icons.person, 'Akun Admin'),
          TextFormField(
            controller: _staffNameController,
            decoration: const InputDecoration(labelText: 'Nama Lengkap Anda'),
            validator: (v) =>
                v!.isEmpty ? 'Nama admin tidak boleh kosong' : null,
          ),

          const SizedBox(height: 48),

          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSave(
                  _resNameController.text,
                  _resPhoneController.text,
                  _staffNameController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Simpan & Selesai'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
