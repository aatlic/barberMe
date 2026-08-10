import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (Platform.isAndroid) {
      return dotenv.env['API_BASE_URL_ANDROID'] ??
          'http://10.0.2.2:5011';
    }

    if (Platform.isWindows) {
      return dotenv.env['API_BASE_URL_WINDOWS'] ??
          'http://localhost:5011';
    }

    throw UnsupportedError('Unsupported platform.');
  }
}