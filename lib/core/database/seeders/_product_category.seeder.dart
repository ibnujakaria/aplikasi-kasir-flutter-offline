import '../scripts/product_category.dart';
import 'package:sqflite/sqflite.dart';

class ProductCategorySeeder {
  static Future<void> seed(Database db) async {
    await db.insert(ProductCategoryTable.tableName, {
      'id': 1,
      'name': 'Makanan',
    });
    await db.insert(ProductCategoryTable.tableName, {
      'id': 2,
      'name': 'Minuman',
    });
  }
}
