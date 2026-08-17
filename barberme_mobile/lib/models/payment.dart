class Payment {
  final int id;
  final int appointmentId;
  final double amount;
  final int status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? clientSecret;
  final String currency;

  Payment({
    required this.id,
    required this.appointmentId,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.paidAt,
    required this.clientSecret,
    required this.currency,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      appointmentId: json['appointmentId'] as int,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as int,
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      clientSecret: json['clientSecret'] as String?,
      currency: json['currency'] as String,
    );
  }
}