import 'staff_table.dart';
import 'customer_table.dart';

class TransactionTable {
  static const String tableName = 'transactions';

  static const String createTable =
      '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      total_amount REAL NOT NULL,
      payment_method TEXT,
      staff_id INTEGER,
      customer_id INTEGER,
      status TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (staff_id) REFERENCES ${StaffTable.tableName} (id) ON DELETE SET NULL,
      FOREIGN KEY (customer_id) REFERENCES ${CustomerTable.tableName} (id) ON DELETE SET NULL
    )
  ''';
}
