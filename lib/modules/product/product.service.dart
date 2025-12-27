import '../../core/database/database.service.dart';
import 'models/product.model.dart';
import 'models/product_image.model.dart';

class ProductService {
  final _dbService = DatabaseService();

  Future<List<Product>> getAllProducts() async {
    final db = await _dbService.database;

    // We join product_category to get the name of the category
    // and product_image to get the thumbnail
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        p.*, 
        pc.name as category_name,
        pi.path as thumbnail 
      FROM product p
      LEFT JOIN product_category pc ON p.category_id = pc.id
      LEFT JOIN product_image pi ON p.id = pi.product_id AND pi.is_thumbnail = 1
    ''');

    return maps.map((map) {
      // Create the image object from the joined path
      final images = map['thumbnail'] != null
          ? [
              ProductImage(
                productId: map['id'],
                path: map['thumbnail'],
                isThumbnail: true,
              ),
            ]
          : <ProductImage>[];

      return Product.fromMap(map, images: images);
    }).toList();
  }
}
