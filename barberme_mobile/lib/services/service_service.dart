import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/config/api_config.dart';
import '../models/paged_response.dart';
import '../models/service.dart';

class ServiceService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<PagedResponse<Service>> getServices({
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
      '${ApiConfig.baseUrl}/api/Services',
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

      return PagedResponse<Service>.fromJson(
        data,
        Service.fromJson,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load services.',
      ),
    );
  }

  Future<Service> getServiceById(
    int serviceId,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Services/$serviceId',
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

      return Service.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load service.',
      ),
    );
  }

  Future<Service> createService({
    required String name,
    String? description,
    required double price,
    required int durationMinutes,
    String? imagePath,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Services',
      ),
    );

    request.headers['Authorization'] =
        'Bearer $token';

    request.fields['Name'] = name.trim();

    request.fields['Description'] =
        description?.trim() ?? '';

    request.fields['Price'] =
        price.toString();

    request.fields['DurationMinutes'] =
        durationMinutes.toString();

    request.fields['IsActive'] = 'true';

    if (imagePath != null &&
        imagePath.trim().isNotEmpty) {
      request.files.add(
        await _createImageFile(
          imagePath,
          fieldName: 'Image',
        ),
      );
    }

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return Service.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to create service.',
      ),
    );
  }

  Future<Service> updateService({
    required int serviceId,
    required String name,
    String? description,
    required double price,
    required int durationMinutes,
    required bool isActive,
    String? imagePath,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Services/$serviceId',
      ),
    );

    request.headers['Authorization'] =
        'Bearer $token';

    request.fields['Name'] = name.trim();

    request.fields['Description'] =
        description?.trim() ?? '';

    request.fields['Price'] =
        price.toString();

    request.fields['DurationMinutes'] =
        durationMinutes.toString();

    request.fields['IsActive'] =
        isActive.toString();

    if (imagePath != null &&
        imagePath.trim().isNotEmpty) {
      request.files.add(
        await _createImageFile(
          imagePath,
          fieldName: 'Image',
        ),
      );
    }

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return Service.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to update service.',
      ),
    );
  }

  Future<void> deleteService(
    int serviceId,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Services/$serviceId',
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
        'Failed to deactivate service.',
      ),
    );
  }

  Future<void> activateService(
    int serviceId,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Services/$serviceId/activate',
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
        'Failed to activate service.',
      ),
    );
  }

  Future<void> deactivateService(
    int serviceId,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Services/$serviceId/deactivate',
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
        'Failed to deactivate service.',
      ),
    );
  }

  Future<http.MultipartFile> _createImageFile(
    String filePath, {
    required String fieldName,
  }) async {
    final extension =
        filePath.split('.').last.toLowerCase();

    late final MediaType contentType;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        contentType = MediaType(
          'image',
          'jpeg',
        );
        break;

      case 'png':
        contentType = MediaType(
          'image',
          'png',
        );
        break;

      case 'webp':
        contentType = MediaType(
          'image',
          'webp',
        );
        break;

      default:
        throw Exception(
          'Only JPG, PNG and WEBP images are allowed.',
        );
    }

    return http.MultipartFile.fromPath(
      fieldName,
      filePath,
      contentType: contentType,
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