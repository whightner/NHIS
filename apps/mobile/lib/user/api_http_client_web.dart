// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

final class ApiHttpResponse {
  const ApiHttpResponse({
    required this.statusCode,
    required this.reasonPhrase,
    required this.body,
  });

  final int statusCode;
  final String reasonPhrase;
  final String body;
}

final class ApiHttpClient {
  Future<ApiHttpResponse> sendJson({
    required String method,
    required Uri uri,
    String? accessToken,
    Map<String, dynamic>? body,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (accessToken != null && accessToken.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final request = await html.HttpRequest.request(
      uri.toString(),
      method: method,
      requestHeaders: headers,
      sendData: body == null ? null : jsonEncode(body),
    );

    return ApiHttpResponse(
      statusCode: request.status ?? 0,
      reasonPhrase: request.statusText ?? '',
      body: request.responseText ?? '',
    );
  }

  void close() {}
}
