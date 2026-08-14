class BarberService {
  final int id;
  final int barberId;
  final String barberFullName;
  final int serviceId;
  final String serviceName;
  final double price;
  final int durationMinutes;

  BarberService({
    required this.id,
    required this.barberId,
    required this.barberFullName,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.durationMinutes,
  });

  factory BarberService.fromJson(Map<String, dynamic> json) {
    return BarberService(
      id: json['id'] as int,
      barberId: json['barberId'] as int,
      barberFullName: json['barberFullName'] as String,
      serviceId: json['serviceId'] as int,
      serviceName: json['serviceName'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int,
    );
  }
}