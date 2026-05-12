import 'dart:io';

import 'auth/auth_api.dart';
import 'auth/user_session_database_table.dart';
import 'dev/dev_user_seed.dart';
import 'http/json_http.dart';
import 'users/user_database_table.dart';
import 'users/users_api.dart';

final class NhisApiApp {
  NhisApiApp({AuthApi? authApi, UsersApi? usersApi})
    : _authApi = authApi ?? AuthApi(),
      _usersApi = usersApi ?? UsersApi();

  final AuthApi _authApi;
  final UsersApi _usersApi;

  Future<void> initialize() async {
    await UserDatabaseTable.createTable();
    await UserSessionDatabaseTable.createTable();
    await const DevUserSeed().run();
  }

  Future<void> handle(HttpRequest request) async {
    setCorsHeaders(request.response);

    if (request.method == 'OPTIONS') {
      await writeNoContent(request.response);
      return;
    }

    try {
      if (request.method == 'GET' && request.uri.path == '/health') {
        await writeJson(
          request.response,
          statusCode: HttpStatus.ok,
          body: {'status': 'ok'},
        );
        return;
      }

      final handledByAuth = await _authApi.handle(request);

      if (handledByAuth) {
        return;
      }

      final handledByUsers = await _usersApi.handle(request);

      if (handledByUsers) {
        return;
      }

      await writeJson(
        request.response,
        statusCode: HttpStatus.notFound,
        body: {'message': 'Route not found'},
      );
    } catch (_) {
      if (request.response.headers.contentType == null) {
        await writeJson(
          request.response,
          statusCode: HttpStatus.internalServerError,
          body: {'message': 'Internal server error'},
        );
      }
    }
  }
}
