import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/login_response.dart';

import '../core/config/api_config.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/Users/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final Map<String, dynamic> responseBody =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final loginResponse = LoginResponse.fromJson(responseBody);

      await _storage.write(
        key: 'jwt_token',
        value: loginResponse.token,
      );

      return loginResponse;
    }

    final message =
        responseBody['message']?.toString() ?? 'Login failed.';

    throw Exception(message);
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    if (token != null && token.isNotEmpty) {
      try {
        await http.post(
          Uri.parse(
            '${ApiConfig.baseUrl}/api/Users/logout',
          ),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {
        // Local logout should still continue
        // even if the API is temporarily unavailable.
      }
    }

    await _storage.delete(
      key: 'jwt_token',
    );
  }
}