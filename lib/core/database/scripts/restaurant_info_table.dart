class RestaurantInfoTable {
  static const String tableName = 'restaurant_info';

  static const String createTable =
      '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      name TEXT NOT NULL,
      address TEXT,
      phone TEXT,
      description TEXT,
      facebook TEXT,
      instagram TEXT,
      twitter TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    ''';
}
