import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/barber_service.dart';
import '../models/paged_response.dart';

class BarberServiceService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<List<BarberService>> getForBooking(
    int barberId,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/BarberServices/booking',
    ).replace(
      queryParameters: {
        'barberId': barberId.toString(),
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
            (item) => BarberService.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load services.',
      ),
    );
  }

  Future<PagedResponse<BarberService>>
      getBarberServices({
    required int barberId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/BarberServices',
    ).replace(
      queryParameters: {
        'barberId': barberId.toString(),
        'page': page.toString(),
        'pageSize': pageSize.toString(),
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
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return PagedResponse<BarberService>.fromJson(
        data,
        BarberService.fromJson,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load barber services.',
      ),
    );
  }

  Future<BarberService> createBarberService({
    required int barberId,
    required int serviceId,
    required double price,
    required int durationMinutes,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/BarberServices',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'barberId': barberId,
        'serviceId': serviceId,
        'price': price,
        'durationMinutes': durationMinutes,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return BarberService.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to assign service.',
      ),
    );
  }

  Future<BarberService> updateBarberService({
    required int id,
    required double price,
    required int durationMinutes,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/BarberServices/$id',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'price': price,
        'durationMinutes': durationMinutes,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return BarberService.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to update barber service.',
      ),
    );
  }

  Future<void> deleteBarberService(
    int id,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/BarberServices/$id',
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
        'Failed to remove barber service.',
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