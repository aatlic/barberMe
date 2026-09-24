import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/working_hours.dart';

class WorkingHoursService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<List<WorkingHours>> getMyWorkingHours() async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/WorkingHours/me',
      ),
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
            (item) => WorkingHours.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load working hours.',
      ),
    );
  }

  Future<List<WorkingHours>> getByBarber(
    int barberId,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/WorkingHours/barber/$barberId',
      ),
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
            (item) => WorkingHours.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load barber working hours.',
      ),
    );
  }

  Future<WorkingHours> createWorkingHours({
    required int barberId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required bool isWorking,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/WorkingHours',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'barberId': barberId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'isWorking': isWorking,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return WorkingHours.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to create working hours.',
      ),
    );
  }

  Future<WorkingHours> updateWorkingHours({
    required int id,
    required String startTime,
    required String endTime,
    required bool isWorking,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/WorkingHours/$id',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'startTime': startTime,
        'endTime': endTime,
        'isWorking': isWorking,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return WorkingHours.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to update working hours.',
      ),
    );
  }

  Future<void> deleteWorkingHours(
    int id,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/WorkingHours/$id',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to delete working hours.',
      ),
    );
  }

  String _getErrorMessage(
    String body,
    String fallback,
  ) {
    try {
      final data =
          jsonDecode(body) as Map<String, dynamic>;

      if (data['message'] != null) {
        return data['message'].toString();
      }

      if (data['errors'] is List &&
          (data['errors'] as List).isNotEmpty) {
        return (data['errors'] as List)
            .first
            .toString();
      }

      if (data['errors']
          is Map<String, dynamic>) {
        final errors =
            data['errors']
                as Map<String, dynamic>;

        for (final value in errors.values) {
          if (value is List &&
              value.isNotEmpty) {
            return value.first.toString();
          }
        }
      }
    } catch (_) {}

    return fallback;
  }
}