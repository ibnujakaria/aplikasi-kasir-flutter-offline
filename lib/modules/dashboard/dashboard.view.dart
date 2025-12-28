import 'package:flutter/material.dart';
import '../transaction/transaction.service.dart';
import '../transaction/pos.view.dart';
import '../transaction/history_list.view.dart';
import '../staff/staff_list.view.dart'; // Import StaffListView
// import '../product/product_list.view.dart'; // Not used yet
import '../../core/utils/currency_format.dart';
import '../transaction/models/transaction.model.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final TransactionService _transactionService = TransactionService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await _transactionService.getDashboardStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Colors
    final revenueColor = Colors.green[700]!;
    final txnColor = Colors.blue[700]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kasir'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Summary Cards ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: "Pendapatan Hari Ini",
                          value: formatCurrency(_stats['today_revenue'] ?? 0),
                          icon: Icons.attach_money,
                          color: revenueColor,
                          bgColor: Colors.green[50]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          title: "Transaksi Hari Ini",
                          value: "${_stats['today_count'] ?? 0}",
                          icon: Icons.receipt,
                          color: txnColor,
                          bgColor: Colors.blue[50]!,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Quick Actions ---
                  const Text(
                    "Aksi Cepat",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: "Transaksi Baru",
                          icon: Icons.add_shopping_cart,
                          color: Colors.orange,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PosView(),
                              ),
                            );
                            _loadStats(); // Refresh stats on return
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          label: "Riwayat Transaksi",
                          icon: Icons.history,
                          color: Colors.purple,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryListView(),
                              ),
                            );
                            _loadStats();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          label: "Kelola Staf",
                          icon: Icons.people,
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StaffListView(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Recent Activity ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Transaksi Terakhir",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryListView(),
                            ),
                          );
                        },
                        child: const Text("Lihat Semua"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _buildRecentList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  Widget _buildRecentList() {
    final List<Transaction> recent =
        (_stats['recent_transactions'] as List?)?.cast<Transaction>() ?? [];

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text("Belum ada transaksi")),
      );
    }

    return Column(
      children: recent.map((txn) {
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[50],
              child: const Icon(
                Icons.receipt_long,
                color: Colors.blue,
                size: 20,
              ),
            ),
            title: Text(
              txn.customerName ?? "Cust #${txn.customerId ?? 'Unknown'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              txn.status.name.toUpperCase(),
              style: const TextStyle(fontSize: 10),
            ),
            trailing: Text(
              formatCurrency(txn.totalAmount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            onTap: () {
              // Optional: Show detail dialog directly?
              // For simplicity, just go to history view for details or implement dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryListView(),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
