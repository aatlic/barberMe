import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';

class SupportService {
  Future<void> createSupportRequest({
    required String fullName,
    required String email,
    required String subject,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/SupportRequests',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullName': fullName.trim(),
        'email': email.trim(),
        'subject': subject.trim(),
        'message': message.trim(),
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to send support request.',
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

      if (data['errors'] != null) {
        final errors = data['errors'];

        if (errors is Map<String, dynamic>) {
          final messages = <String>[];

          for (final value in errors.values) {
            if (value is List) {
              messages.addAll(
                value.map(
                  (item) => item.toString(),
                ),
              );
            }
          }

          if (messages.isNotEmpty) {
            return messages.first;
          }
        }
      }
    } catch (_) {}

    return fallback;
  }
}