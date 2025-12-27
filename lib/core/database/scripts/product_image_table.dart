class ProductImageTable {
  static const String tableName = 'product_image';

  static const String createTable =
      '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER,
      path TEXT,
      is_thumbnail INTEGER,
      FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE CASCADE
    )
  ''';
}
