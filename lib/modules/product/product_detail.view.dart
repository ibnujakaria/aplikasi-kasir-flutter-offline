import 'package:aplikasi_kasir/modules/product/models/product_image.model.dart';
import 'package:flutter/material.dart';
import 'models/product.model.dart';

class ProductDetailView extends StatefulWidget {
  final Product product;
  const ProductDetailView({super.key, required this.product});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images.isNotEmpty
        ? widget.product.images
        : [ProductImage(productId: 0, path: 'https://via.placeholder.com/400')];

    return Scaffold(
      body: CustomScrollView(
        // This allows the "bounce" effect when pulling down
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. THE FLEXIBLE IMAGE HEADER
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true, // Keeps the title visible when scrolled up
            stretch: true, // Allows the image to "stretch" when pulled down
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  PageView.builder(
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final path = images[index].path;
                      return Hero(
                        // Smooth transition from the grid card
                        tag: 'product-${widget.product.id}',
                        child: path.startsWith('http')
                            ? Image.network(path, fit: BoxFit.cover)
                            : Image.asset(path, fit: BoxFit.cover),
                      );
                    },
                  ),
                  // Image Counter
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
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => print("Edit Mode"),
              ),
            ],
          ),

          // 2. THE SLIDABLE WHITE CONTENT
          SliverToBoxAdapter(
            child: Container(
              // Smooth rounded corners at the top that overlap the image slightly
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Chip(
                      label: Text(widget.product.categoryName ?? 'Menu'),
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Rp ${widget.product.price.toInt()}',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.orange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),

                    const Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      widget.product.description ?? 'Belum ada deskripsi.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    ),

                    // Add extra space at the bottom to ensure the user can scroll past the bottom bar
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
