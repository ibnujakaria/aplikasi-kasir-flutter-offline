import 'transaction_item.model.dart';

enum TransactionStatus {
  preparing,
  served,
  finished,
  cancelled;

  String toMap() => name;
  static TransactionStatus fromMap(String name) => values.firstWhere(
    (e) => e.name == name,
    orElse: () => TransactionStatus.preparing,
  );
}

class Transaction {
  final int? id;
  final double totalAmount;
  final String? paymentMethod;
  final int? staffId;
  final int? customerId;
  final String? customerName; // Transient field from JOIN
  final String? staffName; // Transient field from JOIN
  final TransactionStatus status;
  final DateTime? createdAt;
  final List<TransactionItem>? items;

  Transaction({
    this.id,
    required this.totalAmount,
    this.paymentMethod,
    this.staffId,
    this.customerId,
    this.customerName,
    this.staffName,
    this.status = TransactionStatus.preparing,
    this.createdAt,
    this.items,
  });

  factory Transaction.fromMap(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      totalAmount: json['total_amount'],
      paymentMethod: json['payment_method'],
      staffId: json['staff_id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      staffName: json['staff_name'],
      status: TransactionStatus.fromMap(json['status'] ?? 'preparing'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'staff_id': staffId,
      'customer_id': customerId,
      'status': status.toMap(),
      // created_at is strictly handled by DB defaults usually, but can be passed if needed
    };
  }
}
