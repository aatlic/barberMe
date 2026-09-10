class WorkingHours {
  final int id;
  final int barberId;
  final String barberFullName;
  final int dayOfWeek;
  final String dayName;
  final String startTime;
  final String endTime;
  final bool isWorking;

  WorkingHours({
    required this.id,
    required this.barberId,
    required this.barberFullName,
    required this.dayOfWeek,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.isWorking,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      id: json['id'] as int,
      barberId: json['barberId'] as int,
      barberFullName: json['barberFullName']?.toString() ?? '',
      dayOfWeek: json['dayOfWeek'] as int,
      dayName: json['dayName']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      isWorking: json['isWorking'] as bool? ?? false,
    );
  }
}