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
          'created_at': DateTime.now().toIso8601String(),
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

    // Perform JOIN with customer and staff tables
    final sql =
        '''
      SELECT t.*, c.name as customer_name, s.name as staff_name
      FROM ${TransactionTable.tableName} t
      LEFT JOIN customer c ON t.customer_id = c.id
      LEFT JOIN staff s ON t.staff_id = s.id
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

  Future<void> deleteTransaction(int id) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      // 1. Delete Items (Cascade usually handles this if configured, but manual is safer for logic)
      await txn.delete(
        TransactionItemTable.tableName,
        where: 'transaction_id = ?',
        whereArgs: [id],
      );

      // 2. Delete Transaction
      await txn.delete(
        TransactionTable.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    ).toIso8601String();

    // 1. Today's Revenue (Sum total_amount where status != cancelled)
    final revenueResult = await db.rawQuery(
      '''
      SELECT SUM(total_amount) as total 
      FROM ${TransactionTable.tableName} 
      WHERE created_at >= ? AND created_at <= ? 
      AND status != ?
    ''',
      [startOfDay, endOfDay, TransactionStatus.cancelled.toMap()],
    );

    final double todayRevenue =
        (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // 2. Today's Transactions Count
    final countResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count 
      FROM ${TransactionTable.tableName} 
      WHERE created_at >= ? AND created_at <= ?
    ''',
      [startOfDay, endOfDay],
    );

    final int todayCount = (countResult.first['count'] as int?) ?? 0;

    // 3. Recent Transactions (Limit 5)
    final recentMaps = await db.rawQuery('''
      SELECT t.*, c.name as customer_name
      FROM ${TransactionTable.tableName} t
      LEFT JOIN customer c ON t.customer_id = c.id
      ORDER BY t.created_at DESC
      LIMIT 5
    ''');

    final recentTransactions = List.generate(
      recentMaps.length,
      (i) => Transaction.fromMap(recentMaps[i]),
    );

    return {
      'today_revenue': todayRevenue,
      'today_count': todayCount,
      'recent_transactions': recentTransactions,
    };
  }
}
