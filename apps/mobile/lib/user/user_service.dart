import 'dart:convert';
import 'dart:io';

import 'user_model.dart';
import 'user_role.dart';
import 'user_session.dart';
import 'user_status.dart';

class UserServiceException implements Exception {
  const UserServiceException({
    required this.statusCode,
    required this.message,
    this.responseBody,
  });

  final int statusCode;
  final String message;
  final Object? responseBody;

  @override
  String toString() {
    return 'UserServiceException($statusCode): $message';
  }
}

class CreateUserRequest {
  const CreateUserRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
    this.id,
    this.phoneNumber,
    this.status = UserStatus.pending,
    this.facilityId,
    this.organizationId,
    this.patientId,
  });

  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final UserRole role;
  final UserStatus status;
  final String? phoneNumber;
  final String? facilityId;
  final String? organizationId;
  final String? patientId;

  Map<String, dynamic> toJson() {
    return _withoutNullValues({
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'role': role.value,
      'status': status.value,
      'phone_number': phoneNumber,
      'facility_id': facilityId,
      'organization_id': organizationId,
      'patient_id': patientId,
    });
  }
}

class UpdateUserRequest {
  const UpdateUserRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.role,
    this.status,
    this.phoneNumber,
    this.facilityId,
    this.organizationId,
    this.patientId,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final UserRole? role;
  final UserStatus? status;
  final String? phoneNumber;
  final String? facilityId;
  final String? organizationId;
  final String? patientId;

  Map<String, dynamic> toJson() {
    return _withoutNullValues({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'role': role?.value,
      'status': status?.value,
      'phone_number': phoneNumber,
      'facility_id': facilityId,
      'organization_id': organizationId,
      'patient_id': patientId,
    });
  }
}

class UserService {
  UserService({required Uri baseUrl, HttpClient? httpClient})
    : _baseUrl = baseUrl,
      _httpClient = httpClient ?? HttpClient();

  final Uri _baseUrl;
  final HttpClient _httpClient;

  Future<UserSession> login({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    final response = await _sendJson(
      method: 'POST',
      path: '/auth/login',
      body: _withoutNullValues({
        'email': email,
        'password': password,
        'device_id': deviceId,
      }),
    );

    return UserSession.fromJson(response);
  }

  Future<UserSession> refreshSession({
    required String refreshToken,
    String? deviceId,
  }) async {
    final response = await _sendJson(
      method: 'POST',
      path: '/auth/refresh',
      body: _withoutNullValues({
        'refresh_token': refreshToken,
        'device_id': deviceId,
      }),
    );

    return UserSession.fromJson(response);
  }

  Future<void> logout({required String refreshToken}) async {
    await _sendJson(
      method: 'POST',
      path: '/auth/logout',
      body: {'refresh_token': refreshToken},
    );
  }

  Future<UserModel> currentUser({required String accessToken}) async {
    final response = await _sendJson(
      method: 'GET',
      path: '/auth/me',
      accessToken: accessToken,
    );

    return _readUser(response);
  }

  Future<List<UserModel>> fetchUsers({required String accessToken}) async {
    final response = await _sendJson(
      method: 'GET',
      path: '/users',
      accessToken: accessToken,
    );
    final users = response['users'];

    if (users is! List) {
      throw UserServiceException(
        statusCode: HttpStatus.ok,
        message: 'Invalid users response',
        responseBody: response,
      );
    }

    return users
        .cast<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList(growable: false);
  }

  Future<UserModel> fetchUser({
    required String userId,
    required String accessToken,
  }) async {
    final response = await _sendJson(
      method: 'GET',
      path: '/users/$userId',
      accessToken: accessToken,
    );

    return _readUser(response);
  }

  Future<UserModel> createUser({
    required CreateUserRequest request,
    required String accessToken,
  }) async {
    final response = await _sendJson(
      method: 'POST',
      path: '/users',
      accessToken: accessToken,
      body: request.toJson(),
    );

    return _readUser(response);
  }

  Future<UserModel> updateUser({
    required String userId,
    required UpdateUserRequest request,
    required String accessToken,
  }) async {
    final response = await _sendJson(
      method: 'PUT',
      path: '/users/$userId',
      accessToken: accessToken,
      body: request.toJson(),
    );

    return _readUser(response);
  }

  Future<void> deleteUser({
    required String userId,
    required String accessToken,
  }) async {
    await _sendJson(
      method: 'DELETE',
      path: '/users/$userId',
      accessToken: accessToken,
    );
  }

  void close() {
    _httpClient.close(force: true);
  }

  Future<Map<String, dynamic>> _sendJson({
    required String method,
    required String path,
    String? accessToken,
    Map<String, dynamic>? body,
  }) async {
    final request = await _httpClient.openUrl(method, _resolve(path));
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);

    if (accessToken != null && accessToken.trim().isNotEmpty) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }

    if (body != null) {
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final responseText = await utf8.decoder.bind(response).join();
    final decodedBody = _decodeResponseBody(responseText);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UserServiceException(
        statusCode: response.statusCode,
        message: _readErrorMessage(decodedBody, response.reasonPhrase),
        responseBody: decodedBody,
      );
    }

    if (decodedBody == null) {
      return <String, dynamic>{};
    }

    if (decodedBody is! Map<String, dynamic>) {
      throw UserServiceException(
        statusCode: response.statusCode,
        message: 'Expected a JSON object response',
        responseBody: decodedBody,
      );
    }

    return decodedBody;
  }

  Uri _resolve(String path) {
    final normalizedBasePath =
        _baseUrl.path.endsWith('/')
            ? _baseUrl.path.substring(0, _baseUrl.path.length - 1)
            : _baseUrl.path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return _baseUrl.replace(path: '$normalizedBasePath$normalizedPath');
  }

  static Object? _decodeResponseBody(String responseText) {
    if (responseText.trim().isEmpty) {
      return null;
    }

    return jsonDecode(responseText);
  }

  static String _readErrorMessage(Object? responseBody, String reasonPhrase) {
    if (responseBody is Map<String, dynamic>) {
      final message = responseBody['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    return reasonPhrase;
  }

  static UserModel _readUser(Map<String, dynamic> response) {
    final user = response['user'];

    if (user is! Map<String, dynamic>) {
      throw UserServiceException(
        statusCode: HttpStatus.ok,
        message: 'Invalid user response',
        responseBody: response,
      );
    }

    return UserModel.fromJson(user);
  }
}

Map<String, dynamic> _withoutNullValues(Map<String, dynamic> values) {
  return Map<String, dynamic>.fromEntries(
    values.entries.where((entry) => entry.value != null),
  );
}
