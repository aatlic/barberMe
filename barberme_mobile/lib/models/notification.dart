class AppNotification {
  final int id;
  final int userId;

  final int notificationTypeId;
  final String notificationTypeName;

  final String title;
  final String text;

  final bool isRead;

  final DateTime createdAt;
  final DateTime? readAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.notificationTypeId,
    required this.notificationTypeName,
    required this.title,
    required this.text,
    required this.isRead,
    required this.createdAt,
    required this.readAt,
  });

  factory AppNotification.fromJson(
    Map<String, dynamic> json,
  ) {
    return AppNotification(
      id: json['id'] as int,
      userId: json['userId'] as int,
      notificationTypeId:
          json['notificationTypeId'] as int,
      notificationTypeName:
          json['notificationTypeName']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['createdAt'].toString(),
      ),
      readAt: json['readAt'] != null
          ? DateTime.parse(
              json['readAt'].toString(),
            )
          : null,
    );
  }
}