import 'package:flutter/material.dart';
import 'package:aplikasi_kasir/core/utils/currency_format.dart';
import '../product/product.service.dart';
import '../product/models/product.model.dart';
import '../product/widgets/product_card.widget.dart';
import 'transaction.service.dart';
import '../staff/staff.service.dart';
import '../staff/models/staff.model.dart';
import '../customer/customer.service.dart';
import '../customer/models/customer.model.dart';

class PosView extends StatefulWidget {
  const PosView({super.key});

  @override
  State<PosView> createState() => _PosViewState();
}

class _PosViewState extends State<PosView> {
  final ProductService _productService = ProductService();
  final TransactionService _transactionService = TransactionService();
  final StaffService _staffService = StaffService();
  // final CustomerService _customerService = CustomerService(); // Removed unused

  // State for Cart
  final Map<int, int> _cart = {}; // {productId: quantity}
  final Map<int, Product> _cartProducts = {}; // {productId: ProductObject}

  // State for Filtering
  String _searchQuery = '';
  int? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];

  // State for Transaction
  List<Staff> _staffMembers = [];
  Staff? _selectedStaff;
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final cats = await _productService.getCategories();
    final staff = await _staffService.getAllStaff();
    setState(() {
      _categories = cats;
      _staffMembers = staff;
    });
  }

  // --- LOGIC ---

  void _addToCart(Product product) {
    int currentQtyInCart = _cart[product.id] ?? 0;

    // Check if we still have stock
    if (currentQtyInCart < product.stock) {
      setState(() {
        int id = product.id!;
        _cart[id] = currentQtyInCart + 1;
        _cartProducts[id] = product;
      });
    } else {
      // Optional: Show a toast or snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Stok ${product.name} habis!")));
    }
  }

  void _updateQty(int productId, int delta) {
    setState(() {
      if (_cart.containsKey(productId)) {
        _cart[productId] = _cart[productId]! + delta;
        if (_cart[productId]! <= 0) {
          _cart.remove(productId);
          _cartProducts.remove(productId);
        }
      }
    });
  }

  double get _totalPrice {
    double total = 0;
    _cart.forEach((id, qty) {
      total += (_cartProducts[id]?.price ?? 0) * qty;
    });
    return total;
  }

  // --- UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir (POS)'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: _buildFilterBar(),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildProductGrid()),
          if (_cart.isNotEmpty) _buildBottomSummary(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari menu...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: _selectedCategoryId,
                hint: const Text("Filter"),
                items: [
                  const DropdownMenuItem(value: null, child: Text("Semua")),
                  ..._categories.map(
                    (c) => DropdownMenuItem(
                      value: c['id'],
                      child: Text(c['name']),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate columns: 2 for small screens, 3 for medium, 4+ for wide
        int crossAxisCount = 2;
        if (constraints.maxWidth > 600) crossAxisCount = 3;
        if (constraints.maxWidth > 900) crossAxisCount = 4;
        if (constraints.maxWidth > 1200) crossAxisCount = 5;

        return FutureBuilder<List<Product>>(
          future: _productService.getAllProducts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = snapshot.data!.where((p) {
              final matchesSearch = p.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
              final matchesCategory =
                  _selectedCategoryId == null ||
                  p.categoryId == _selectedCategoryId;
              return matchesSearch && matchesCategory;
            }).toList();

            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Use the dynamic count here
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                final qty = _cart[p.id] ?? 0;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductCard(product: p, onTap: () => _addToCart(p)),
                    if (qty > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          child: Center(
                            child: Text(
                              '$qty',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${_cart.length} Item dipilih",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "Total: ${formatCurrency(_totalPrice)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              onPressed: () => _showReviewSheet(),
              child: const Text(
                "Review Pesanan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Detail Pesanan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Cart Items
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView(
                      shrinkWrap: true,
                      children: _cart.entries.map((entry) {
                        final product = _cartProducts[entry.key]!;
                        final qty = entry.value;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(product.name),
                          subtitle: Text("Rp ${product.price.toInt()} x $qty"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setSheetState(
                                    () => _updateQty(product.id!, -1),
                                  );
                                  setState(() {}); // Updates main grid badges
                                },
                              ),
                              Text('$qty'),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  setSheetState(
                                    () => _updateQty(product.id!, 1),
                                  );
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const Divider(),

                  // Staff Selection
                  DropdownButtonFormField<Staff>(
                    decoration: const InputDecoration(
                      labelText: 'Dilayani oleh (Opsional)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    value: _selectedStaff,
                    items: _staffMembers.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s.name));
                    }).toList(),
                    onChanged: (v) {
                      setSheetState(() => _selectedStaff = v);
                      setState(() {}); // Persist to parent state
                    },
                  ),

                  const SizedBox(height: 10),

                  // Customer Selection
                  InkWell(
                    onTap: () async {
                      final customer = await _showCustomerSearchDialog();
                      if (customer != null) {
                        setSheetState(() => _selectedCustomer = customer);
                        setState(() {});
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Pelanggan',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person_search),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        _selectedCustomer?.name ?? 'Umum (Klik untuk cari)',
                        style: TextStyle(
                          color: _selectedCustomer == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pay Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {
                      try {
                        // Prepare Data
                        final cartList = _cart.entries.map((e) {
                          return {
                            'product': _cartProducts[e.key],
                            'qty': e.value,
                          };
                        }).toList();

                        // Call Service
                        final txn = await _transactionService.createTransaction(
                          totalAmount: _totalPrice,
                          paymentMethod: 'cash', // Logic can be extended later
                          staffId: _selectedStaff?.id,
                          customerId: _selectedCustomer?.id,
                          cartItems: cartList,
                        );

                        if (txn != null) {
                          if (mounted) {
                            Navigator.pop(context); // Close sheet
                            setState(() {
                              _cart.clear();
                              _cartProducts.clear();
                              _selectedCustomer = null;
                              // _selectedStaff = null; // Maybe keep staff selected?
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Transaksi Berhasil! Status: Preparing',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          throw Exception("Gagal membuat transaksi");
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Proses Pembayaran",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<Customer?> _showCustomerSearchDialog() {
    return showDialog<Customer>(
      context: context,
      builder: (context) {
        return const _CustomerSearchDialog();
      },
    );
  }
}

class _CustomerSearchDialog extends StatefulWidget {
  const _CustomerSearchDialog();

  @override
  State<_CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<_CustomerSearchDialog> {
  final CustomerService _customerService = CustomerService();
  List<Customer> _results = [];
  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search();
  }

  void _search() async {
    final list = await _customerService.getCustomers(query: _query);
    setState(() => _results = list);
  }

  void _createCustomer() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Pelanggan Baru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Nama"),
              ),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: "No HP"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  final newC = Customer(
                    name: nameCtrl.text,
                    phone: phoneCtrl.text,
                  );
                  await _customerService.createCustomer(newC);
                  Navigator.pop(context);
                  _search(); // refresh list
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pilih Pelanggan"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: "Cari nama / hp...",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) {
                      _query = v;
                      _search();
                    },
                  ),
                ),
                IconButton(
                  onPressed: _createCustomer,
                  icon: const Icon(Icons.person_add, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final c = _results[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(c.name),
                      subtitle: Text(c.phone ?? '-'),
                      onTap: () => Navigator.pop(context, c),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
      ],
    );
  }
}
