class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final bool isMerchant;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isMerchant,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      isMerchant: json['isMerchant'] ?? false,
    );
  }
}