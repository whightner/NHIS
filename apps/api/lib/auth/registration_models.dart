/// Thrown when a registration input fails validation.
final class RegistrationValidationException implements Exception {
  const RegistrationValidationException(this.message);

  final String message;

  @override
  String toString() => 'RegistrationValidationException: $message';
}

/// Thrown when a registration attempt violates a security policy
/// (e.g., invalid invite code, registration closed for role).
final class RegistrationPolicyException implements Exception {
  const RegistrationPolicyException(this.message);

  final String message;

  @override
  String toString() => 'RegistrationPolicyException: $message';
}

/// Normalised, validated registration payload.
/// Constructed by [AuthValidator], not directly from raw HTTP input.
final class RegisterRequest {
  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.sex,
    required this.email,
    required this.password,
    required this.role,
    this.phoneNumber,
    // Doctor-specific
    this.licenseNumber,
    this.licenseIssuer,
    this.specialty,
    // Doctor / Admin invite key
    this.inviteCode,
  });

  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String sex;
  final String email;
  final String password;
  final String role;
  final String? phoneNumber;
  final String? licenseNumber;
  final String? licenseIssuer;
  final String? specialty;
  final String? inviteCode;
}
