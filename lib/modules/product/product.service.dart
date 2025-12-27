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

  Future<int> saveProduct(Product product) async {
    final db = await _dbService.database;

    if (product.id == null) {
      // CREATE
      return await db.insert('product', {
        'category_id': product.categoryId,
        'name': product.name,
        'price': product.price,
        'stock': product.stock,
        'description': product.description,
      });
    } else {
      // UPDATE
      return await db.update(
        'product',
        {
          'category_id': product.categoryId,
          'name': product.name,
          'price': product.price,
          'stock': product.stock,
          'description': product.description,
        },
        where: 'id = ?',
        whereArgs: [product.id],
      );
    }
  }

  Future<void> saveProductImages(
    int productId,
    List<ProductImage> images,
  ) async {
    final db = await _dbService.database;

    // Simple sync: Delete existing and re-insert current list
    await db.delete(
      'product_image',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    for (var img in images) {
      await db.insert('product_image', {
        'product_id': productId,
        'path': img.path,
        'is_thumbnail': img.isThumbnail ? 1 : 0,
      });
    }
  }

  Future<Product?> getProductById(int id) async {
    final db = await _dbService.database;

    // 1. Fetch product data
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT p.*, pc.name as category_name
    FROM product p
    LEFT JOIN product_category pc ON p.category_id = pc.id
    WHERE p.id = ?
  ''',
      [id],
    );

    if (maps.isEmpty) return null;

    // 2. Fetch images for this specific product
    final List<Map<String, dynamic>> imageMaps = await db.query(
      'product_image',
      where: 'product_id = ?',
      whereArgs: [id],
    );

    List<ProductImage> images = imageMaps
        .map(
          (img) => ProductImage(
            productId: id,
            path: img['path'],
            isThumbnail: img['is_thumbnail'] == 1,
          ),
        )
        .toList();

    return Product.fromMap(maps.first, images: images);
  }

  Future<void> deleteProduct(int id) async {
    final db = await _dbService.database;

    // 1. Check if product is used in any transaction
    final List<Map<String, dynamic>> transactionItems = await db.query(
      'transaction_items',
      where: 'product_id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (transactionItems.isNotEmpty) {
      throw Exception(
        'Produk tidak dapat dihapus karena sudah memiliki riwayat transaksi.',
      );
    }

    await db.transaction((txn) async {
      // 2. Delete Child Images first
      await txn.delete(
        'product_image',
        where: 'product_id = ?',
        whereArgs: [id],
      );

      // 3. Delete Product
      await txn.delete('product', where: 'id = ?', whereArgs: [id]);
    });
  }
}
