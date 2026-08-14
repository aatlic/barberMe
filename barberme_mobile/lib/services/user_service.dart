import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/user.dart';

class UserService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<List<User>> getBarbers() async {
    final token = await _storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/barbers',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (item) => User.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception('Failed to load barbers.');
  }
}