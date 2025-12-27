import 'package:flutter/material.dart';
import 'pos.view.dart';

class HistoryListView extends StatelessWidget {
  const HistoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: const Center(
        child: Text(
          'Belum ada transaksi recorded.',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PosView()),
        ),
        label: const Text('Transaksi Baru'),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
