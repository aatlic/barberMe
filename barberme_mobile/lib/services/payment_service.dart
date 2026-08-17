import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/payment.dart';

class PaymentService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<Payment> createPayment(
    int appointmentId,
  ) async {
    final token =
        await _storage.read(key: 'jwt_token');

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Payments/appointments/$appointmentId',
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

      return Payment.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to create payment.',
      ),
    );
  }

  Future<bool> confirmPayment(
    int paymentId,
  ) async {
    final token =
        await _storage.read(key: 'jwt_token');

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Payments/$paymentId/confirm',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body) as bool;
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to confirm payment.',
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
    } catch (_) {}

    return fallback;
  }
}