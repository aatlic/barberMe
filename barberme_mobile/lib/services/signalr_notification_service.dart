import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../core/config/api_config.dart';

class SignalRNotificationService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  HubConnection? _connection;

  Future<void> connect({
    required void Function(Map<String, dynamic> data)
        onNotificationReceived,
  }) async {
    if (_connection != null &&
        _connection!.state ==
            HubConnectionState.Connected) {
      return;
    }

    final token =
        await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      return;
    }

    final hubUrl =
        '${ApiConfig.baseUrl}/hubs/notifications';

    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on(
      'ReceiveNotification',
      (arguments) {
        if (arguments == null ||
            arguments.isEmpty) {
          return;
        }

        final raw = arguments.first;

        if (raw is Map<String, dynamic>) {
          onNotificationReceived(raw);
          return;
        }

        if (raw is Map) {
          onNotificationReceived(
            Map<String, dynamic>.from(raw),
          );
        }
      },
    );

    await _connection!.start();
  }

  Future<void> disconnect() async {
    if (_connection == null) {
      return;
    }

    await _connection!.stop();
    _connection = null;
  }
}