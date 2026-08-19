import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/appointment.dart';
import '../models/paged_response.dart';
import '../models/available_slot.dart';

import '../models/calendar_availability.dart';

class AppointmentService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<PagedResponse<Appointment>> getAppointments({
    int? appointmentStatusId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? listType,
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await _storage.read(key: 'jwt_token');

    final queryParameters = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    if (listType != null) {
      queryParameters['ListType'] = listType;
    }

    if (appointmentStatusId != null) {
      queryParameters['AppointmentStatusId'] =
          appointmentStatusId.toString();
    }

    if (dateFrom != null) {
      queryParameters['DateFrom'] =
          dateFrom.toIso8601String();
    }

    if (dateTo != null) {
      queryParameters['DateTo'] =
          dateTo.toIso8601String();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Appointments',
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return PagedResponse<Appointment>.fromJson(
        data,
        Appointment.fromJson,
      );
    }

    throw Exception('Failed to load appointments.');
  }

  Future<List<AvailableSlot>> getAvailableSlots({
    required int barberId,
    required int serviceId,
    required DateTime date,
  }) async {
    final token = await _storage.read(key: 'jwt_token');

    final formattedDate =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Appointments/available-slots',
    ).replace(
      queryParameters: {
        'barberId': barberId.toString(),
        'serviceId': serviceId.toString(),
        'date': formattedDate,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (item) => AvailableSlot.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load available time slots.',
    );
  }

  Future<Appointment> createAppointment({
    required int barberServiceId,
    required DateTime startDateTime,
    bool reminderEnabled = false,
  }) async {
    final token = await _storage.read(key: 'jwt_token');

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Appointments',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'barberServiceId': barberServiceId,
        'startDateTime': startDateTime.toIso8601String(),
        'reminderEnabled': reminderEnabled,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return Appointment.fromJson(data);
    }

    String message = 'Failed to book appointment.';

    try {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}
    
    throw Exception(message);
  }

  Future<void> updateReminder({
    required int appointmentId,
    required bool reminderEnabled,
  }) async {
    final token = await _storage.read(key: 'jwt_token');

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Appointments/$appointmentId/reminder',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reminderEnabled': reminderEnabled,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message = 'Failed to update reminder.';

    try {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }

  Future<List<CalendarAvailability>>
    getCalendarAvailability({
      required int barberId,
      required int serviceId,
      required int year,
      required int month,
    }) async {
      final token = await _storage.read(key: 'jwt_token');

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/Appointments/availability-calendar',
      ).replace(
        queryParameters: {
          'barberId': barberId.toString(),
          'serviceId': serviceId.toString(),
          'year': year.toString(),
          'month': month.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data =
            jsonDecode(response.body) as List<dynamic>;

        return data
            .map(
              (item) =>
                  CalendarAvailability.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      throw Exception(
        'Failed to load calendar availability.',
      );
    }

  Future<void> cancelAppointment({
    required int appointmentId,
    required String cancellationReason,
  }) async {
    final token = await _storage.read(key: 'jwt_token');

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Appointments/$appointmentId/cancel',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cancellationReason': cancellationReason,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message = 'Failed to cancel appointment.';

    try {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }

  Future<bool> rescheduleAppointment({
    required int appointmentId,
    required DateTime startDateTime,
  }) async {
    final token = await _storage.read(key: 'jwt_token');

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Appointments/$appointmentId/reschedule',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'startDateTime': startDateTime.toIso8601String(),
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body) as bool;
    }

    String message = 'Failed to reschedule appointment.';

    try {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }
}