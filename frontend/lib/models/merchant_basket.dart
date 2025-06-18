class MerchantBasket {
  final int id;
  final String name;
  final double originalPrice;
  final double discountPercentage;
  final String category;
  final String description;
  final int quantity;

  MerchantBasket({
    required this.id,
    required this.name,
    required this.originalPrice,
    required this.discountPercentage,
    required this.category,
    required this.description,
    required this.quantity,
  });

  factory MerchantBasket.fromJson(Map<String, dynamic> json) {
    return MerchantBasket(
      id: json['id'],
      name: json['name'],
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }
}