import 'product_image.model.dart';

class Product {
  final int? id;
  final int? categoryId;
  final String? categoryName;
  final String name;
  final double price;
  final String? description;
  final int stock;
  final List<ProductImage> images;

  Product({
    this.id,
    this.categoryId,
    this.categoryName,
    required this.name,
    required this.price,
    this.stock = 0,
    this.description,
    this.images = const [],
  });

  factory Product.fromMap(
    Map<String, dynamic> map, {
    List<ProductImage> images = const [],
  }) {
    return Product(
      id: map['id'],
      categoryId: map['category_id'],
      categoryName: map['category_name'],
      name: map['name'],
      price: map['price'],
      stock: map['stock'],
      description: map['description'],
      images: images,
    );
  }
}
