class CustomerTable {
  static const String tableName = 'customer';

  static const String createTable =
      '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      phone TEXT
    )
  ''';
}
