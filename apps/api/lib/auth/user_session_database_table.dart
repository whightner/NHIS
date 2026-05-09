import 'package:postgres/postgres.dart';

import '../nhis_database/nhis_database_setup.dart';
import 'user_session_database_model.dart';

final class UserSessionDatabaseTable {
  const UserSessionDatabaseTable._();

  static const tableName = UserSessionDatabaseModel.tableName;

  static const columns = [
    UserSessionDatabaseModel.idColumn,
    UserSessionDatabaseModel.userIdColumn,
    UserSessionDatabaseModel.refreshTokenHashColumn,
    UserSessionDatabaseModel.deviceIdColumn,
    UserSessionDatabaseModel.ipAddressColumn,
    UserSessionDatabaseModel.userAgentColumn,
    UserSessionDatabaseModel.createdAtColumn,
    UserSessionDatabaseModel.expiresAtColumn,
    UserSessionDatabaseModel.lastUsedAtColumn,
    UserSessionDatabaseModel.revokedAtColumn,
    UserSessionDatabaseModel.replacedBySessionIdColumn,
  ];

  static const createTableStatement = '''
CREATE TABLE IF NOT EXISTS $tableName (
  ${UserSessionDatabaseModel.idColumn} TEXT PRIMARY KEY,
  ${UserSessionDatabaseModel.userIdColumn} TEXT NOT NULL,
  ${UserSessionDatabaseModel.refreshTokenHashColumn} TEXT NOT NULL UNIQUE,
  ${UserSessionDatabaseModel.deviceIdColumn} TEXT,
  ${UserSessionDatabaseModel.ipAddressColumn} TEXT,
  ${UserSessionDatabaseModel.userAgentColumn} TEXT,
  ${UserSessionDatabaseModel.createdAtColumn} TIMESTAMPTZ NOT NULL,
  ${UserSessionDatabaseModel.expiresAtColumn} TIMESTAMPTZ NOT NULL,
  ${UserSessionDatabaseModel.lastUsedAtColumn} TIMESTAMPTZ,
  ${UserSessionDatabaseModel.revokedAtColumn} TIMESTAMPTZ,
  ${UserSessionDatabaseModel.replacedBySessionIdColumn} TEXT
);
''';

  static const createUserIdIndexStatement = '''
CREATE INDEX IF NOT EXISTS user_sessions_user_id_idx
ON $tableName (${UserSessionDatabaseModel.userIdColumn});
''';

  static const createRefreshTokenHashIndexStatement = '''
CREATE INDEX IF NOT EXISTS user_sessions_refresh_token_hash_idx
ON $tableName (${UserSessionDatabaseModel.refreshTokenHashColumn});
''';

  static const selectByIdStatement = '''
SELECT
  ${UserSessionDatabaseModel.idColumn},
  ${UserSessionDatabaseModel.userIdColumn},
  ${UserSessionDatabaseModel.refreshTokenHashColumn},
  ${UserSessionDatabaseModel.deviceIdColumn},
  ${UserSessionDatabaseModel.ipAddressColumn},
  ${UserSessionDatabaseModel.userAgentColumn},
  ${UserSessionDatabaseModel.createdAtColumn},
  ${UserSessionDatabaseModel.expiresAtColumn},
  ${UserSessionDatabaseModel.lastUsedAtColumn},
  ${UserSessionDatabaseModel.revokedAtColumn},
  ${UserSessionDatabaseModel.replacedBySessionIdColumn}
FROM $tableName
WHERE ${UserSessionDatabaseModel.idColumn} = @id
LIMIT 1;
''';

  static const selectByRefreshTokenHashStatement = '''
SELECT
  ${UserSessionDatabaseModel.idColumn},
  ${UserSessionDatabaseModel.userIdColumn},
  ${UserSessionDatabaseModel.refreshTokenHashColumn},
  ${UserSessionDatabaseModel.deviceIdColumn},
  ${UserSessionDatabaseModel.ipAddressColumn},
  ${UserSessionDatabaseModel.userAgentColumn},
  ${UserSessionDatabaseModel.createdAtColumn},
  ${UserSessionDatabaseModel.expiresAtColumn},
  ${UserSessionDatabaseModel.lastUsedAtColumn},
  ${UserSessionDatabaseModel.revokedAtColumn},
  ${UserSessionDatabaseModel.replacedBySessionIdColumn}
FROM $tableName
WHERE ${UserSessionDatabaseModel.refreshTokenHashColumn} = @refresh_token_hash
LIMIT 1;
''';

