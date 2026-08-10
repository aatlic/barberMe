import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/appointment.dart';
import '../models/paged_response.dart';

class AppointmentService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<PagedResponse<Appointment>> getAppointments({
    int? appointmentStatusId,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await _storage.read(key: 'jwt_token');

    final queryParameters = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

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
}