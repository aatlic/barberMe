import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/paged_response.dart';
import '../models/support_request.dart';

class SupportRequestService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<PagedResponse<SupportRequest>> getSupportRequests({
    String? fts,
    int? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final token = await _storage.read(key: 'jwt_token');

    final queryParameters = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    if (fts != null && fts.trim().isNotEmpty) {
      queryParameters['FTS'] = fts.trim();
    }

    if (status != null) {
      queryParameters['Status'] = status.toString();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/SupportRequests',
    ).replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return PagedResponse<SupportRequest>.fromJson(
        json,
        (item) => SupportRequest.fromJson(
          item as Map<String, dynamic>,
        ),
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load support requests.',
      ),
    );
  }

  Future<SupportRequest> getSupportRequestById(int id) async {
    final token = await _storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/SupportRequests/$id',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return SupportRequest.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load support request.',
      ),
    );
  }

  Future<void> setInProgress(int id) async {
    await _putAction(
      id: id,
      action: 'in-progress',
      fallback: 'Failed to mark support request as in progress.',
    );
  }

  Future<void> resolve(int id) async {
    await _putAction(
      id: id,
      action: 'resolve',
      fallback: 'Failed to resolve support request.',
    );
  }

  Future<void> _putAction({
    required int id,
    required String action,
    required String fallback,
  }) async {
    final token = await _storage.read(key: 'jwt_token');

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/SupportRequests/$id/$action',
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
        fallback,
      ),
    );
  }

  String _getErrorMessage(
    String body,
    String fallback,
  ) {
    if (body.trim().isEmpty) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] != null) {
          return decoded['message'].toString();
        }

        if (decoded['title'] != null) {
          return decoded['title'].toString();
        }

        if (decoded['errors'] is Map) {
          final errors = decoded['errors'] as Map;

          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
          }
        }
      }

      if (decoded is String && decoded.isNotEmpty) {
        return decoded;
      }
    } catch (_) {
      // Response is not JSON.
    }

    return fallback;
  }
}