class Customer {
  final int? id;
  final String name;
  final String? phone;
  final DateTime? createdAt;

  Customer({this.id, required this.name, this.phone, this.createdAt});

  factory Customer.fromMap(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      // created_at is default by DB
    };
  }
}
