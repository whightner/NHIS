import 'registration_models.dart';

/// Static validation helpers for authentication inputs.
/// Every method either returns the sanitised value or throws
/// [RegistrationValidationException].
final class AuthValidator {
  const AuthValidator._();

  static const _minPasswordLength = 8;
  static const _maxFieldLength = 255;

  // ── Password ──────────────────────────────────────────────────────────────

  /// Enforces strong password policy:
  /// min 8 chars · uppercase · lowercase · digit · special char.
  static void validatePassword(String password) {
    if (password.length < _minPasswordLength) {
      throw RegistrationValidationException(
        'Password must be at least $_minPasswordLength characters long.',
      );
    }
    if (password.length > 128) {
      throw const RegistrationValidationException(
        'Password must not exceed 128 characters.',
      );
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      throw const RegistrationValidationException(
        'Password must contain at least one uppercase letter.',
      );
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      throw const RegistrationValidationException(
        'Password must contain at least one lowercase letter.',
      );
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      throw const RegistrationValidationException(
        'Password must contain at least one number.',
      );
    }
    if (!password.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{};:,.<>?/\\|`~]'))) {
      throw const RegistrationValidationException(
        'Password must contain at least one special character.',
      );
    }
  }

  // ── Email ─────────────────────────────────────────────────────────────────

  /// Validates and returns a normalised (trimmed, lowercased) email.
  static String validateAndNormalizeEmail(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    if (value.isEmpty) {
      throw const RegistrationValidationException('Email is required.');
    }
    if (value.length > _maxFieldLength) {
      throw const RegistrationValidationException('Email is too long.');
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      throw const RegistrationValidationException('Invalid email address.');
    }
    return value;
  }

  // ── Generic fields ────────────────────────────────────────────────────────

  /// Returns trimmed value or throws if blank.
  static String validateRequiredField(String? raw, String fieldName) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      throw RegistrationValidationException('$fieldName is required.');
    }
    if (value.length > _maxFieldLength) {
      throw RegistrationValidationException('$fieldName is too long.');
    }
    return value;
  }

  /// Returns trimmed value or null if blank.
  static String? validateOptionalField(String? raw, [int? maxLen]) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    final limit = maxLen ?? _maxFieldLength;
    if (value.length > limit) {
      throw RegistrationValidationException(
        'Field value exceeds $limit characters.',
      );
    }
    return value;
  }

  // ── Date of birth ─────────────────────────────────────────────────────────

  static DateTime validateDateOfBirth(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      throw const RegistrationValidationException('Date of birth is required.');
    }
    final DateTime dob;
    try {
      dob = DateTime.parse(value);
    } on FormatException {
      throw const RegistrationValidationException(
        'Invalid date of birth format. Use YYYY-MM-DD.',
      );
    }
    final now = DateTime.now();
    if (dob.isAfter(now)) {
      throw const RegistrationValidationException(
        'Date of birth cannot be in the future.',
      );
    }
    final ageYears = now.difference(dob).inDays ~/ 365;
    if (ageYears > 150) {
      throw const RegistrationValidationException('Invalid date of birth.');
    }
    return dob;
  }

  // ── Sex ───────────────────────────────────────────────────────────────────

  static const _validSexValues = {
    'male',
    'female',
    'other',
    'prefer_not_to_say',
  };

  static String validateSex(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    if (!_validSexValues.contains(value)) {
      throw RegistrationValidationException(
        'Sex must be one of: ${_validSexValues.join(', ')}.',
      );
    }
    return value;
  }

  // ── Role ──────────────────────────────────────────────────────────────────

  static const _registrableRoles = {'patient', 'doctor', 'admin'};

  static String validateRole(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    if (!_registrableRoles.contains(value)) {
      throw RegistrationValidationException(
        'Role must be one of: ${_registrableRoles.join(', ')}.',
      );
    }
    return value;
  }

  // ── Phone number ──────────────────────────────────────────────────────────

  static String? validatePhoneNumber(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
      throw const RegistrationValidationException(
        'Invalid phone number. Use digits only, optionally prefixed with +.',
      );
    }
    return value;
  }

  // ── License number ────────────────────────────────────────────────────────

  static String validateLicenseNumber(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      throw const RegistrationValidationException(
        'License number is required for doctor registration.',
      );
    }
    if (value.length > 100) {
      throw const RegistrationValidationException(
        'License number is too long.',
      );
    }
    return value;
  }
}
