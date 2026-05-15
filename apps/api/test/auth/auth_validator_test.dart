import 'package:nhis_api/auth/auth_validator.dart';
import 'package:nhis_api/auth/registration_models.dart';
import 'package:test/test.dart';

void main() {
  group('AuthValidator', () {
    // ── Email ────────────────────────────────────────────────────────────
    group('validateAndNormalizeEmail', () {
      test('accepts a valid email and normalises to lowercase', () {
        expect(
          AuthValidator.validateAndNormalizeEmail('User@Example.COM'),
          equals('user@example.com'),
        );
      });

      test('throws on empty email', () {
        expect(
          () => AuthValidator.validateAndNormalizeEmail(''),
          throwsA(isA<RegistrationValidationException>()),
        );
      });

      test('throws on email without @', () {
        expect(
          () => AuthValidator.validateAndNormalizeEmail('notanemail'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });

      test('throws on email without domain', () {
        expect(
          () => AuthValidator.validateAndNormalizeEmail('user@'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });
    });

    // ── Password ─────────────────────────────────────────────────────────
    group('validatePassword', () {
      test('accepts a password meeting all requirements', () {
        expect(
          () => AuthValidator.validatePassword('Str0ng@Pass!'),
          returnsNormally,
        );
      });

      test('throws when password is too short', () {
        expect(
          () => AuthValidator.validatePassword('Sh0rt!'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });

      test('throws when no uppercase letter', () {
        expect(
          () => AuthValidator.validatePassword('no_upper123!'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });

      test('throws when no lowercase letter', () {
        expect(
          () => AuthValidator.validatePassword('NO_LOWER123!'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });

      test('throws when no digit', () {
        expect(
          () => AuthValidator.validatePassword('NoDigits!Pass'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });

      test('throws when no special character', () {
        expect(
          () => AuthValidator.validatePassword('NoSpecial123'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });
    });

    // ── Sex ──────────────────────────────────────────────────────────────
    group('validateSex', () {
      for (final valid in ['male', 'female', 'other', 'prefer_not_to_say']) {
        test('accepts "$valid"', () {
          expect(AuthValidator.validateSex(valid), equals(valid));
        });
      }

      test('normalises to lowercase', () {
        expect(AuthValidator.validateSex('MALE'), equals('male'));
      });

      test('throws on unknown value', () {
        expect(
          () => AuthValidator.validateSex('unknown'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });
    });

    // ── Role ─────────────────────────────────────────────────────────────
    group('validateRole', () {
      for (final role in ['patient', 'doctor', 'admin']) {
        test('accepts "$role"', () {
          expect(AuthValidator.validateRole(role), equals(role));
        });
      }

      test('throws on unlisted role', () {
        expect(
          () => AuthValidator.validateRole('nurse'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });
    });

    // ── Date of birth ─────────────────────────────────────────────────────
    group('validateDateOfBirth', () {
      test('accepts a valid past date', () {
        expect(
          () => AuthValidator.validateDateOfBirth('1990-06-15'),
          returnsNormally,
        );
      });

      test('throws on future date', () {
        expect(
          () => AuthValidator.validateDateOfBirth('2099-01-01'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });

      test('throws on invalid format', () {
        expect(
          () => AuthValidator.validateDateOfBirth('15/06/1990'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });

      test('throws on empty value', () {
        expect(
          () => AuthValidator.validateDateOfBirth(''),
          throwsA(isA<RegistrationValidationException>()),
        );
      });
    });

    // ── Phone ─────────────────────────────────────────────────────────────
    group('validatePhoneNumber', () {
      test('returns null for empty input (optional)', () {
        expect(AuthValidator.validatePhoneNumber(''), isNull);
        expect(AuthValidator.validatePhoneNumber(null), isNull);
      });

      test('accepts E.164 style number', () {
        expect(AuthValidator.validatePhoneNumber('+237612345678'), isNotNull);
      });

      test('throws on letters in phone', () {
        expect(
          () => AuthValidator.validatePhoneNumber('123abc'),
          throwsA(isA<RegistrationValidationException>()),
        );
      });
    });
  });
}
