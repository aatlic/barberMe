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

    String message =
        'Failed to load working hours.';

    try {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      if (data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }
}