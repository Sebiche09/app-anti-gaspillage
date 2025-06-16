class Basket {
  final String id;
  final String name;
  final String address;
  final double rating;
  final double originalPrice;
  final double discountPrice;
  final String typeBasket;
  final String category;
  final double latitude;
  final double longitude;

  Basket({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.originalPrice,
    required this.discountPrice,
    required this.typeBasket,
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
      discountPrice: (json['discountPrice'] ?? 0).toDouble(),
      typeBasket: json['typeBasket'],
      category: json['category'],
      latitude: (json['latitude'] ?? 0).toDouble(),    
      longitude: (json['longitude'] ?? 0).toDouble(),  
    );
  }
}
