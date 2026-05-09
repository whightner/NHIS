import 'package:postgres/postgres.dart';

import '../nhis_database/nhis_database_setup.dart';
import 'user_database_model.dart';

final class UserDatabaseTable {
  const UserDatabaseTable._();

  static const tableName = UserDatabaseModel.tableName;

  static const columns = [
    UserDatabaseModel.idColumn,
    UserDatabaseModel.firstNameColumn,
    UserDatabaseModel.lastNameColumn,
    UserDatabaseModel.emailColumn,
    UserDatabaseModel.phoneNumberColumn,
    UserDatabaseModel.passwordHashColumn,
    UserDatabaseModel.roleColumn,
    UserDatabaseModel.statusColumn,
    UserDatabaseModel.facilityIdColumn,
    UserDatabaseModel.organizationIdColumn,
    UserDatabaseModel.patientIdColumn,
    UserDatabaseModel.createdAtColumn,
    UserDatabaseModel.updatedAtColumn,
    UserDatabaseModel.lastLoginAtColumn,
  ];

  static const createTableStatement = '''
CREATE TABLE IF NOT EXISTS $tableName (
  ${UserDatabaseModel.idColumn} TEXT PRIMARY KEY,
  ${UserDatabaseModel.firstNameColumn} TEXT NOT NULL,
  ${UserDatabaseModel.lastNameColumn} TEXT NOT NULL,
  ${UserDatabaseModel.emailColumn} TEXT UNIQUE,
  ${UserDatabaseModel.phoneNumberColumn} TEXT,
  ${UserDatabaseModel.passwordHashColumn} TEXT NOT NULL,
  ${UserDatabaseModel.roleColumn} TEXT NOT NULL,
  ${UserDatabaseModel.statusColumn} TEXT NOT NULL,
  ${UserDatabaseModel.facilityIdColumn} TEXT,
  ${UserDatabaseModel.organizationIdColumn} TEXT,
  ${UserDatabaseModel.patientIdColumn} TEXT,
  ${UserDatabaseModel.createdAtColumn} TIMESTAMPTZ,
  ${UserDatabaseModel.updatedAtColumn} TIMESTAMPTZ,
  ${UserDatabaseModel.lastLoginAtColumn} TIMESTAMPTZ
);
''';

  static const selectAllStatement = '''
SELECT
  ${UserDatabaseModel.idColumn},
  ${UserDatabaseModel.firstNameColumn},
  ${UserDatabaseModel.lastNameColumn},
  ${UserDatabaseModel.emailColumn},
  ${UserDatabaseModel.phoneNumberColumn},
  ${UserDatabaseModel.passwordHashColumn},
  ${UserDatabaseModel.roleColumn},
  ${UserDatabaseModel.statusColumn},
  ${UserDatabaseModel.facilityIdColumn},
  ${UserDatabaseModel.organizationIdColumn},
  ${UserDatabaseModel.patientIdColumn},
  ${UserDatabaseModel.createdAtColumn},
  ${UserDatabaseModel.updatedAtColumn},
  ${UserDatabaseModel.lastLoginAtColumn}
FROM $tableName
ORDER BY ${UserDatabaseModel.createdAtColumn} DESC;
''';

  static const selectByIdStatement = '''
SELECT
  ${UserDatabaseModel.idColumn},
  ${UserDatabaseModel.firstNameColumn},
  ${UserDatabaseModel.lastNameColumn},
  ${UserDatabaseModel.emailColumn},
  ${UserDatabaseModel.phoneNumberColumn},
  ${UserDatabaseModel.passwordHashColumn},
  ${UserDatabaseModel.roleColumn},
  ${UserDatabaseModel.statusColumn},
  ${UserDatabaseModel.facilityIdColumn},
  ${UserDatabaseModel.organizationIdColumn},
  ${UserDatabaseModel.patientIdColumn},
  ${UserDatabaseModel.createdAtColumn},
  ${UserDatabaseModel.updatedAtColumn},
  ${UserDatabaseModel.lastLoginAtColumn}
FROM $tableName
WHERE ${UserDatabaseModel.idColumn} = @id
LIMIT 1;
''';

