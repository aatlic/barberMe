import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';

class ReviewService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<void> createReview({
    required int appointmentId,
    required int rating,
    String? comment,
  }) async {
    final token = await _storage.read(key: 'jwt_token');

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Reviews',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'appointmentId': appointmentId,
        'rating': rating,
        'comment': comment?.trim().isEmpty == true
            ? null
            : comment?.trim(),
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message = 'Failed to submit review.';

    try {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }
}