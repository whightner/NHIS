import 'dart:io';

import 'auth/auth_api.dart';
import 'auth/user_session_database_table.dart';
import 'http/json_http.dart';
import 'users/user_database_table.dart';

final class NhisApiApp {
  NhisApiApp({AuthApi? authApi}) : _authApi = authApi ?? AuthApi();

  final AuthApi _authApi;

  Future<void> initialize() async {
    await UserDatabaseTable.createTable();
    await UserSessionDatabaseTable.createTable();
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
