class ProductCategoryTable {
  static const String tableName = 'product_category';

  static const String createTable =
      '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ''';
}
