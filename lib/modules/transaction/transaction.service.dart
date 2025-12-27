import 'package:sqflite/sqflite.dart' as sql;
import '../../core/database/database.service.dart';
import '../../core/database/scripts/transaction_table.dart';
import '../../core/database/scripts/transaction_item_table.dart';
import '../../core/database/scripts/product_table.dart';
import 'models/transaction.model.dart';
import 'models/transaction_item.model.dart';

class TransactionService {
  final DatabaseService _databaseService = DatabaseService();

  Future<Transaction?> createTransaction({
    required double totalAmount,
    required String paymentMethod,
    required int? staffId,
    required int? customerId,
    required List<Map<String, dynamic>>
    cartItems, // [{product: Product, qty: int}]
  }) async {
    final db = await _databaseService.database;

    return await db.transaction((txn) async {
      try {
        // 1. Insert Transaction
        final transactionId = await txn.insert(TransactionTable.tableName, {
          'total_amount': totalAmount,
          'payment_method': paymentMethod,
          'staff_id': staffId,
          'customer_id': customerId,
          'status': TransactionStatus.preparing.toMap(),
          // created_at is default
        });

        // 2. Insert Items & Update Stock
        final List<TransactionItem> items = [];
        for (var item in cartItems) {
          final product = item['product']; // Assuming Product object
          final qty = item['qty'] as int;
          final price =
              product.price as double; // Capture price at time of transaction

          // Insert Item
          final itemId = await txn.insert(TransactionItemTable.tableName, {
            'transaction_id': transactionId,
            'product_id': product.id,
            'quantity': qty,
            'price': price,
          });

          items.add(
            TransactionItem(
              id: itemId,
              transactionId: transactionId,
              productId: product.id!,
              quantity: qty,
              price: price,
            ),
          );

          // Decrement Stock
          int count = await txn.rawUpdate(
            'UPDATE ${ProductTable.tableName} SET stock = stock - ? WHERE id = ?',
            [qty, product.id],
          );

          if (count == 0) {
            throw Exception("Failed to update stock for product ${product.id}");
          }
        }

        return Transaction(
          id: transactionId,
          totalAmount: totalAmount,
          paymentMethod: paymentMethod,
          staffId: staffId,
          customerId: customerId,
          status: TransactionStatus.preparing,
          items: items,
          createdAt: DateTime.now(), // Approximate
        );
      } catch (e) {
        print("Transaction Error: $e");
        return null; // Trigger rollback
      }
    });
  }

  Future<List<Transaction>> getTransactions({
    String? query,
    TransactionStatus? status,
    String orderBy = 'created_at DESC',
  }) async {
    final db = await _databaseService.database;

    String whereClause = '';
    List<dynamic> args = [];

    // Filter by Status
    if (status != null) {
      whereClause += 't.status = ?';
      args.add(status.toMap());
    }

    // Filter by Search Query
    if (query != null && query.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      // Search by ID, Payment Method, or Customer Name
      whereClause +=
          '(t.id LIKE ? OR t.payment_method LIKE ? OR c.name LIKE ?)';
      args.add('%$query%');
      args.add('%$query%');
      args.add('%$query%');
    }

    // Perform JOIN
    final sql =
        '''
      SELECT t.*, c.name as customer_name
      FROM ${TransactionTable.tableName} t
      LEFT JOIN customer c ON t.customer_id = c.id
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
      ORDER BY t.$orderBy
    ''';

    final maps = await db.rawQuery(sql, args);

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<void> updateTransactionStatus(int id, TransactionStatus status) async {
    final db = await _databaseService.database;
    await db.update(
      TransactionTable.tableName,
      {'status': status.toMap()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
