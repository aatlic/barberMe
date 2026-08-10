import 'dart:convert';
import '../core/config/api_config.dart';
import 'package:http/http.dart' as http;

import '../models/shop_settings.dart';
import '../models/shop_working_hours.dart';

class ShopService {
  Future<ShopSettings> getShopSettings() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/ShopSettings'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return ShopSettings.fromJson(data);
    }

    throw Exception('Failed to load shop information.');
  }

  Future<List<ShopWorkingHours>> getWorkingHours() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/ShopWorkingHours'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data =
          jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (item) => ShopWorkingHours.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception('Failed to load shop working hours.');
  }
}