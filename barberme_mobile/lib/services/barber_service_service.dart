import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/barber_service.dart';

class BarberServiceService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<List<BarberService>> getForBooking(int barberId) async {
    final token = await _storage.read(key: 'jwt_token');

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/BarberServices/booking',
    ).replace(
      queryParameters: {
        'barberId': barberId.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (item) => BarberService.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception('Failed to load services.');
  }
}