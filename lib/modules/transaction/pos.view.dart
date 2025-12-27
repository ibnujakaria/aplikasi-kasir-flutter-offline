import 'package:aplikasi_kasir/core/utils/currency_format.dart';
import 'package:flutter/material.dart';
import '../product/product.service.dart';
import '../product/models/product.model.dart';
import '../product/widgets/product_card.widget.dart';

class PosView extends StatefulWidget {
  const PosView({super.key});

  @override
  State<PosView> createState() => _PosViewState();
}

class _PosViewState extends State<PosView> {
  final ProductService _productService = ProductService();

  // State for Cart
  final Map<int, int> _cart = {}; // {productId: quantity}
  final Map<int, Product> _cartProducts = {}; // {productId: ProductObject}

  // State for Filtering
  String _searchQuery = '';
  int? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final cats = await _productService.getCategories();
    setState(() => _categories = cats);
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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Detail Pesanan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ..._cart.entries.map((entry) {
                    final product = _cartProducts[entry.key]!;
                    final qty = entry.value;
                    return ListTile(
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
                              setSheetState(() => _updateQty(product.id!, -1));
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
                              setSheetState(() => _updateQty(product.id!, 1));
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Next: save to DB!
                    },
                    child: const Text(
                      "Proses Pembayaran",
                      style: TextStyle(color: Colors.white),
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
}
