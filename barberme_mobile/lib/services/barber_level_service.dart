import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/barber_level.dart';
import '../models/paged_response.dart';

class BarberLevelService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<PagedResponse<BarberLevel>> getBarberLevels({
    String? fts,
    int page = 1,
    int pageSize = 10,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final queryParameters = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (fts != null && fts.trim().isNotEmpty) {
      queryParameters['fts'] = fts.trim();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/BarberLevels',
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
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return PagedResponse<BarberLevel>.fromJson(
        data,
        BarberLevel.fromJson,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load barber levels.',
      ),
    );
  }

  Future<BarberLevel> getBarberLevelById(
    int id,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/BarberLevels/$id',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return BarberLevel.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load barber level.',
      ),
    );
  }

  Future<BarberLevel> createBarberLevel({
    required String name,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/BarberLevels',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name.trim(),
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return BarberLevel.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to create barber level.',
      ),
    );
  }

  Future<BarberLevel> updateBarberLevel({
    required int id,
    required String name,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/BarberLevels/$id',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name.trim(),
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return BarberLevel.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to update barber level.',
      ),
    );
  }

  Future<void> activateBarberLevel(
    int id,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/BarberLevels/$id/activate',
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
        'Failed to activate barber level.',
      ),
    );
  }

  Future<void> deactivateBarberLevel(
    int id,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/BarberLevels/$id/deactivate',
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
        'Failed to deactivate barber level.',
      ),
    );
  }

  Future<void> deleteBarberLevel(
    int id,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/BarberLevels/$id',
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
        'Failed to delete barber level.',
      ),
    );
  }

  String _getErrorMessage(
    String body,
    String fallback,
  ) {
    try {
      final data =
          jsonDecode(body)
              as Map<String, dynamic>;

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