class UserDataBaseModel {
  const UserDataBaseModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.passwordHash,
    required this.role,
    required this.status,
    this.email,
    this.phoneNumber,
    this.facilityId,
    this.organizationId,
    this.patientId,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  static const tableName = 'users';

  static const idColumn = 'id';
  static const firstNameColumn = 'first_name';
  static const lastNameColumn = 'last_name';
  static const emailColumn = 'email';
  static const phoneNumberColumn = 'phone_number';
  static const passwordHashColumn = 'password_hash';
  static const roleColumn = 'role';
  static const statusColumn = 'status';
  static const facilityIdColumn = 'facility_id';
  static const organizationIdColumn = 'organization_id';
  static const patientIdColumn = 'patient_id';
  static const createdAtColumn = 'created_at';
  static const updatedAtColumn = 'updated_at';
  static const lastLoginAtColumn = 'last_login_at';

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String passwordHash;
  final String role;
  final String status;
  final String? facilityId;
  final String? organizationId;
  final String? patientId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  String get fullName => '$firstName $lastName';

  factory UserDataBaseModel.fromRow(Map<String, dynamic> row) {
    return UserDataBaseModel(
      id: row[idColumn] as String,
      firstName: row[firstNameColumn] as String,
      lastName: row[lastNameColumn] as String,
      email: row[emailColumn] as String?,
      phoneNumber: row[phoneNumberColumn] as String?,
      passwordHash: row[passwordHashColumn] as String,
      role: row[roleColumn] as String,
      status: row[statusColumn] as String,
      facilityId: row[facilityIdColumn] as String?,
      organizationId: row[organizationIdColumn] as String?,
      patientId: row[patientIdColumn] as String?,
      createdAt: _parseDateTime(row[createdAtColumn]),
      updatedAt: _parseDateTime(row[updatedAtColumn]),
      lastLoginAt: _parseDateTime(row[lastLoginAtColumn]),
    );
  }

  Map<String, dynamic> toRow() {
    return {
      idColumn: id,
      firstNameColumn: firstName,
      lastNameColumn: lastName,
      emailColumn: email,
      phoneNumberColumn: phoneNumber,
      passwordHashColumn: passwordHash,
      roleColumn: role,
      statusColumn: status,
      facilityIdColumn: facilityId,
      organizationIdColumn: organizationId,
      patientIdColumn: patientId,
      createdAtColumn: createdAt?.toIso8601String(),
      updatedAtColumn: updatedAt?.toIso8601String(),
      lastLoginAtColumn: lastLoginAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.parse(value as String);
  }
}
