import 'dart:convert';
import '../core/config/api_config.dart';
import 'package:http/http.dart' as http;

import '../models/shop_settings.dart';
import '../models/shop_working_hours.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ShopService {
  final FlutterSecureStorage _storage =
    const FlutterSecureStorage();

  Future<ShopSettings> getShopSettings() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/ShopSettings'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return ShopSettings.fromJson(data);
    }

    throw Exception('Failed to load shop information.');
  }

  Future<List<ShopWorkingHours>> getWorkingHours() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/ShopWorkingHours'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data =
          jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (item) => ShopWorkingHours.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception('Failed to load shop working hours.');
  }

  Future<ShopSettings> updateShopSettings({
    required String name,
    required String address,
    required String phoneNumber,
    required String email,
    String? description,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/ShopSettings',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name.trim(),
        'address': address.trim(),
        'phoneNumber': phoneNumber.trim(),
        'email': email.trim(),
        'description':
            description?.trim().isEmpty == true
                ? null
                : description?.trim(),
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final Map<String, dynamic> data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return ShopSettings.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to update shop information.',
      ),
    );
  }

  Future<ShopWorkingHours> updateWorkingHours({
    required int id,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required bool isWorking,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/ShopWorkingHours/$id',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'isWorking': isWorking,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final Map<String, dynamic> data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return ShopWorkingHours.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to update shop working hours.',
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

      if (data['errors'] is Map<String, dynamic>) {
        final errors =
            data['errors'] as Map<String, dynamic>;

        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
        }
      }
    } catch (_) {}

    return fallback;
  }
}