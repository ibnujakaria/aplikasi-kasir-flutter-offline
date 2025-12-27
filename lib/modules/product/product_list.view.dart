import 'package:aplikasi_kasir/modules/product/product_form.view.dart';
import 'package:flutter/material.dart';
import 'product.service.dart';
import 'models/product.model.dart';
import 'widgets/product_card.widget.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final ProductService _productService = ProductService();
  String _searchQuery = '';
  int? _selectedCategoryId; // null means "All Categories"
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 4 : 6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        // Removed actions: [] to keep it clean
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                // 1. SEARCH BAR (Takes remaining space)
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true, // Makes it compact
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),

                const SizedBox(width: 8),

                // 2. CATEGORY DROPDOWN
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedCategoryId,
                      hint: const Text("Kategori"),
                      icon: const Icon(Icons.filter_list, size: 20),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("Semua"),
                        ),
                        ..._categories.map(
                          (cat) => DropdownMenuItem(
                            value: cat['id'],
                            child: Text(cat['name']),
                          ),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedCategoryId = val),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to the form in "Create" mode (product is null)
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormView()),
          );
          // Refresh the grid when the user comes back after saving
          setState(() {});
        },
        backgroundColor: Colors.orange, // Match your theme
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Tambah Produk",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productService.getAllProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          // --- APPLY FILTERS ---
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
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) =>
                ProductCard(product: products[index]),
          );
        },
      ),
    );
  }
}
