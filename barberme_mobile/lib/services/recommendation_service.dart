import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/recommendation.dart';
import '../models/recommendation_feedback.dart';

class RecommendationService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<List<Recommendation>>
      getRecommendations() async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Recommendation',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as List<dynamic>;

      return data
          .map(
            (item) => Recommendation.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load recommendations.',
      ),
    );
  }

  Future<void> setAcceptance({
    required int recommendationId,
    required bool wasAccepted,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Recommendation/'
        '$recommendationId/acceptance',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        wasAccepted,
      ),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to update recommendation.',
      ),
    );
  }

  Future<RecommendationFeedback> addFeedback({
    required int recommendationId,
    required int rating,
    String? comment,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Recommendation/'
        '$recommendationId/feedback',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'rating': rating,
        'comment':
            comment?.trim().isEmpty == true
                ? null
                : comment?.trim(),
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return RecommendationFeedback.fromJson(
        data,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to submit recommendation feedback.',
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
    } catch (_) {}

    return fallback;
  }
}