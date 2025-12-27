class ProductImage {
  final int? id;
  final int productId;
  final String path;
  bool isThumbnail;

  ProductImage({
    this.id,
    required this.productId,
    required this.path,
    this.isThumbnail = false,
  });

  factory ProductImage.fromMap(Map<String, dynamic> map) {
    return ProductImage(
      id: map['id'],
      productId: map['product_id'],
      path: map['path'],
      isThumbnail: map['is_thumbnail'] == 1,
    );
  }
}
