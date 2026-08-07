class BarberLevel {
  final int id;
  final String name;
  final bool isActive;

  BarberLevel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory BarberLevel.fromJson(Map<String, dynamic> json) {
    return BarberLevel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}