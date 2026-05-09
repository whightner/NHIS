import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../auth/auth_password_service.dart';
import '../auth/auth_service.dart';
import '../auth/auth_token_service.dart';
import '../http/json_http.dart';
import 'user_database_model.dart';
import 'user_database_table.dart';

final class UsersApi {
  UsersApi({AuthService? authService, AuthPasswordService? passwordService})
    : _authService = authService ?? AuthService(),
      _passwordService = passwordService ?? const AuthPasswordService();

  static const _readRoles = {
    'admin',
    'facility_admin',
    'registration_agent',
    'verifier',
    'auditor',
    'support_agent',
  };
  static const _writeRoles = {'admin', 'facility_admin', 'registration_agent'};
  static const _deleteRoles = {'admin'};

  final AuthService _authService;
  final AuthPasswordService _passwordService;

  Future<bool> handle(HttpRequest request) async {
    final path = _normalizedPath(request.uri.path);

    if (!path.startsWith('/users')) {
      return false;
    }

    try {
      final currentUser = await _authenticate(request);

      switch (request.method) {
        case 'GET':
          await _get(request, currentUser);
        case 'POST':
          await _create(request, currentUser);
        case 'PUT':
          await _update(request, currentUser);
        case 'DELETE':
          await _delete(request, currentUser);
        default:
          await writeJson(
            request.response,
            statusCode: HttpStatus.methodNotAllowed,
            body: {'message': 'Method not allowed'},
          );
      }
    } on ApiRequestException catch (error) {
      await writeJson(
        request.response,
        statusCode: error.statusCode,
        body: {'message': error.message},
      );
    } on AuthException catch (error) {
      await writeJson(
        request.response,
        statusCode: HttpStatus.unauthorized,
        body: {'message': error.message},
      );
    } on AuthTokenException catch (error) {
      await writeJson(
        request.response,
        statusCode: HttpStatus.unauthorized,
        body: {'message': error.message},
      );
    }

    return true;
  }

  Future<UserDatabaseModel> _authenticate(HttpRequest request) {
    return _authService.authenticateAccessToken(readBearerToken(request));
  }

  Future<void> _get(HttpRequest request, UserDatabaseModel currentUser) async {
    final id = _readUserIdFromPath(request.uri.path);

    if (id == null) {
      _ensureRole(currentUser, _readRoles);
      final users = await UserDatabaseTable.selectAll();

      await writeJson(
        request.response,
        statusCode: HttpStatus.ok,
        body: {'users': users.map(_userToJson).toList(growable: false)},
      );
      return;
    }

    if (currentUser.id != id) {
      _ensureRole(currentUser, _readRoles);
    }

    final user = await UserDatabaseTable.selectById(id);

    if (user == null) {
      throw const ApiRequestException(HttpStatus.notFound, 'User not found');
    }

    await writeJson(
      request.response,
      statusCode: HttpStatus.ok,
      body: {'user': _userToJson(user)},
    );
  }

  Future<void> _create(
    HttpRequest request,
    UserDatabaseModel currentUser,
  ) async {
    _ensureRole(currentUser, _writeRoles);

    final body = await readJsonObject(request);
    final now = DateTime.now().toUtc();
    final user = UserDatabaseModel(
      id: readOptionalString(body, 'id') ?? _createUserId(),
      firstName: readRequiredString(body, 'first_name'),
      lastName: readRequiredString(body, 'last_name'),
      email: readRequiredString(body, 'email'),
      phoneNumber: readOptionalString(body, 'phone_number'),
      passwordHash: _passwordService.hashPassword(
        readRequiredString(body, 'password'),
      ),
      role: readRequiredString(body, 'role'),
      status: readOptionalString(body, 'status') ?? 'pending',
      facilityId: readOptionalString(body, 'facility_id'),
      organizationId: readOptionalString(body, 'organization_id'),
      patientId: readOptionalString(body, 'patient_id'),
      createdAt: now,
      updatedAt: now,
    );

    await UserDatabaseTable.insert(user);

    await writeJson(
      request.response,
      statusCode: HttpStatus.created,
      body: {'user': _userToJson(user)},
    );
  }

