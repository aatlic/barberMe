class Recommendation {
  final int recommendationId;
  final int barberServiceId;
  final int serviceId;
  final String serviceName;
  final int barberId;
  final String barberName;
  final double price;
  final int durationMinutes;
  final double score;
  final String explanation;
  final bool? wasAccepted;
  final DateTime createdAt;

  Recommendation({
    required this.recommendationId,
    required this.barberServiceId,
    required this.serviceId,
    required this.serviceName,
    required this.barberId,
    required this.barberName,
    required this.price,
    required this.durationMinutes,
    required this.score,
    required this.explanation,
    required this.wasAccepted,
    required this.createdAt,
  });

  factory Recommendation.fromJson(
    Map<String, dynamic> json,
  ) {
    return Recommendation(
      recommendationId:
          json['recommendationId'] as int,
      barberServiceId:
          json['barberServiceId'] as int,
      serviceId: json['serviceId'] as int,
      serviceName:
          json['serviceName']?.toString() ?? '',
      barberId: json['barberId'] as int,
      barberName:
          json['barberName']?.toString() ?? '',
      price:
          (json['price'] as num?)?.toDouble() ?? 0,
      durationMinutes:
          json['durationMinutes'] as int? ?? 0,
      score:
          (json['score'] as num?)?.toDouble() ?? 0,
      explanation:
          json['explanation']?.toString() ?? '',
      wasAccepted:
          json['wasAccepted'] as bool?,
      createdAt: DateTime.parse(
        json['createdAt'].toString(),
      ),
    );
  }
}