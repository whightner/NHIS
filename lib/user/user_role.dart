enum UserRole {
  admin('admin'),
  facilityAdmin('facility_admin'),
  registrationAgent('registration_agent'),
  verifier('verifier'),
  auditor('auditor'),
  doctor('doctor'),
  nurse('nurse'),
  laboratoryTechnician('laboratory_technician'),
  pharmacist('pharmacist'),
  insuranceOfficer('insurance_officer'),
  patient('patient'),
  supportAgent('support_agent'),
  publicHealthOfficer('public_health_officer'),
  dataAnalyst('data_analyst');

  const UserRole(this.value);

  final String value;

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse:
          () => throw ArgumentError.value(value, 'value', 'Unknown user role'),
    );
  }
}
