import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/notification.dart';
import '../models/paged_response.dart';

class NotificationService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<PagedResponse<AppNotification>> getNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final queryParameters = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    if (isRead != null) {
      queryParameters['IsRead'] =
          isRead.toString();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Notifications',
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

      return PagedResponse<AppNotification>.fromJson(
        data,
        AppNotification.fromJson,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load notifications.',
      ),
    );
  }

  Future<void> markAsRead(
    int notificationId,
  ) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Notifications/$notificationId/read',
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
        'Failed to mark notification as read.',
      ),
    );
  }

  Future<int> getUnreadCount() async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Notifications/unread-count',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body) as int;
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load unread notification count.',
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
    } catch (_) {}

    return fallback;
  }
}