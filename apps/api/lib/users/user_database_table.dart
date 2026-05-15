import 'package:postgres/postgres.dart';

import '../nhis_database/nhis_database_setup.dart';
import 'user_database_model.dart';

final class UserDatabaseTable {
  const UserDatabaseTable._();

  static const tableName = UserDatabaseModel.tableName;

  // ── DDL ───────────────────────────────────────────────────────────────────

  static const createTableStatement = '''
CREATE TABLE IF NOT EXISTS $tableName (
  ${UserDatabaseModel.idColumn}                TEXT PRIMARY KEY,
  ${UserDatabaseModel.firstNameColumn}         TEXT NOT NULL,
  ${UserDatabaseModel.lastNameColumn}          TEXT NOT NULL,
  ${UserDatabaseModel.emailColumn}             TEXT UNIQUE,
  ${UserDatabaseModel.phoneNumberColumn}       TEXT,
  ${UserDatabaseModel.dateOfBirthColumn}       DATE,
  ${UserDatabaseModel.sexColumn}               TEXT,
  ${UserDatabaseModel.nationalIdColumn}        TEXT,
  ${UserDatabaseModel.licenseNumberColumn}     TEXT,
  ${UserDatabaseModel.licenseIssuerColumn}     TEXT,
  ${UserDatabaseModel.specialtyColumn}         TEXT,
  ${UserDatabaseModel.passwordHashColumn}      TEXT NOT NULL,
  ${UserDatabaseModel.roleColumn}              TEXT NOT NULL,
  ${UserDatabaseModel.statusColumn}            TEXT NOT NULL,
  ${UserDatabaseModel.facilityIdColumn}        TEXT,
  ${UserDatabaseModel.organizationIdColumn}    TEXT,
  ${UserDatabaseModel.patientIdColumn}         TEXT,
  ${UserDatabaseModel.verificationTokenColumn} TEXT,
  ${UserDatabaseModel.verifiedAtColumn}        TIMESTAMPTZ,
  ${UserDatabaseModel.createdAtColumn}         TIMESTAMPTZ,
  ${UserDatabaseModel.updatedAtColumn}         TIMESTAMPTZ,
  ${UserDatabaseModel.lastLoginAtColumn}       TIMESTAMPTZ
);
''';

  /// Idempotent migrations — safe to run on every startup.
  static const migrateTableStatements = [
    '''ALTER TABLE $tableName ADD COLUMN IF NOT EXISTS ${UserDatabaseModel.dateOfBirthColumn}       DATE;''',
    '''ALTER TABLE $tableName ADD COLUMN IF NOT EXISTS ${UserDatabaseModel.sexColumn}               TEXT;''',
    '''ALTER TABLE $tableName ADD COLUMN IF NOT EXISTS ${UserDatabaseModel.nationalIdColumn}        TEXT;''',
    '''ALTER TABLE $tableName ADD COLUMN IF NOT EXISTS ${UserDatabaseModel.licenseNumberColumn}     TEXT;''',
    '''ALTER TABLE $tableName ADD COLUMN IF NOT EXISTS ${UserDatabaseModel.licenseIssuerColumn}     TEXT;''',
    '''ALTER TABLE $tableName ADD COLUMN IF NOT EXISTS ${UserDatabaseModel.specialtyColumn}         TEXT;''',
    '''ALTER TABLE $tableName ADD COLUMN IF NOT EXISTS ${UserDatabaseModel.verificationTokenColumn} TEXT;''',
    '''ALTER TABLE $tableName ADD COLUMN IF NOT EXISTS ${UserDatabaseModel.verifiedAtColumn}        TIMESTAMPTZ;''',
  ];

  // ── DQL ───────────────────────────────────────────────────────────────────

  static const _selectColumns = '''
  ${UserDatabaseModel.idColumn},
  ${UserDatabaseModel.firstNameColumn},
  ${UserDatabaseModel.lastNameColumn},
  ${UserDatabaseModel.emailColumn},
  ${UserDatabaseModel.phoneNumberColumn},
  ${UserDatabaseModel.dateOfBirthColumn},
  ${UserDatabaseModel.sexColumn},
  ${UserDatabaseModel.nationalIdColumn},
  ${UserDatabaseModel.licenseNumberColumn},
  ${UserDatabaseModel.licenseIssuerColumn},
  ${UserDatabaseModel.specialtyColumn},
  ${UserDatabaseModel.passwordHashColumn},
  ${UserDatabaseModel.roleColumn},
  ${UserDatabaseModel.statusColumn},
  ${UserDatabaseModel.facilityIdColumn},
  ${UserDatabaseModel.organizationIdColumn},
  ${UserDatabaseModel.patientIdColumn},
  ${UserDatabaseModel.verificationTokenColumn},
  ${UserDatabaseModel.verifiedAtColumn},
  ${UserDatabaseModel.createdAtColumn},
  ${UserDatabaseModel.updatedAtColumn},
  ${UserDatabaseModel.lastLoginAtColumn}''';

  static const selectAllStatement = '''
SELECT $_selectColumns
FROM $tableName
ORDER BY ${UserDatabaseModel.createdAtColumn} DESC;
''';

  static const selectByIdStatement = '''
SELECT $_selectColumns
FROM $tableName
WHERE ${UserDatabaseModel.idColumn} = @id
LIMIT 1;
''';

  static const selectByEmailStatement = '''
SELECT $_selectColumns
FROM $tableName
WHERE ${UserDatabaseModel.emailColumn} = @email
LIMIT 1;
''';

  // ── DML ───────────────────────────────────────────────────────────────────

