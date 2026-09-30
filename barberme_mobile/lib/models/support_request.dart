class SupportRequest {
  final int id;
  final int? userId;
  final String fullName;
  final String email;
  final String subject;
  final String message;
  final int status;
  final DateTime createdAt;

  SupportRequest({
    required this.id,
    this.userId,
    required this.fullName,
    required this.email,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    return SupportRequest(
      id: json['id'] as int,
      userId: json['userId'] as int?,
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status'] as int,
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }

  bool get isOpen => status == 1;
  bool get isInProgress => status == 2;
  bool get isClosed => status == 3;

  String get statusName {
    switch (status) {
      case 1:
        return 'Open';
      case 2:
        return 'In Progress';
      case 3:
        return 'Closed';
      default:
        return 'Unknown';
    }
  }
}