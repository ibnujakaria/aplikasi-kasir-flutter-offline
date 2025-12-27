import 'package:flutter/material.dart';
import 'models/product.model.dart';
import 'product.service.dart';
import 'product_form.view.dart';

class ProductDetailView extends StatefulWidget {
  final int productId; // Changed from Product to int
  const ProductDetailView({super.key, required this.productId});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final _service = ProductService();
  late Future<Product?> _productFuture;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _refreshProduct();
  }

  void _refreshProduct() {
    setState(() {
      _productFuture = _service.getProductById(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Product?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Produk tidak ditemukan"));
          }

          final product = snapshot.data!;
          final images = product.images;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      PageView.builder(
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemCount: images.isEmpty ? 1 : images.length,
                        itemBuilder: (context, index) {
                          final path = images.isEmpty
                              ? 'https://via.placeholder.com/400'
                              : images[index].path;
                          return Hero(
                            tag: 'product-${product.id}',
                            child: path.startsWith('http')
                                ? Image.network(path, fit: BoxFit.cover)
                                : Image.asset(path, fit: BoxFit.cover),
                          );
                        },
                      ),
                      if (images.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentPage + 1} / ${images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      // Wait for the result from the Form Page
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => ProductFormView(product: product),
                        ),
                      );
                      // When user comes back, RE-READ the database
                      _refreshProduct();
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          label: Text(product.categoryName ?? 'Menu'),
                          backgroundColor: Colors.orange.withOpacity(0.1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${product.price.toInt()}',
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.orange,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Divider(height: 40),
                        const Text(
                          "Deskripsi",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.description ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