  static const insertStatement = '''
INSERT INTO $tableName (
  ${UserDatabaseModel.idColumn},
  ${UserDatabaseModel.firstNameColumn},
  ${UserDatabaseModel.lastNameColumn},
  ${UserDatabaseModel.emailColumn},
  ${UserDatabaseModel.phoneNumberColumn},
  ${UserDatabaseModel.dateOfBirthColumn},
  ${UserDatabaseModel.sexColumn},
  ${UserDatabaseModel.nationalIdColumn},
  ${UserDatabaseModel.licenseNumberColumn},
  ${UserDatabaseModel.licenseIssuerColumn},
  ${UserDatabaseModel.specialtyColumn},
  ${UserDatabaseModel.passwordHashColumn},
  ${UserDatabaseModel.roleColumn},
  ${UserDatabaseModel.statusColumn},
  ${UserDatabaseModel.facilityIdColumn},
  ${UserDatabaseModel.organizationIdColumn},
  ${UserDatabaseModel.patientIdColumn},
  ${UserDatabaseModel.verificationTokenColumn},
  ${UserDatabaseModel.verifiedAtColumn},
  ${UserDatabaseModel.createdAtColumn},
  ${UserDatabaseModel.updatedAtColumn},
  ${UserDatabaseModel.lastLoginAtColumn}
) VALUES (
  @id,
  @first_name,
  @last_name,
  @email,
  @phone_number,
  @date_of_birth,
  @sex,
  @national_id,
  @license_number,
  @license_issuer,
  @specialty,
  @password_hash,
  @role,
  @status,
  @facility_id,
  @organization_id,
  @patient_id,
  @verification_token,
  @verified_at,
  @created_at,
  @updated_at,
  @last_login_at
);
''';

  static const updateByIdStatement = '''
UPDATE $tableName
SET
  ${UserDatabaseModel.firstNameColumn}         = @first_name,
  ${UserDatabaseModel.lastNameColumn}          = @last_name,
  ${UserDatabaseModel.emailColumn}             = @email,
  ${UserDatabaseModel.phoneNumberColumn}       = @phone_number,
  ${UserDatabaseModel.dateOfBirthColumn}       = @date_of_birth,
  ${UserDatabaseModel.sexColumn}               = @sex,
  ${UserDatabaseModel.nationalIdColumn}        = @national_id,
  ${UserDatabaseModel.licenseNumberColumn}     = @license_number,
  ${UserDatabaseModel.licenseIssuerColumn}     = @license_issuer,
  ${UserDatabaseModel.specialtyColumn}         = @specialty,
  ${UserDatabaseModel.passwordHashColumn}      = @password_hash,
  ${UserDatabaseModel.roleColumn}              = @role,
  ${UserDatabaseModel.statusColumn}            = @status,
  ${UserDatabaseModel.facilityIdColumn}        = @facility_id,
  ${UserDatabaseModel.organizationIdColumn}    = @organization_id,
  ${UserDatabaseModel.patientIdColumn}         = @patient_id,
  ${UserDatabaseModel.verificationTokenColumn} = @verification_token,
  ${UserDatabaseModel.verifiedAtColumn}        = @verified_at,
  ${UserDatabaseModel.updatedAtColumn}         = @updated_at,
  ${UserDatabaseModel.lastLoginAtColumn}       = @last_login_at
WHERE ${UserDatabaseModel.idColumn} = @id;
''';

  static const deleteByIdStatement = '''
DELETE FROM $tableName
WHERE ${UserDatabaseModel.idColumn} = @id;
''';

  // ── Setup ─────────────────────────────────────────────────────────────────

  static Future<void> createTable() async {
    await _execute(createTableStatement, ignoreRows: true);
    for (final stmt in migrateTableStatements) {
      await _execute(stmt, ignoreRows: true);
    }
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  static Future<List<UserDatabaseModel>> selectAll() async {
    final result = await _execute(selectAllStatement);
    return fromRows(result.map((row) => row.toColumnMap()));
  }

  static Future<UserDatabaseModel?> selectById(String id) async {
    final result = await _execute(
      Sql.named(selectByIdStatement),
      parameters: {UserDatabaseModel.idColumn: id},
    );
    if (result.isEmpty) return null;
    return fromRow(result.first.toColumnMap());
  }

  static Future<UserDatabaseModel?> selectByEmail(String email) async {
    final result = await _execute(
      Sql.named(selectByEmailStatement),
      parameters: {UserDatabaseModel.emailColumn: email},
    );
    if (result.isEmpty) return null;
    return fromRow(result.first.toColumnMap());
  }

  static Future<int> insert(UserDatabaseModel user) async {
    final result = await _execute(
      Sql.named(insertStatement),
      parameters: _insertParameters(user),
      ignoreRows: true,
    );
    return result.affectedRows;
  }

  static Future<int> updateById(UserDatabaseModel user) async {
    final result = await _execute(
      Sql.named(updateByIdStatement),
      parameters: _updateParameters(user),
      ignoreRows: true,
    );
    return result.affectedRows;
  }

  static Future<int> deleteById(String id) async {
    final result = await _execute(
      Sql.named(deleteByIdStatement),
      parameters: {UserDatabaseModel.idColumn: id},
      ignoreRows: true,
    );
    return result.affectedRows;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static UserDatabaseModel fromRow(Map<String, dynamic> row) =>
      UserDatabaseModel.fromRow(row);

  static List<UserDatabaseModel> fromRows(
    Iterable<Map<String, dynamic>> rows,
  ) => rows.map(UserDatabaseModel.fromRow).toList(growable: false);

  static Map<String, dynamic> _insertParameters(UserDatabaseModel user) =>
      user.toRow();

  static Map<String, dynamic> _updateParameters(UserDatabaseModel user) {
    final row = user.toRow();
    row.remove(UserDatabaseModel.createdAtColumn);
    return row;
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