import 'dart:convert';
import 'dart:io';

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
  ApiHttpClient({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  Future<ApiHttpResponse> sendJson({
    required String method,
    required Uri uri,
    String? accessToken,
    Map<String, dynamic>? body,
  }) async {
    final request = await _httpClient.openUrl(method, uri);
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

    return ApiHttpResponse(
      statusCode: response.statusCode,
      reasonPhrase: response.reasonPhrase,
      body: await utf8.decoder.bind(response).join(),
    );
  }

  void close() {
    _httpClient.close(force: true);
  }
}
