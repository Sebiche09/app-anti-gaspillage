class Basket {
  final String id;
  final String name;
  final String address;
  final double rating;
  final double originalPrice;
  final double discountPrice;
  final String typeBasket;
  final String category;

  Basket({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.originalPrice,
    required this.discountPrice,
    required this.typeBasket,
    required this.category,
  });

  factory Basket.fromJson(Map<String, dynamic> json) {
    return Basket(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      rating: json['rating'].toDouble(),
      originalPrice: json['originalPrice'].toDouble(),
      discountPrice: json['discountPrice'].toDouble(),
      typeBasket: json['typeBasket'],
      category: json['category'],
    );
  }
}