class StoreCategory {
  final int id;
  final String name;
  
  StoreCategory({
    required this.id, 
    required this.name
  });
  
  factory StoreCategory.fromJson(Map<String, dynamic> json) {
    return StoreCategory(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? 'Sans catégorie',
    );
  }
}