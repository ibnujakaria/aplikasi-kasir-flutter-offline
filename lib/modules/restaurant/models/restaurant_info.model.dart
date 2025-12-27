class RestaurantInfo {
  final int id; // Always 1
  final String name;
  final String? address;
  final String? phone;
  final String? description;
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final DateTime? createdAt;

  RestaurantInfo({
    this.id = 1,
    required this.name,
    this.address,
    this.phone,
    this.description,
    this.facebook,
    this.instagram,
    this.twitter,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 1, // Force ID to 1
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'facebook': facebook,
      'instagram': instagram,
      'twitter': twitter,
    };
  }

  factory RestaurantInfo.fromMap(Map<String, dynamic> map) {
    return RestaurantInfo(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      description: map['description'],
      facebook: map['facebook'],
      instagram: map['instagram'],
      twitter: map['twitter'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }
}
