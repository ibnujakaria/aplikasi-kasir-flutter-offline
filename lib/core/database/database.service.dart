import 'package:aplikasi_kasir/core/database/scripts/product_category.dart';
import 'package:aplikasi_kasir/core/database/scripts/staff_table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'scripts/restaurant_info_table.dart';

import 'scripts/product_table.dart';
import 'scripts/product_image_table.dart';
import 'scripts/customer_table.dart';
import 'scripts/transaction_table.dart';
import 'scripts/transaction_item_table.dart';

import 'seeders/database.seeder.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'resto_kasir.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      // This is crucial for Foreign Keys to work!
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // We place them in a list.
    // IMPORTANT: ProductTable must be first because ProductImageTable depends on it!
    final scripts = [
      ProductCategoryTable.createTable,
      ProductTable.createTable,
      ProductImageTable.createTable,
      CustomerTable.createTable,
      StaffTable.createTable,
      RestaurantInfoTable.createTable,
      TransactionTable.createTable,
      TransactionItemTable.createTable,
    ];

    for (var script in scripts) {
      await db.execute(script);
    }

    print("Database and Tables created successfully!");

    await DatabaseSeeder.run(db);
  }
}
