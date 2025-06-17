class Store {
  final int id;
  final String name;
  final String address;
  final String city;
  final String postalCode;
  final String phoneNumber;
  final int categoryId;
  final double? latitude;
  final double? longitude;
  final double? rating;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.phoneNumber,
    required this.categoryId,
    this.latitude,
    this.longitude,
    this.rating,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['ID'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postal_code'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      categoryId: json['category_id'] ?? 0,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      rating: json['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'phone_number': phoneNumber,
      'category_id': categoryId,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
    };
  }
}