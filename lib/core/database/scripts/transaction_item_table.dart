import 'transaction_table.dart';
import 'product_table.dart';

class TransactionItemTable {
  static const String tableName = 'transaction_items';

  static const String createTable =
      '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transaction_id INTEGER NOT NULL,
      product_id INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      FOREIGN KEY (transaction_id) REFERENCES ${TransactionTable.tableName} (id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES ${ProductTable.tableName} (id) ON DELETE SET NULL
    )
  ''';
}