  Future<void> _update(
    HttpRequest request,
    UserDatabaseModel currentUser,
  ) async {
    _ensureRole(currentUser, _writeRoles);

    final id = _readRequiredUserIdFromPath(request.uri.path);
    final existingUser = await UserDatabaseTable.selectById(id);

    if (existingUser == null) {
      throw const ApiRequestException(HttpStatus.notFound, 'User not found');
    }

    final body = await readJsonObject(request);
    final password = readOptionalString(body, 'password');
    final updatedUser = UserDatabaseModel(
      id: existingUser.id,
      firstName:
          readOptionalString(body, 'first_name') ?? existingUser.firstName,
      lastName: readOptionalString(body, 'last_name') ?? existingUser.lastName,
      email: readOptionalString(body, 'email') ?? existingUser.email,
      phoneNumber:
          readOptionalString(body, 'phone_number') ?? existingUser.phoneNumber,
      passwordHash:
          password == null
              ? existingUser.passwordHash
              : _passwordService.hashPassword(password),
      role: readOptionalString(body, 'role') ?? existingUser.role,
      status: readOptionalString(body, 'status') ?? existingUser.status,
      facilityId:
          readOptionalString(body, 'facility_id') ?? existingUser.facilityId,
      organizationId:
          readOptionalString(body, 'organization_id') ??
          existingUser.organizationId,
      patientId:
          readOptionalString(body, 'patient_id') ?? existingUser.patientId,
      createdAt: existingUser.createdAt,
      updatedAt: DateTime.now().toUtc(),
      lastLoginAt: existingUser.lastLoginAt,
    );

    await UserDatabaseTable.updateById(updatedUser);

    await writeJson(
      request.response,
      statusCode: HttpStatus.ok,
      body: {'user': _userToJson(updatedUser)},
    );
  }

  Future<void> _delete(
    HttpRequest request,
    UserDatabaseModel currentUser,
  ) async {
    _ensureRole(currentUser, _deleteRoles);

    final id = _readRequiredUserIdFromPath(request.uri.path);
    final deletedRows = await UserDatabaseTable.deleteById(id);

    if (deletedRows == 0) {
      throw const ApiRequestException(HttpStatus.notFound, 'User not found');
    }

    await writeJson(
      request.response,
      statusCode: HttpStatus.ok,
      body: {'message': 'User deleted'},
    );
  }

  static String? _readUserIdFromPath(String path) {
    final segments = Uri.parse(path).pathSegments;

    if (segments.length == 1 && segments.first == 'users') {
      return null;
    }

    if (segments.length == 2 && segments.first == 'users') {
      return segments.last;
    }

    throw const ApiRequestException(
      HttpStatus.notFound,
      'User route not found',
    );
  }

  static String _readRequiredUserIdFromPath(String path) {
    final userId = _readUserIdFromPath(path);

    if (userId == null) {
      throw const ApiRequestException(
        HttpStatus.badRequest,
        'Missing user id in path',
      );
    }

    return userId;
  }

  static void _ensureRole(
    UserDatabaseModel currentUser,
    Set<String> allowedRoles,
  ) {
    if (!allowedRoles.contains(currentUser.role)) {
      throw const ApiRequestException(
        HttpStatus.forbidden,
        'Insufficient permissions',
      );
    }
  }

  static Map<String, dynamic> _userToJson(UserDatabaseModel user) {
    return {
      'id': user.id,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'email': user.email,
      'phone_number': user.phoneNumber,
      'role': user.role,
      'status': user.status,
      'facility_id': user.facilityId,
      'organization_id': user.organizationId,
      'patient_id': user.patientId,
      'created_at': user.createdAt?.toIso8601String(),
      'updated_at': user.updatedAt?.toIso8601String(),
      'last_login_at': user.lastLoginAt?.toIso8601String(),
    };
  }

  static String _createUserId() {
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));

    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static String _normalizedPath(String path) {
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }

    return path;
  }
}
