class CalendarAvailability {
  final DateTime date;
  final bool isWorkingDay;
  final bool hasAvailableSlots;

  CalendarAvailability({
    required this.date,
    required this.isWorkingDay,
    required this.hasAvailableSlots,
  });

  factory CalendarAvailability.fromJson(
    Map<String, dynamic> json,
  ) {
    return CalendarAvailability(
      date: DateTime.parse(json['date']),
      isWorkingDay: json['isWorkingDay'] as bool,
      hasAvailableSlots:
          json['hasAvailableSlots'] as bool,
    );
  }
}