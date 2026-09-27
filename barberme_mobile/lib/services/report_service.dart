import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/report.dart';

class ReportService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<Report> getReport({
    required DateTime dateFrom,
    required DateTime dateTo,
    int? barberId,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Reports',
    ).replace(
      queryParameters: _buildQueryParameters(
        dateFrom: dateFrom,
        dateTo: dateTo,
        barberId: barberId,
      ),
    );

    final response = await http.get(
      uri,
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return Report.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load report.',
      ),
    );
  }

  Future<BarberPerformanceReport>
      getBarberPerformanceReport({
    required DateTime dateFrom,
    required DateTime dateTo,
    int? barberId,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );
    
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Reports/barber-performance',
    ).replace(
      queryParameters: _buildQueryParameters(
        dateFrom: dateFrom,
        dateTo: dateTo,
        barberId: barberId,
      ),
    );

    final response = await http.get(
      uri,
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return BarberPerformanceReport.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load barber performance report.',
      ),
    );
  }

  Future<Uint8List> downloadReportPdf({
    required DateTime dateFrom,
    required DateTime dateTo,
    int? barberId,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Reports/pdf',
    ).replace(
      queryParameters: _buildQueryParameters(
        dateFrom: dateFrom,
        dateTo: dateTo,
        barberId: barberId,
      ),
    );

    final response = await http.get(
      uri,
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to download report PDF.',
      ),
    );
  }

  Future<Uint8List> downloadBarberPerformancePdf({
    required DateTime dateFrom,
    required DateTime dateTo,
    int? barberId,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Reports/barber-performance/pdf',
    ).replace(
      queryParameters: _buildQueryParameters(
        dateFrom: dateFrom,
        dateTo: dateTo,
        barberId: barberId,
      ),
    );

    final response = await http.get(
      uri,
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to download barber performance PDF.',
      ),
    );
  }

  Map<String, String> _buildQueryParameters({
    required DateTime dateFrom,
    required DateTime dateTo,
    int? barberId,
  }) {
    final parameters = <String, String>{
      'DateFrom': _formatDate(dateFrom),
      'DateTo': _formatDate(dateTo),
    };

    if (barberId != null) {
      parameters['BarberId'] = barberId.toString();
    }

    return parameters;
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _getErrorMessage(
    String body,
    String fallback,
  ) {
    if (body.trim().isEmpty) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];

        if (message is String &&
            message.trim().isNotEmpty) {
          return message;
        }

        final title = decoded['title'];

        if (title is String &&
            title.trim().isNotEmpty) {
          return title;
        }

        final errors = decoded['errors'];

        if (errors is Map) {
          final messages = <String>[];

          for (final value in errors.values) {
            if (value is List) {
              messages.addAll(
                value.map((e) => e.toString()),
              );
            }
          }

          if (messages.isNotEmpty) {
            return messages.join('\n');
          }
        }
      }

      if (decoded is String &&
          decoded.trim().isNotEmpty) {
        return decoded;
      }
    } catch (_) {
      // Response is not JSON.
    }

    return fallback;
  }
}