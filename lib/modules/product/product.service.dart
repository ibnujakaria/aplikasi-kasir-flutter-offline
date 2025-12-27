import '../../core/database/database.service.dart';
import 'models/product.model.dart';
import 'models/product_image.model.dart';

class ProductService {
  final _dbService = DatabaseService();

  Future<List<Product>> getAllProducts() async {
    final db = await _dbService.database;

    // 1. Fetch all products and their category names
    final List<Map<String, dynamic>> productMaps = await db.rawQuery('''
    SELECT 
      p.*, 
      pc.name as category_name
    FROM product p
    LEFT JOIN product_category pc ON p.category_id = pc.id
  ''');

    // 2. Fetch ALL images from the image table
    final List<Map<String, dynamic>> imageMaps = await db.query(
      'product_image',
    );

    // 3. Group images by product_id for quick lookup
    // Result: { productId: [ProductImage, ProductImage], ... }
    Map<int, List<ProductImage>> imageGroup = {};
    for (var imgMap in imageMaps) {
      int productId = imgMap['product_id'];
      if (!imageGroup.containsKey(productId)) {
        imageGroup[productId] = [];
      }
      imageGroup[productId]!.add(
        ProductImage(
          productId: productId,
          path: imgMap['path'],
          isThumbnail: imgMap['is_thumbnail'] == 1,
        ),
      );
    }

    // 4. Map products and attach their specific image list
    return productMaps.map((map) {
      int productId = map['id'];
      return Product.fromMap(
        map,
        images: imageGroup[productId] ?? [], // Attach all images found
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await _dbService.database;
    return await db.query('product_category');
  }
}
