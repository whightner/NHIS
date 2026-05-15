class UserDatabaseModel {
  const UserDatabaseModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.passwordHash,
    required this.role,
    required this.status,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.sex,
    this.nationalId,
    this.licenseNumber,
    this.licenseIssuer,
    this.specialty,
    this.facilityId,
    this.organizationId,
    this.patientId,
    this.verificationToken,
    this.verifiedAt,
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
  static const dateOfBirthColumn = 'date_of_birth';
  static const sexColumn = 'sex';
  static const nationalIdColumn = 'national_id';
  static const licenseNumberColumn = 'license_number';
  static const licenseIssuerColumn = 'license_issuer';
  static const specialtyColumn = 'specialty';
  static const passwordHashColumn = 'password_hash';
  static const roleColumn = 'role';
  static const statusColumn = 'status';
  static const facilityIdColumn = 'facility_id';
  static const organizationIdColumn = 'organization_id';
  static const patientIdColumn = 'patient_id';
  static const verificationTokenColumn = 'verification_token';
  static const verifiedAtColumn = 'verified_at';
  static const createdAtColumn = 'created_at';
  static const updatedAtColumn = 'updated_at';
  static const lastLoginAtColumn = 'last_login_at';

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? sex;
  final String? nationalId;
  final String? licenseNumber;
  final String? licenseIssuer;
  final String? specialty;
  final String passwordHash;
  final String role;
  final String status;
  final String? facilityId;
  final String? organizationId;
  final String? patientId;
  final String? verificationToken;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  String get fullName => '$firstName $lastName';

  factory UserDatabaseModel.fromRow(Map<String, dynamic> row) {
    return UserDatabaseModel(
      id: row[idColumn] as String,
      firstName: row[firstNameColumn] as String,
      lastName: row[lastNameColumn] as String,
      email: row[emailColumn] as String?,
      phoneNumber: row[phoneNumberColumn] as String?,
      dateOfBirth: _parseDateTime(row[dateOfBirthColumn]),
      sex: row[sexColumn] as String?,
      nationalId: row[nationalIdColumn] as String?,
      licenseNumber: row[licenseNumberColumn] as String?,
      licenseIssuer: row[licenseIssuerColumn] as String?,
      specialty: row[specialtyColumn] as String?,
      passwordHash: row[passwordHashColumn] as String,
      role: row[roleColumn] as String,
      status: row[statusColumn] as String,
      facilityId: row[facilityIdColumn] as String?,
      organizationId: row[organizationIdColumn] as String?,
      patientId: row[patientIdColumn] as String?,
      verificationToken: row[verificationTokenColumn] as String?,
      verifiedAt: _parseDateTime(row[verifiedAtColumn]),
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
      dateOfBirthColumn: _dateOnly(dateOfBirth),
      sexColumn: sex,
      nationalIdColumn: nationalId,
      licenseNumberColumn: licenseNumber,
      licenseIssuerColumn: licenseIssuer,
      specialtyColumn: specialty,
      passwordHashColumn: passwordHash,
      roleColumn: role,
      statusColumn: status,
      facilityIdColumn: facilityId,
      organizationIdColumn: organizationId,
      patientIdColumn: patientId,
      verificationTokenColumn: verificationToken,
      verifiedAtColumn: verifiedAt?.toIso8601String(),
      createdAtColumn: createdAt?.toIso8601String(),
      updatedAtColumn: updatedAt?.toIso8601String(),
      lastLoginAtColumn: lastLoginAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.parse(value as String);
  }

  static String? _dateOnly(DateTime? value) {
    if (value == null) return null;
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}