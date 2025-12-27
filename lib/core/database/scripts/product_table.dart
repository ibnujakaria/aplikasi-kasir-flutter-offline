class ProductTable {
  static const String tableName = 'product';

  static const String createTable =
      '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER, -- New Column
      name TEXT NOT NULL,
      price REAL NOT NULL,
      description TEXT,
      stock INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (category_id) REFERENCES product_category (id) ON DELETE SET NULL
    )
  ''';
}
