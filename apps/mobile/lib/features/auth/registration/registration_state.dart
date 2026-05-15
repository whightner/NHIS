/// Mutable registration wizard state — one object per wizard session.
/// Passed top-down through all steps; never sent to the API until Step 7.
class RegistrationState {
  // Step 1 — Personal information
  String firstName = '';
  String lastName = '';
  String dateOfBirth = ''; // YYYY-MM-DD
  String sex = '';

  // Step 2 — Contact information
  String email = '';
  String phoneNumber = '';

  // Step 3 — Account security
  String password = '';
  String confirmPassword = '';

  // Step 5 — Role
  String role = '';

  // Step 6 — Role-specific (doctor)
  String licenseNumber = '';
  String licenseIssuer = '';
  String specialty = '';
  String inviteCode = '';

  // Convenience
  bool get isPatient => role == 'patient';
  bool get isDoctor => role == 'doctor';
  bool get isAdmin => role == 'admin';

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'sex': sex,
      'email': email,
      'password': password,
      'role': role,
    };
    if (phoneNumber.trim().isNotEmpty) {
      json['phone_number'] = phoneNumber.trim();
    }
    if (isDoctor) {
      if (licenseNumber.trim().isNotEmpty) {
        json['license_number'] = licenseNumber.trim();
      }
      if (licenseIssuer.trim().isNotEmpty) {
        json['license_issuer'] = licenseIssuer.trim();
      }
      if (specialty.trim().isNotEmpty) {
        json['specialty'] = specialty.trim();
      }
      if (inviteCode.trim().isNotEmpty) {
        json['invite_code'] = inviteCode.trim();
      }
    }
    if (isAdmin && inviteCode.trim().isNotEmpty) {
      json['invite_code'] = inviteCode.trim();
    }
    return json;
  }
}
