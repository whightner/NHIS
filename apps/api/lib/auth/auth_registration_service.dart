import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'auth_password_service.dart';
import 'auth_validator.dart';
import 'registration_models.dart';
import '../users/user_database_model.dart';
import '../users/user_database_table.dart';

/// Policy constants for role-gated registration.
/// Values come exclusively from environment variables — never hardcoded.
final class RegistrationPolicy {
  const RegistrationPolicy._();

  /// Returns the required invite code for doctor registration,
  /// or null if doctor self-registration is disabled.
  static String? get doctorInviteCode {
    return _env('NHIS_DOCTOR_INVITE_CODE');
  }

  /// Returns the required invite code for admin registration,
  /// or null if admin self-registration is disabled.
  static String? get adminInviteCode {
    return _env('NHIS_ADMIN_INVITE_CODE');
  }

  static String? _env(String key) {
    final value = Platform.environment[key]?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }
}

/// Handles the complete registration flow:
/// validation → policy checks → uniqueness → persistence.
///
/// Keeps all business rules out of the HTTP layer.
final class AuthRegistrationService {
  AuthRegistrationService({AuthPasswordService? passwordService})
    : _passwordService = passwordService ?? const AuthPasswordService();

  final AuthPasswordService _passwordService;

  /// Parses and validates the raw JSON body, enforces role policies,
  /// then inserts the new user and returns the created [UserDatabaseModel].
  Future<UserDatabaseModel> register(Map<String, dynamic> body) async {
    final request = _parseAndValidate(body);
    await _enforceRolePolicy(request);
    await _ensureEmailAvailable(request.email);
    return _persist(request);
  }

  // ── Parsing & validation ──────────────────────────────────────────────────

  RegisterRequest _parseAndValidate(Map<String, dynamic> body) {
    final firstName = AuthValidator.validateRequiredField(
      body['first_name'] as String?,
      'First name',
    );
    final lastName = AuthValidator.validateRequiredField(
      body['last_name'] as String?,
      'Last name',
    );
    final dateOfBirth = AuthValidator.validateDateOfBirth(
      body['date_of_birth'] as String?,
    );
    final sex = AuthValidator.validateSex(body['sex'] as String?);
    final email = AuthValidator.validateAndNormalizeEmail(
      body['email'] as String?,
    );
    final phoneNumber = AuthValidator.validatePhoneNumber(
      body['phone_number'] as String?,
    );
    final password = AuthValidator.validateRequiredField(
      body['password'] as String?,
      'Password',
    );
    AuthValidator.validatePassword(password);
    final role = AuthValidator.validateRole(body['role'] as String?);

    // Role-specific fields
    String? licenseNumber;
    String? licenseIssuer;
    String? specialty;
    String? inviteCode;

    if (role == 'doctor') {
      licenseNumber = AuthValidator.validateLicenseNumber(
        body['license_number'] as String?,
      );
      licenseIssuer = AuthValidator.validateOptionalField(
        body['license_issuer'] as String?,
      );
      specialty = AuthValidator.validateOptionalField(
        body['specialty'] as String?,
      );
      inviteCode = AuthValidator.validateOptionalField(
        body['invite_code'] as String?,
      );
    }

    if (role == 'admin') {
      inviteCode = AuthValidator.validateOptionalField(
        body['invite_code'] as String?,
      );
    }

    return RegisterRequest(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      sex: sex,
      email: email,
      password: password,
      role: role,
      phoneNumber: phoneNumber,
      licenseNumber: licenseNumber,
      licenseIssuer: licenseIssuer,
      specialty: specialty,
      inviteCode: inviteCode,
    );
  }

  // ── Role policy ───────────────────────────────────────────────────────────

  Future<void> _enforceRolePolicy(RegisterRequest request) async {
    switch (request.role) {
      case 'patient':
        // Patient registration is always open — no special gate.
        return;

      case 'doctor':
        final expected = RegistrationPolicy.doctorInviteCode;
        if (expected == null) {
          throw const RegistrationPolicyException(
            'Doctor self-registration is currently disabled. '
            'Contact your system administrator.',
          );
        }
        if (!_secureCodeMatch(request.inviteCode, expected)) {
          throw const RegistrationPolicyException(
            'Invalid doctor invite code.',
          );
        }

      case 'admin':
        final expected = RegistrationPolicy.adminInviteCode;
        if (expected == null) {
          throw const RegistrationPolicyException(
            'Administrator self-registration is disabled. '
            'Contact your system administrator.',
          );
        }
        if (!_secureCodeMatch(request.inviteCode, expected)) {
          throw const RegistrationPolicyException(
            'Invalid administrator invite code.',
          );
        }
    }
  }

  // ── Uniqueness check ──────────────────────────────────────────────────────

  Future<void> _ensureEmailAvailable(String email) async {
    final existing = await UserDatabaseTable.selectByEmail(email);
    if (existing != null) {
      throw const RegistrationValidationException(
        'An account with this email address already exists.',
      );
    }
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<UserDatabaseModel> _persist(RegisterRequest request) async {
    final now = DateTime.now().toUtc();
    final user = UserDatabaseModel(
      id: _generateUserId(),
      firstName: request.firstName,
      lastName: request.lastName,
      email: request.email,
      phoneNumber: request.phoneNumber,
      dateOfBirth: request.dateOfBirth,
      sex: request.sex,
      licenseNumber: request.licenseNumber,
      licenseIssuer: request.licenseIssuer,
      specialty: request.specialty,
      passwordHash: _passwordService.hashPassword(request.password),
      role: request.role,
      // Patients are auto-activated.  Doctors/admins need no further
      // approval when a valid invite code was supplied — the code itself
      // is the approval mechanism.
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );

    await UserDatabaseTable.insert(user);
    return user;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Constant-time string comparison to prevent timing attacks on invite codes.
  static bool _secureCodeMatch(String? provided, String expected) {
    if (provided == null) return false;
    final a = utf8.encode(provided);
    final b = utf8.encode(expected);
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  static String _generateUserId() {
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