  static const insertStatement = '''
INSERT INTO $tableName (
  ${UserDatabaseModel.idColumn},
  ${UserDatabaseModel.firstNameColumn},
  ${UserDatabaseModel.lastNameColumn},
  ${UserDatabaseModel.emailColumn},
  ${UserDatabaseModel.phoneNumberColumn},
  ${UserDatabaseModel.passwordHashColumn},
  ${UserDatabaseModel.roleColumn},
  ${UserDatabaseModel.statusColumn},
  ${UserDatabaseModel.facilityIdColumn},
  ${UserDatabaseModel.organizationIdColumn},
  ${UserDatabaseModel.patientIdColumn},
  ${UserDatabaseModel.createdAtColumn},
  ${UserDatabaseModel.updatedAtColumn},
  ${UserDatabaseModel.lastLoginAtColumn}
) VALUES (
  @id,
  @first_name,
  @last_name,
  @email,
  @phone_number,
  @password_hash,
  @role,
  @status,
  @facility_id,
  @organization_id,
  @patient_id,
  @created_at,
  @updated_at,
  @last_login_at
);
''';

  static const updateByIdStatement = '''
UPDATE $tableName
SET
  ${UserDatabaseModel.firstNameColumn} = @first_name,
  ${UserDatabaseModel.lastNameColumn} = @last_name,
  ${UserDatabaseModel.emailColumn} = @email,
  ${UserDatabaseModel.phoneNumberColumn} = @phone_number,
  ${UserDatabaseModel.passwordHashColumn} = @password_hash,
  ${UserDatabaseModel.roleColumn} = @role,
  ${UserDatabaseModel.statusColumn} = @status,
  ${UserDatabaseModel.facilityIdColumn} = @facility_id,
  ${UserDatabaseModel.organizationIdColumn} = @organization_id,
  ${UserDatabaseModel.patientIdColumn} = @patient_id,
  ${UserDatabaseModel.updatedAtColumn} = @updated_at,
  ${UserDatabaseModel.lastLoginAtColumn} = @last_login_at
WHERE ${UserDatabaseModel.idColumn} = @id;
''';

  static const deleteByIdStatement = '''
DELETE FROM $tableName
WHERE ${UserDatabaseModel.idColumn} = @id;
''';

  static Future<void> createTable() async {
    await _execute(createTableStatement, ignoreRows: true);
  }

  static Future<List<UserDatabaseModel>> selectAll() async {
    final result = await _execute(selectAllStatement);

    return fromRows(result.map((row) => row.toColumnMap()));
  }

  static Future<UserDatabaseModel?> selectById(String id) async {
    final result = await _execute(
      Sql.named(selectByIdStatement),
      parameters: idParameters(id),
    );

    if (result.isEmpty) {
      return null;
    }

    return fromRow(result.first.toColumnMap());
  }

  static Future<int> insert(UserDatabaseModel user) async {
    final result = await _execute(
      Sql.named(insertStatement),
      parameters: insertParameters(user),
      ignoreRows: true,
    );

    return result.affectedRows;
  }

  static Future<int> updateById(UserDatabaseModel user) async {
    final result = await _execute(
      Sql.named(updateByIdStatement),
      parameters: updateParameters(user),
      ignoreRows: true,
    );

    return result.affectedRows;
  }

  static Future<int> deleteById(String id) async {
    final result = await _execute(
      Sql.named(deleteByIdStatement),
      parameters: idParameters(id),
      ignoreRows: true,
    );

    return result.affectedRows;
  }

  static Map<String, dynamic> idParameters(String id) {
    return {UserDatabaseModel.idColumn: id};
  }

  static Map<String, dynamic> insertParameters(UserDatabaseModel user) {
    return user.toRow();
  }

  static Map<String, dynamic> updateParameters(UserDatabaseModel user) {
    final row = user.toRow();
    row.remove(UserDatabaseModel.createdAtColumn);
    return row;
  }

  static UserDatabaseModel fromRow(Map<String, dynamic> row) {
    return UserDatabaseModel.fromRow(row);
  }

  static List<UserDatabaseModel> fromRows(Iterable<Map<String, dynamic>> rows) {
    return rows.map(UserDatabaseModel.fromRow).toList(growable: false);
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
