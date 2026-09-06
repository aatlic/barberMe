import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/login_response.dart';
import '../models/user.dart';
import '../core/config/api_config.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<User> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/register',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'username': username.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return User.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Registration failed.',
      ),
    );
  }

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

  Future<String> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/forgot-password',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return data['message']?.toString() ??
          'If an account with that email exists, instructions have been sent.';
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to reset password.',
      ),
    );
  }
}