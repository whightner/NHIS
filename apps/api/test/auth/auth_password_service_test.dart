import 'package:nhis_api/auth/auth_password_service.dart';
import 'package:test/test.dart';

void main() {
  group('AuthPasswordService', () {
    const service = AuthPasswordService();

    test('verifies a password against its hash', () {
      final hash = service.hashPassword(
        'secret-password',
        iterations: 1000,
        salt: 'c2FsdA',
      );

      expect(
        service.verifyPassword(password: 'secret-password', passwordHash: hash),
        isTrue,
      );
    });

    test('rejects an invalid password', () {
      final hash = service.hashPassword(
        'secret-password',
        iterations: 1000,
        salt: 'c2FsdA',
      );

      expect(
        service.verifyPassword(password: 'wrong-password', passwordHash: hash),
        isFalse,
      );
    });
  });
}
