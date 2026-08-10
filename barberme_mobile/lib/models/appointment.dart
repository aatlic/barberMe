class Appointment {
  final int id;

  final int clientId;
  final String clientFullName;

  final int barberId;
  final String barberFullName;

  final int barberServiceId;

  final int serviceId;
  final String serviceName;

  final double price;
  final int durationMinutes;

  final DateTime startDateTime;
  final DateTime endDateTime;

  final String status;

  final bool isPaid;
  final bool reminderEnabled;

  final String? cancellationReason;

  final bool hasReview;

  final double basePrice;
  final double appliedDiscountPercent;
  final double appliedPenaltyPercent;
  final double finalPrice;

  Appointment({
    required this.id,
    required this.clientId,
    required this.clientFullName,
    required this.barberId,
    required this.barberFullName,
    required this.barberServiceId,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.durationMinutes,
    required this.startDateTime,
    required this.endDateTime,
    required this.status,
    required this.isPaid,
    required this.reminderEnabled,
    required this.cancellationReason,
    required this.hasReview,
    required this.basePrice,
    required this.appliedDiscountPercent,
    required this.appliedPenaltyPercent,
    required this.finalPrice,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int,
      clientId: json['clientId'] as int,
      clientFullName: json['clientFullName']?.toString() ?? '',
      barberId: json['barberId'] as int,
      barberFullName: json['barberFullName']?.toString() ?? '',
      barberServiceId: json['barberServiceId'] as int,
      serviceId: json['serviceId'] as int,
      serviceName: json['serviceName']?.toString() ?? '',
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int,
      startDateTime: DateTime.parse(
        json['startDateTime'].toString(),
      ),
      endDateTime: DateTime.parse(
        json['endDateTime'].toString(),
      ),
      status: json['status'].toString(),
      isPaid: json['isPaid'] as bool? ?? false,
      reminderEnabled:
          json['reminderEnabled'] as bool? ?? false,
      cancellationReason:
          json['cancellationReason']?.toString(),
      hasReview: json['hasReview'] as bool? ?? false,
      basePrice: (json['basePrice'] as num).toDouble(),
      appliedDiscountPercent:
          (json['appliedDiscountPercent'] as num).toDouble(),
      appliedPenaltyPercent:
          (json['appliedPenaltyPercent'] as num).toDouble(),
      finalPrice: (json['finalPrice'] as num).toDouble(),
    );
  }
}