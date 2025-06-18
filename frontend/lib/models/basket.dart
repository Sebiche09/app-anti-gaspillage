class Basket {
  final int id;
  final String name;
  final String address;
  final double rating;
  final double originalPrice;
  final double discountPercentage;
  final String description;
  final String category;
  final double latitude;
  final double longitude;

  Basket({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.originalPrice,
    required this.discountPercentage,
    required this.description,
    required this.category,
    required this.latitude,   
    required this.longitude,  
  });

  factory Basket.fromJson(Map<String, dynamic> json) {
    return Basket(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      rating: (json['rating'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      category: json['category'],
      latitude: (json['latitude'] ?? 0).toDouble(),    
      longitude: (json['longitude'] ?? 0).toDouble(),  
    );
  }
}
