class Staff {
  final int? id;
  final String name;
  final String role;
  final String avatar;
  final DateTime? createdAt;

  Staff({
    this.id,
    required this.name,
    this.role = 'Staff',
    required this.avatar,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'role': role, 'avatar': avatar};
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      avatar: map['avatar'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }
}
