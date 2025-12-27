import 'package:aplikasi_kasir/core/utils/currency_format.dart';
import 'package:aplikasi_kasir/modules/product/product_detail.view.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/product.model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty
        ? product.images.first.path
        : 'https://via.placeholder.com/150';

    final bool isOutOfStock = product.stock <= 0;

    void goToDetailPage() {
      if (product.id != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailView(productId: product.id!),
          ),
        );
      }
    }

    return GestureDetector(
      onTap: onTap ?? goToDetailPage,
      child: Opacity(
        opacity: isOutOfStock ? 0.6 : 1.0,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. IMAGE SECTION
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl.startsWith('http')
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Image.file(
                              File(imageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                    ),
                    // Out of Stock Overlay
                    if (isOutOfStock)
                      Container(
                        color: Colors.black45,
                        child: const Center(
                          child: Text(
                            "HABIS",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    // Category Tag
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.categoryName ?? 'Menu',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. CONTENT SECTION
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // --- STOCK DISPLAY ---
                    Text(
                      isOutOfStock ? "Stok Kosong" : "Stok: ${product.stock}",
                      style: TextStyle(
                        fontSize: 11,
                        color: isOutOfStock ? Colors.red : Colors.grey[600],
                        fontWeight: isOutOfStock
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(product.price),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
