import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/config/api_config.dart';
import '../models/news.dart';
import '../models/paged_response.dart';

class NewsService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<PagedResponse<News>> getNews({
    String? fts,
    bool? isActive,
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

    if (isActive != null) {
      queryParameters['isActive'] =
          isActive.toString();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/News',
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

      return PagedResponse<News>.fromJson(
        data,
        News.fromJson,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load news.',
      ),
    );
  }

  Future<News> createNews({
    required String title,
    required String content,
    required String imagePath,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConfig.baseUrl}/api/News',
      ),
    );

    request.headers['Authorization'] =
        'Bearer $token';

    request.fields['Title'] = title.trim();
    request.fields['Content'] = content.trim();

    request.files.add(
      await http.MultipartFile.fromPath(
        'Image',
        imagePath,
        contentType: _getImageContentType(
          imagePath,
        ),
      ),
    );

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return News.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to create news.',
      ),
    );
  }

  Future<News> updateNews({
    required int newsId,
    required String title,
    required String content,
    required bool isActive,
    String? imagePath,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse(
        '${ApiConfig.baseUrl}/api/News/$newsId',
      ),
    );

    request.headers['Authorization'] =
        'Bearer $token';

    request.fields['Title'] = title.trim();
    request.fields['Content'] = content.trim();
    request.fields['IsActive'] =
        isActive.toString();

    if (imagePath != null &&
        imagePath.trim().isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'Image',
          imagePath,
          contentType: _getImageContentType(
            imagePath,
          ),
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
      return News.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to update news.',
      ),
    );
  }

  Future<void> activateNews(int newsId) async {
    await _putAction(
      newsId: newsId,
      action: 'activate',
      fallback: 'Failed to activate news.',
    );
  }

  Future<void> deactivateNews(int newsId) async {
    await _putAction(
      newsId: newsId,
      action: 'deactivate',
      fallback: 'Failed to deactivate news.',
    );
  }

  Future<void> deleteNews(int newsId) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/News/$newsId',
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
        'Failed to delete news.',
      ),
    );
  }

  Future<void> _putAction({
    required int newsId,
    required String action,
    required String fallback,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/News/$newsId/$action',
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

  MediaType _getImageContentType(
    String filePath,
  ) {
    final extension =
        filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');

      case 'png':
        return MediaType('image', 'png');

      case 'webp':
        return MediaType('image', 'webp');

      default:
        throw Exception(
          'Only JPG, PNG and WEBP images are allowed.',
        );
    }
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

      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;

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