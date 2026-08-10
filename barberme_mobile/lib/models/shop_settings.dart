class ShopSettings {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final String? description;

  ShopSettings({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    this.description,
  });

  factory ShopSettings.fromJson(Map<String, dynamic> json) {
    return ShopSettings(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }
}