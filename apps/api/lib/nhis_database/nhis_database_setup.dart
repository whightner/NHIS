import 'dart:io';

import 'package:postgres/postgres.dart';

final class NhisDatabaseConfig {
  const NhisDatabaseConfig({
    required this.host,
    required this.database,
    required this.username,
    required this.password,
    this.port = 5432,
    this.sslMode = SslMode.require,
  });

  static const defaultDatabaseName = 'nhis_database';

  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
  final SslMode sslMode;

  factory NhisDatabaseConfig.fromEnvironment([
    Map<String, String>? environment,
  ]) {
    final env = environment ?? Platform.environment;

    return NhisDatabaseConfig(
      host: _requiredEnvironment(env, 'NHIS_DB_HOST'),
      port: int.parse(env['NHIS_DB_PORT'] ?? '5432'),
      database: env['NHIS_DB_NAME'] ?? defaultDatabaseName,
      username: _requiredEnvironment(env, 'NHIS_DB_USER'),
      password: _requiredEnvironment(env, 'NHIS_DB_PASSWORD'),
      sslMode: _parseSslMode(env['NHIS_DB_SSL_MODE'] ?? 'require'),
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

  ConnectionSettings toConnectionSettings() {
    return ConnectionSettings(sslMode: sslMode);
  }

  static SslMode _parseSslMode(String value) {
    switch (value.trim().toLowerCase()) {
      case 'disable':
        return SslMode.disable;
      case 'require':
        return SslMode.require;
      case 'verify_full':
      case 'verify-full':
      case 'verifyfull':
        return SslMode.verifyFull;
      default:
        throw StateError('Unsupported NHIS_DB_SSL_MODE value: $value');
    }
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

final class NhisDatabaseSetup {
  NhisDatabaseSetup._();

  static final instance = NhisDatabaseSetup._();

  Connection? _connection;

  Future<Connection> get connection => connect();

  Future<Connection> connect({NhisDatabaseConfig? config}) async {
    final existingConnection = _connection;

    if (existingConnection != null) {
      return existingConnection;
    }

    final resolvedConfig = config ?? NhisDatabaseConfig.fromEnvironment();
    final connection = await Connection.open(
      resolvedConfig.toEndpoint(),
      settings: resolvedConfig.toConnectionSettings(),
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