  static const insertStatement = '''
INSERT INTO $tableName (
  ${UserSessionDatabaseModel.idColumn},
  ${UserSessionDatabaseModel.userIdColumn},
  ${UserSessionDatabaseModel.refreshTokenHashColumn},
  ${UserSessionDatabaseModel.deviceIdColumn},
  ${UserSessionDatabaseModel.ipAddressColumn},
  ${UserSessionDatabaseModel.userAgentColumn},
  ${UserSessionDatabaseModel.createdAtColumn},
  ${UserSessionDatabaseModel.expiresAtColumn},
  ${UserSessionDatabaseModel.lastUsedAtColumn},
  ${UserSessionDatabaseModel.revokedAtColumn},
  ${UserSessionDatabaseModel.replacedBySessionIdColumn}
) VALUES (
  @id,
  @user_id,
  @refresh_token_hash,
  @device_id,
  @ip_address,
  @user_agent,
  @created_at,
  @expires_at,
  @last_used_at,
  @revoked_at,
  @replaced_by_session_id
);
''';

  static const updateLastUsedAtStatement = '''
UPDATE $tableName
SET ${UserSessionDatabaseModel.lastUsedAtColumn} = @last_used_at
WHERE ${UserSessionDatabaseModel.idColumn} = @id;
''';

  static const revokeByIdStatement = '''
UPDATE $tableName
SET
  ${UserSessionDatabaseModel.revokedAtColumn} = @revoked_at,
  ${UserSessionDatabaseModel.replacedBySessionIdColumn} = @replaced_by_session_id
WHERE ${UserSessionDatabaseModel.idColumn} = @id;
''';

  static const deleteExpiredStatement = '''
DELETE FROM $tableName
WHERE ${UserSessionDatabaseModel.expiresAtColumn} <= @expires_at;
''';

  static Future<void> createTable() async {
    await _execute(createTableStatement, ignoreRows: true);
    await _execute(createUserIdIndexStatement, ignoreRows: true);
    await _execute(createRefreshTokenHashIndexStatement, ignoreRows: true);
  }

  static Future<UserSessionDatabaseModel?> selectById(String id) async {
    final result = await _execute(
      Sql.named(selectByIdStatement),
      parameters: idParameters(id),
    );

    if (result.isEmpty) {
      return null;
    }

    return fromRow(result.first.toColumnMap());
  }

  static Future<UserSessionDatabaseModel?> selectByRefreshTokenHash(
    String refreshTokenHash,
  ) async {
    final result = await _execute(
      Sql.named(selectByRefreshTokenHashStatement),
      parameters: refreshTokenHashParameters(refreshTokenHash),
    );

    if (result.isEmpty) {
      return null;
    }

    return fromRow(result.first.toColumnMap());
  }

  static Future<int> insert(UserSessionDatabaseModel session) async {
    final result = await _execute(
      Sql.named(insertStatement),
      parameters: insertParameters(session),
      ignoreRows: true,
    );

    return result.affectedRows;
  }

  static Future<int> updateLastUsedAt({
    required String id,
    required DateTime lastUsedAt,
  }) async {
    final result = await _execute(
      Sql.named(updateLastUsedAtStatement),
      parameters: {
        UserSessionDatabaseModel.idColumn: id,
        UserSessionDatabaseModel.lastUsedAtColumn: lastUsedAt.toUtc(),
      },
      ignoreRows: true,
    );

    return result.affectedRows;
  }

  static Future<int> revokeById({
    required String id,
    required DateTime revokedAt,
    String? replacedBySessionId,
  }) async {
    final result = await _execute(
      Sql.named(revokeByIdStatement),
      parameters: {
        UserSessionDatabaseModel.idColumn: id,
        UserSessionDatabaseModel.revokedAtColumn: revokedAt.toUtc(),
        UserSessionDatabaseModel.replacedBySessionIdColumn: replacedBySessionId,
      },
      ignoreRows: true,
    );

    return result.affectedRows;
  }

  static Future<int> deleteExpired({DateTime? at}) async {
    final result = await _execute(
      Sql.named(deleteExpiredStatement),
      parameters: {
        UserSessionDatabaseModel.expiresAtColumn:
            (at ?? DateTime.now()).toUtc(),
      },
      ignoreRows: true,
    );

    return result.affectedRows;
  }

  static Map<String, dynamic> idParameters(String id) {
    return {UserSessionDatabaseModel.idColumn: id};
  }

  static Map<String, dynamic> refreshTokenHashParameters(
    String refreshTokenHash,
  ) {
    return {UserSessionDatabaseModel.refreshTokenHashColumn: refreshTokenHash};
  }

  static Map<String, dynamic> insertParameters(
    UserSessionDatabaseModel session,
  ) {
    return session.toRow();
  }

  static UserSessionDatabaseModel fromRow(Map<String, dynamic> row) {
    return UserSessionDatabaseModel.fromRow(row);
  }

  static Future<Result> _execute(
    Object query, {
    Object? parameters,
    bool ignoreRows = false,
  }) async {
    final connection = await NhisDatabaseSetup.instance.connection;

    return connection.execute(
      query,
      parameters: parameters,
      ignoreRows: ignoreRows,
    );
  }
}
