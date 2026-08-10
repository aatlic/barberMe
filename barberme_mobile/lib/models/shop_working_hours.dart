class ShopWorkingHours {
  final int id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isWorking;

  ShopWorkingHours({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isWorking,
  });

  factory ShopWorkingHours.fromJson(Map<String, dynamic> json) {
    return ShopWorkingHours(
      id: json['id'] as int,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      isWorking: json['isWorking'] as bool? ?? false,
    );
  }
}