class Report {
  final DateTime dateFrom;
  final DateTime dateTo;

  final int? barberId;
  final String barberName;

  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int uniqueClients;

  final double totalRevenue;

  final List<ReportServiceItem> services;
  final List<ReportAppointmentItem> appointments;

  final DateTime generatedAt;

  const Report({
    required this.dateFrom,
    required this.dateTo,
    required this.barberId,
    required this.barberName,
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.uniqueClients,
    required this.totalRevenue,
    required this.services,
    required this.appointments,
    required this.generatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      dateFrom: DateTime.parse(json['dateFrom']),
      dateTo: DateTime.parse(json['dateTo']),
      barberId: json['barberId'],
      barberName: json['barberName'] ?? 'All barbers',
      totalAppointments: json['totalAppointments'] ?? 0,
      completedAppointments: json['completedAppointments'] ?? 0,
      cancelledAppointments: json['cancelledAppointments'] ?? 0,
      uniqueClients: json['uniqueClients'] ?? 0,
      totalRevenue:
          (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      services: (json['services'] as List<dynamic>? ?? [])
          .map(
            (item) => ReportServiceItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      appointments:
          (json['appointments'] as List<dynamic>? ?? [])
              .map(
                (item) => ReportAppointmentItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
}

class ReportAppointmentItem {
  final int appointmentId;

  final String clientName;
  final String barberName;
  final String serviceName;

  final DateTime startDateTime;

  final String status;

  final double basePrice;
  final double appliedDiscountPercent;
  final double appliedPenaltyPercent;
  final double finalPrice;

  final bool isPaid;

  const ReportAppointmentItem({
    required this.appointmentId,
    required this.clientName,
    required this.barberName,
    required this.serviceName,
    required this.startDateTime,
    required this.status,
    required this.basePrice,
    required this.appliedDiscountPercent,
    required this.appliedPenaltyPercent,
    required this.finalPrice,
    required this.isPaid,
  });

  factory ReportAppointmentItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportAppointmentItem(
      appointmentId: json['appointmentId'] ?? 0,
      clientName: json['clientName'] ?? '',
      barberName: json['barberName'] ?? '',
      serviceName: json['serviceName'] ?? '',
      startDateTime: DateTime.parse(
        json['startDateTime'],
      ),
      status: json['status'] ?? '',
      basePrice:
          (json['basePrice'] as num?)?.toDouble() ?? 0,
      appliedDiscountPercent:
          (json['appliedDiscountPercent'] as num?)
                  ?.toDouble() ??
              0,
      appliedPenaltyPercent:
          (json['appliedPenaltyPercent'] as num?)
                  ?.toDouble() ??
              0,
      finalPrice:
          (json['finalPrice'] as num?)?.toDouble() ?? 0,
      isPaid: json['isPaid'] ?? false,
    );
  }
}

class ReportServiceItem {
  final int serviceId;
  final String serviceName;

  final int appointmentCount;

  final double unitPrice;
  final double totalRevenue;

  const ReportServiceItem({
    required this.serviceId,
    required this.serviceName,
    required this.appointmentCount,
    required this.unitPrice,
    required this.totalRevenue,
  });

  factory ReportServiceItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportServiceItem(
      serviceId: json['serviceId'] ?? 0,
      serviceName: json['serviceName'] ?? '',
      appointmentCount: json['appointmentCount'] ?? 0,
      unitPrice:
          (json['unitPrice'] as num?)?.toDouble() ?? 0,
      totalRevenue:
          (json['totalRevenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class BarberPerformanceReport {
  final DateTime dateFrom;
  final DateTime dateTo;

  final int totalCompletedAppointments;
  final int totalUniqueClients;

  final double totalRevenue;

  final List<BarberPerformanceItem> barbers;

  final DateTime generatedAt;

  const BarberPerformanceReport({
    required this.dateFrom,
    required this.dateTo,
    required this.totalCompletedAppointments,
    required this.totalUniqueClients,
    required this.totalRevenue,
    required this.barbers,
    required this.generatedAt,
  });

  factory BarberPerformanceReport.fromJson(
    Map<String, dynamic> json,
  ) {
    return BarberPerformanceReport(
      dateFrom: DateTime.parse(json['dateFrom']),
      dateTo: DateTime.parse(json['dateTo']),
      totalCompletedAppointments:
          json['totalCompletedAppointments'] ?? 0,
      totalUniqueClients:
          json['totalUniqueClients'] ?? 0,
      totalRevenue:
          (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      barbers: (json['barbers'] as List<dynamic>? ?? [])
          .map(
            (item) => BarberPerformanceItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
}

class BarberPerformanceItem {
  final int barberId;
  final String barberName;

  final int completedAppointments;
  final int uniqueClients;

  final double totalRevenue;
  final double averageRating;

  final String mostPopularService;

  const BarberPerformanceItem({
    required this.barberId,
    required this.barberName,
    required this.completedAppointments,
    required this.uniqueClients,
    required this.totalRevenue,
    required this.averageRating,
    required this.mostPopularService,
  });

  factory BarberPerformanceItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return BarberPerformanceItem(
      barberId: json['barberId'] ?? 0,
      barberName: json['barberName'] ?? '',
      completedAppointments:
          json['completedAppointments'] ?? 0,
      uniqueClients: json['uniqueClients'] ?? 0,
      totalRevenue:
          (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      averageRating:
          (json['averageRating'] as num?)?.toDouble() ?? 0,
      mostPopularService:
          json['mostPopularService'] ?? 'No data',
    );
  }
}