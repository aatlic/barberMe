class Service {
  final int id;
  final String name;
  final String? description;
  final double defaultPrice;
  final int defaultDurationMinutes;
  final String? imageUrl;
  final bool isActive;

  const Service({
    required this.id,
    required this.name,
    this.description,
    required this.defaultPrice,
    required this.defaultDurationMinutes,
    this.imageUrl,
    required this.isActive,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      defaultPrice:
          (json['defaultPrice'] as num).toDouble(),
      defaultDurationMinutes:
          json['defaultDurationMinutes'] as int,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool,
    );
  }
}