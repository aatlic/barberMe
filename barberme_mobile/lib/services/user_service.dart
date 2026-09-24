import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/config/api_config.dart';
import '../models/user.dart';
import '../models/paged_response.dart';

class UserService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<List<User>> getBarbers() async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

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
      final data =
          jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (item) => User.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load barbers.',
      ),
    );
  }

  Future<User> getCurrentUser() async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/me',
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

      return User.fromJson(data);
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load profile.',
      ),
    );
  }

  Future<User> updateCurrentUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required bool receiveNewsletter,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/me',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'receiveNewsletter': receiveNewsletter,
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
        'Failed to update profile.',
      ),
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/me/change-password',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to change password.',
      ),
    );
  }

  Future<String> uploadProfileImage({
    required String filePath,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/me/profile-image',
      ),
    );

    request.headers['Authorization'] =
        'Bearer $token';

    final extension = filePath
        .split('.')
        .last
        .toLowerCase();

    late final MediaType contentType;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        contentType = MediaType(
          'image',
          'jpeg',
        );
        break;

      case 'png':
        contentType = MediaType(
          'image',
          'png',
        );
        break;

      case 'webp':
        contentType = MediaType(
          'image',
          'webp',
        );
        break;

      default:
        throw Exception(
          'Only JPG, PNG and WEBP images are allowed.',
        );
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'File',
        filePath,
        contentType: contentType,
      ),
    );

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final body = response.body.trim();

      if (body.startsWith('"') &&
          body.endsWith('"')) {
        try {
          return jsonDecode(body) as String;
        } catch (_) {}
      }

      return body;
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to upload profile image.',
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

      if (data['errors'] is List &&
          (data['errors'] as List).isNotEmpty) {
        return (data['errors'] as List)
            .first
            .toString();
      }
    } catch (_) {}

    return fallback;
  }

  Future<PagedResponse<User>> getClients({
    String? fts,
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final queryParameters = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (fts != null && fts.trim().isNotEmpty) {
      queryParameters['fts'] = fts.trim();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Users/clients',
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

      return PagedResponse<User>.fromJson(
        data,
        User.fromJson,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load clients.',
      ),
    );
  }

  Future<PagedResponse<User>> getUsers({
    String? fts,
    int? roleId,
    bool? isActive,
    int? barberLevelId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final queryParameters = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (fts != null && fts.trim().isNotEmpty) {
      queryParameters['fts'] = fts.trim();
    }

    if (roleId != null) {
      queryParameters['roleId'] = roleId.toString();
    }

    if (isActive != null) {
      queryParameters['isActive'] = isActive.toString();
    }

    if (barberLevelId != null) {
      queryParameters['barberLevelId'] =
          barberLevelId.toString();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/Users',
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

      return PagedResponse<User>.fromJson(
        data,
        User.fromJson,
      );
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to load users.',
      ),
    );
  }

  Future<void> lockUser(int userId) async {
    await _putUserAction(
      userId: userId,
      action: 'lock',
      fallback: 'Failed to lock user.',
    );
  }

  Future<void> unlockUser(int userId) async {
    await _putUserAction(
      userId: userId,
      action: 'unlock',
      fallback: 'Failed to unlock user.',
    );
  }

  Future<void> activateUser(int userId) async {
    await _putUserAction(
      userId: userId,
      action: 'activate',
      fallback: 'Failed to activate user.',
    );
  }

  Future<void> deactivateUser(int userId) async {
    await _putUserAction(
      userId: userId,
      action: 'deactivate',
      fallback: 'Failed to deactivate user.',
    );
  }

  Future<String> generatePassword() async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/generate-password',
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

      return data['password'].toString();
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        'Failed to generate password.',
      ),
    );
  }

  Future<User> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required int roleId,
    int? barberLevelId,
    bool requirePasswordChange = true,
    bool receiveNewsletter = false,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'username': username.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'password': password,
        'roleId': roleId,
        'barberLevelId': barberLevelId,
        'requirePasswordChange':
            requirePasswordChange,
        'receiveNewsletter':
            receiveNewsletter,
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
        'Failed to create user.',
      ),
    );
  }

  Future<User> updateUser({
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    int? barberLevelId,
    required bool isActive,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/$userId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'barberLevelId': barberLevelId,
        'isActive': isActive,
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
        'Failed to update user.',
      ),
    );
  }

  Future<void> deleteUser(int userId) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/$userId',
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
        'Failed to delete user.',
      ),
    );
  }

  Future<User> copyEmployee({
    required int sourceEmployeeId,
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required bool requirePasswordChange,
    required bool copyServices,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/$sourceEmployeeId/copy',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'username': username.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'password': password,
        'requirePasswordChange':
            requirePasswordChange,
        'copyServices': copyServices,
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
        'Failed to copy employee.',
      ),
    );
  }

  Future<void> _putUserAction({
    required int userId,
    required String action,
    required String fallback,
  }) async {
    final token = await _storage.read(
      key: 'jwt_token',
    );

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/Users/$userId/$action',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      _getErrorMessage(
        response.body,
        fallback,
      ),
    );
  }
}