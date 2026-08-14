class AvailableSlot {
  final DateTime startDateTime;
  final DateTime endDateTime;

  AvailableSlot({
    required this.startDateTime,
    required this.endDateTime,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      startDateTime: DateTime.parse(json['startDateTime']),
      endDateTime: DateTime.parse(json['endDateTime']),
    );
  }
}