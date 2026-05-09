import 'dart:convert';
import 'dart:io';

final class ApiRequestException implements Exception {
  const ApiRequestException(this.statusCode, this.message);

  final int statusCode;
  final String message;
}

Future<Map<String, dynamic>> readJsonObject(HttpRequest request) async {
  final body = await utf8.decoder.bind(request).join();

  if (body.trim().isEmpty) {
    return <String, dynamic>{};
  }

  final Object? decoded;

  try {
    decoded = jsonDecode(body);
  } on FormatException {
    throw const ApiRequestException(
      HttpStatus.badRequest,
      'Invalid JSON request body',
    );
  }

  if (decoded is! Map<String, dynamic>) {
    throw const ApiRequestException(
      HttpStatus.badRequest,
      'Expected a JSON object request body',
    );
  }

  return decoded;
}

String readRequiredString(Map<String, dynamic> body, String key) {
  final value = body[key];

  if (value is! String || value.trim().isEmpty) {
    throw ApiRequestException(
      HttpStatus.badRequest,
      'Missing required field: $key',
    );
  }

  return value;
}

String? readOptionalString(Map<String, dynamic> body, String key) {
  final value = body[key];

  if (value == null) {
    return null;
  }

  if (value is! String) {
    throw ApiRequestException(
      HttpStatus.badRequest,
      'Expected field to be a string: $key',
    );
  }

  if (value.trim().isEmpty) {
    return null;
  }

  return value;
}

String readBearerToken(HttpRequest request) {
  final authorization = request.headers.value(HttpHeaders.authorizationHeader);

  if (authorization == null) {
    throw const ApiRequestException(
      HttpStatus.unauthorized,
      'Missing authorization header',
    );
  }

  final parts = authorization.split(' ');

  if (parts.length != 2 || parts.first.toLowerCase() != 'bearer') {
    throw const ApiRequestException(
      HttpStatus.unauthorized,
      'Expected Bearer authorization header',
    );
  }

  if (parts.last.trim().isEmpty) {
    throw const ApiRequestException(
      HttpStatus.unauthorized,
      'Missing bearer token',
    );
  }

  return parts.last;
}

Future<void> writeJson(
  HttpResponse response, {
  required int statusCode,
  required Object? body,
}) async {
  response.statusCode = statusCode;
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(body));
  await response.close();
}

Future<void> writeNoContent(HttpResponse response) async {
  response.statusCode = HttpStatus.noContent;
  await response.close();
}

void setCorsHeaders(HttpResponse response) {
  response.headers
    ..set(HttpHeaders.accessControlAllowOriginHeader, '*')
    ..set(
      HttpHeaders.accessControlAllowHeadersHeader,
      '${HttpHeaders.authorizationHeader}, ${HttpHeaders.contentTypeHeader}',
    )
    ..set(
      HttpHeaders.accessControlAllowMethodsHeader,
      'GET, POST, PUT, DELETE, OPTIONS',
    );
}
