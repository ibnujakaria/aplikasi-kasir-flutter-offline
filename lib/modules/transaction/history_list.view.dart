import 'package:aplikasi_kasir/core/database/database.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_kasir/core/utils/currency_format.dart';
import 'models/transaction.model.dart';
import 'transaction.service.dart';
import 'pos.view.dart';

class HistoryListView extends StatefulWidget {
  const HistoryListView({super.key});

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final TransactionService _transactionService = TransactionService();

  List<Transaction> _transactions = [];
  bool _isLoading = true;

  // Filters
  String _searchQuery = '';
  TransactionStatus? _selectedStatus;
  String _sortOrder = 'created_at DESC';

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    setState(() => _isLoading = true);
    final list = await _transactionService.getTransactions(
      query: _searchQuery,
      status: _selectedStatus,
      orderBy: _sortOrder,
    );
    setState(() {
      _transactions = list;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String v) {
    setState(() => _searchQuery = v);
    _loadTransactions();
  }

  void _onStatusChanged(TransactionStatus? status) {
    setState(() => _selectedStatus = status);
    _loadTransactions();
  }

  void _onSortChanged(String order) {
    setState(() => _sortOrder = order);
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                ? const Center(child: Text("Tidak ada transaksi ditemukan"))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(_transactions[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PosView()),
          );
          _loadTransactions(); // Refresh on return
        },
        label: const Text('Transaksi Baru'),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Cari ID Transaksi...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
            ),
            onChanged: (v) {
              // Debounce could be added here
              _onSearchChanged(v);
            },
          ),
          const SizedBox(height: 12),
          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Sort Dropdown
                _buildFilterChipLikeDropdown<String>(
                  value: _sortOrder,
                  items: const [
                    DropdownMenuItem(
                      value: 'created_at DESC',
                      child: Text("Terbaru"),
                    ),
                    DropdownMenuItem(
                      value: 'created_at ASC',
                      child: Text("Terlama"),
                    ),
                    DropdownMenuItem(
                      value: 'total_amount DESC',
                      child: Text("Harga Tertinggi"),
                    ),
                    DropdownMenuItem(
                      value: 'total_amount ASC',
                      child: Text("Harga Terendah"),
                    ),
                  ],
                  onChanged: (v) => _onSortChanged(v!),
                  label: 'Urutkan',
                ),
                const SizedBox(width: 8),
                // Status Dropdown
                _buildFilterChipLikeDropdown<TransactionStatus?>(
                  value: _selectedStatus,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("Semua Status"),
                    ),
                    ...TransactionStatus.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.name.toUpperCase()),
                      );
                    }),
                  ],
                  onChanged: _onStatusChanged,
                  label: 'Status',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipLikeDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.grey[300]!),
      //   borderRadius: BorderRadius.circular(20),
      //   color: Colors.white
      // ),
      // Simplify to standard card look or generic
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: Colors.black),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction txn) {
    Color statusColor = Colors.grey;
    switch (txn.status) {
      case TransactionStatus.preparing:
        statusColor = Colors.orange;
        break;
      case TransactionStatus.served:
        statusColor = Colors.blue;
        break;
      case TransactionStatus.finished:
        statusColor = Colors.green;
        break;
      case TransactionStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Show detail dialog or navigate
          _showDetailDialog(txn);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${txn.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      txn.status.name.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatCurrency(txn.totalAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(
                      'dd MMM yyyy, HH:mm',
                    ).format(txn.createdAt ?? DateTime.now()),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (txn.customerId != null)
                    // Ideally we show customer Name, but we only have ID in this context. Use placeholder or fetch.
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "Cust #${txn.customerId}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(Transaction txn) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Detail Transaksi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),

              // Detail Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: ${formatCurrency(txn.totalAmount)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Status: ${txn.status.name}"),
                ],
              ),
              const SizedBox(height: 10),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchItemsWithNames(txn.id!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  if (snapshot.data!.isEmpty)
                    return const Text("Tidak ada item");

                  return SizedBox(
                    height: 200,
                    child: ListView(
                      children: snapshot.data!.map((item) {
                        final name = item['product_name'] ?? 'Unknown Product';
                        final qty = item['quantity'];
                        final price = item['price'];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(name),
                          trailing: Text("$qty x ${formatCurrency(price)}"),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchItemsWithNames(
    int transactionId,
  ) async {
    final db = await DatabaseService().database;
    // Join to get product name
    return await db.rawQuery(
      '''
        SELECT ti.*, p.name as product_name
        FROM transaction_items ti
        LEFT JOIN product p ON ti.product_id = p.id
        WHERE ti.transaction_id = ?
     ''',
      [transactionId],
    );
  }
}
