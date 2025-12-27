import 'package:aplikasi_kasir/core/utils/currency_format.dart';
import 'package:aplikasi_kasir/modules/product/product_detail.view.dart';
import 'package:flutter/material.dart';
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

    return GestureDetector(
      onTap:
          onTap ??
          () {
            if (product.id != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailView(productId: product.id!),
                ),
              );
            }
          },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. WRAP THE IMAGE IN EXPANDED
            // This forces the image area to take up all space EXCEPT what the text needs
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    // Make image fill the Expanded area
                    child: imageUrl.startsWith('http')
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : Image.asset(imageUrl, fit: BoxFit.cover),
                  ),
                  // Category Tag
                  Positioned(
                    top: 8,
                    right: 8,
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
                        product.categoryName ?? 'Tanpa Kategori',
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

            // 2. CONTENT SECTION (Fixed size at bottom)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Keep this section small
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
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(
                      product.price,
                    ), // Changed from 'Rp ${product.price.toInt()}'
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
    );
  }
}
