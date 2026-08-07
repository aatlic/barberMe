import 'barber_level.dart';
import 'role.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String? profileImagePath;

  final bool isActive;
  final bool isLocked;
  final DateTime? lockedUntil;
  final int failedLoginAttempts;
  final bool requirePasswordChange;
  final bool receiveNewsletter;

  final double discountPercent;
  final bool hasNoShowPenalty;

  final Role role;
  final BarberLevel? barberLevel;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.profileImagePath,
    required this.isActive,
    required this.isLocked,
    this.lockedUntil,
    required this.failedLoginAttempts,
    required this.requirePasswordChange,
    required this.receiveNewsletter,
    required this.discountPercent,
    required this.hasNoShowPenalty,
    required this.role,
    this.barberLevel,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      profileImagePath: json['profileImagePath']?.toString(),
      isActive: json['isActive'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      lockedUntil: json['lockedUntil'] != null
          ? DateTime.tryParse(json['lockedUntil'].toString())
          : null,
      failedLoginAttempts: json['failedLoginAttempts'] as int? ?? 0,
      requirePasswordChange:
          json['requirePasswordChange'] as bool? ?? false,
      receiveNewsletter:
          json['receiveNewsletter'] as bool? ?? false,
      discountPercent:
          (json['discountPercent'] as num?)?.toDouble() ?? 0,
      hasNoShowPenalty:
          json['hasNoShowPenalty'] as bool? ?? false,
      role: Role.fromJson(
        json['role'] as Map<String, dynamic>,
      ),
      barberLevel: json['barberLevel'] != null
          ? BarberLevel.fromJson(
              json['barberLevel'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}