import 'dart:io';

import 'package:postgres/postgres.dart';

final class NhisDataBaseConfig {
  const NhisDataBaseConfig({
    required this.host,
    required this.database,
    required this.username,
    required this.password,
    this.port = 5432,
  });

  static const defaultDatabaseName = 'nhis_database';

  final String host;
  final int port;
  final String database;
  final String username;
  final String password;

  factory NhisDataBaseConfig.fromEnvironment([
    Map<String, String>? environment,
  ]) {
    final env = environment ?? Platform.environment;

    return NhisDataBaseConfig(
      host: _requiredEnvironment(env, 'DB_HOST'),
      port: int.parse(env['NHIS_DB_PORT'] ?? '5432'),
      database: env['NHIS_DB_NAME'] ?? defaultDatabaseName,
      username: _requiredEnvironment(env, 'NHIS_DB_USER'),
      password: _requiredEnvironment(env, 'NHIS_DB_PASSWORD'),
    );
  }

  Endpoint toEndpoint() {
    return Endpoint(
      host: host,
      port: port,
      database: database,
      username: username,
      password: password,
    );
  }

  static String _requiredEnvironment(
    Map<String, String> environment,
    String name,
  ) {
    final value = environment[name];

    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing required environment variable: $name');
    }

    return value;
  }
}

final class NhisDataBaseSetup {
  NhisDataBaseSetup._();

  static final instance = NhisDataBaseSetup._();

  Connection? _connection;

  Future<Connection> get connection => connect();

  Future<Connection> connect({NhisDataBaseConfig? config}) async {
    final existingConnection = _connection;

    if (existingConnection != null) {
      return existingConnection;
    }

    final resolvedConfig = config ?? NhisDataBaseConfig.fromEnvironment();
    final connection = await Connection.open(
      resolvedConfig.toEndpoint(),
      settings: const ConnectionSettings(sslMode: SslMode.require),
    );

    _connection = connection;
    return connection;
  }

  Future<void> close() async {
    final existingConnection = _connection;
    _connection = null;
    await existingConnection?.close();
  }
}
