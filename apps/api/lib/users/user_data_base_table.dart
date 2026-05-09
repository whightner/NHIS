import 'user_data_base_model.dart';

final class UserDataBaseTable {
  const UserDataBaseTable._();

  static const tableName = UserDataBaseModel.tableName;

  static const columns = [
    UserDataBaseModel.idColumn,
    UserDataBaseModel.firstNameColumn,
    UserDataBaseModel.lastNameColumn,
    UserDataBaseModel.emailColumn,
    UserDataBaseModel.phoneNumberColumn,
    UserDataBaseModel.roleColumn,
    UserDataBaseModel.statusColumn,
    UserDataBaseModel.facilityIdColumn,
    UserDataBaseModel.organizationIdColumn,
    UserDataBaseModel.patientIdColumn,
    UserDataBaseModel.createdAtColumn,
    UserDataBaseModel.updatedAtColumn,
    UserDataBaseModel.lastLoginAtColumn,
  ];

  static const createTableStatement = '''
CREATE TABLE IF NOT EXISTS $tableName (
  ${UserDataBaseModel.idColumn} TEXT PRIMARY KEY,
  ${UserDataBaseModel.firstNameColumn} TEXT NOT NULL,
  ${UserDataBaseModel.lastNameColumn} TEXT NOT NULL,
  ${UserDataBaseModel.emailColumn} TEXT UNIQUE,
  ${UserDataBaseModel.phoneNumberColumn} TEXT,
  ${UserDataBaseModel.roleColumn} TEXT NOT NULL,
  ${UserDataBaseModel.statusColumn} TEXT NOT NULL,
  ${UserDataBaseModel.facilityIdColumn} TEXT,
  ${UserDataBaseModel.organizationIdColumn} TEXT,
  ${UserDataBaseModel.patientIdColumn} TEXT,
  ${UserDataBaseModel.createdAtColumn} TIMESTAMPTZ,
  ${UserDataBaseModel.updatedAtColumn} TIMESTAMPTZ,
  ${UserDataBaseModel.lastLoginAtColumn} TIMESTAMPTZ
);
''';

  static const selectAllStatement = '''
SELECT
  ${UserDataBaseModel.idColumn},
  ${UserDataBaseModel.firstNameColumn},
  ${UserDataBaseModel.lastNameColumn},
  ${UserDataBaseModel.emailColumn},
  ${UserDataBaseModel.phoneNumberColumn},
  ${UserDataBaseModel.roleColumn},
  ${UserDataBaseModel.statusColumn},
  ${UserDataBaseModel.facilityIdColumn},
  ${UserDataBaseModel.organizationIdColumn},
  ${UserDataBaseModel.patientIdColumn},
  ${UserDataBaseModel.createdAtColumn},
  ${UserDataBaseModel.updatedAtColumn},
  ${UserDataBaseModel.lastLoginAtColumn}
FROM $tableName
ORDER BY ${UserDataBaseModel.createdAtColumn} DESC;
''';

  static const selectByIdStatement = '''
SELECT
  ${UserDataBaseModel.idColumn},
  ${UserDataBaseModel.firstNameColumn},
  ${UserDataBaseModel.lastNameColumn},
  ${UserDataBaseModel.emailColumn},
  ${UserDataBaseModel.phoneNumberColumn},
  ${UserDataBaseModel.roleColumn},
  ${UserDataBaseModel.statusColumn},
  ${UserDataBaseModel.facilityIdColumn},
  ${UserDataBaseModel.organizationIdColumn},
  ${UserDataBaseModel.patientIdColumn},
  ${UserDataBaseModel.createdAtColumn},
  ${UserDataBaseModel.updatedAtColumn},
  ${UserDataBaseModel.lastLoginAtColumn}
FROM $tableName
WHERE ${UserDataBaseModel.idColumn} = @id
LIMIT 1;
''';

  static const insertStatement = '''
INSERT INTO $tableName (
  ${UserDataBaseModel.idColumn},
  ${UserDataBaseModel.firstNameColumn},
  ${UserDataBaseModel.lastNameColumn},
  ${UserDataBaseModel.emailColumn},
  ${UserDataBaseModel.phoneNumberColumn},
  ${UserDataBaseModel.roleColumn},
  ${UserDataBaseModel.statusColumn},
  ${UserDataBaseModel.facilityIdColumn},
  ${UserDataBaseModel.organizationIdColumn},
  ${UserDataBaseModel.patientIdColumn},
  ${UserDataBaseModel.createdAtColumn},
  ${UserDataBaseModel.updatedAtColumn},
  ${UserDataBaseModel.lastLoginAtColumn}
) VALUES (
  @id,
  @first_name,
  @last_name,
  @email,
  @phone_number,
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
  ${UserDataBaseModel.firstNameColumn} = @first_name,
  ${UserDataBaseModel.lastNameColumn} = @last_name,
  ${UserDataBaseModel.emailColumn} = @email,
  ${UserDataBaseModel.phoneNumberColumn} = @phone_number,
  ${UserDataBaseModel.roleColumn} = @role,
  ${UserDataBaseModel.statusColumn} = @status,
  ${UserDataBaseModel.facilityIdColumn} = @facility_id,
  ${UserDataBaseModel.organizationIdColumn} = @organization_id,
  ${UserDataBaseModel.patientIdColumn} = @patient_id,
  ${UserDataBaseModel.updatedAtColumn} = @updated_at,
  ${UserDataBaseModel.lastLoginAtColumn} = @last_login_at
WHERE ${UserDataBaseModel.idColumn} = @id;
''';

  static const deleteByIdStatement = '''
DELETE FROM $tableName
WHERE ${UserDataBaseModel.idColumn} = @id;
''';

  static Map<String, dynamic> idParameters(String id) {
    return {UserDataBaseModel.idColumn: id};
  }

  static Map<String, dynamic> insertParameters(UserDataBaseModel user) {
    return user.toRow();
  }

  static Map<String, dynamic> updateParameters(UserDataBaseModel user) {
    final row = user.toRow();
    row.remove(UserDataBaseModel.createdAtColumn);
    return row;
  }

  static UserDataBaseModel fromRow(Map<String, dynamic> row) {
    return UserDataBaseModel.fromRow(row);
  }

  static List<UserDataBaseModel> fromRows(Iterable<Map<String, dynamic>> rows) {
    return rows.map(UserDataBaseModel.fromRow).toList(growable: false);
  }
}
