import 'package:sqflite/sqflite.dart';
import '_product_category.seeder.dart';
import '_product.seeder.dart';

class DatabaseSeeder {
  static Future<void> run(Database db) async {
    print("Checking if seeding is required...");

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM product_category'),
    );

    if (count == 0) {
      print("Seeding initial data...");
      await ProductCategorySeeder.seed(db); // Seed Category FIRST
      await ProductSeeder.seed(db); // Seed Product SECOND
      print("Seeding completed!");
    }
  }
}
