import 'dart:io';

import 'package:nhis_api/app.dart';

Future<void> main() async {
  final host = InternetAddress(
    Platform.environment['NHIS_API_HOST'] ?? '0.0.0.0',
  );
  final port = int.parse(Platform.environment['NHIS_API_PORT'] ?? '8080');
  final app = NhisApiApp();

  await app.initialize();

  final server = await HttpServer.bind(host, port);

  print('NHIS API listening on http://${host.address}:$port');

  await for (final request in server) {
    await app.handle(request);
  }
}
