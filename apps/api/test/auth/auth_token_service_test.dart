import 'package:nhis_api/auth/auth_token_service.dart';
import 'package:nhis_api/users/user_database_model.dart';
import 'package:test/test.dart';

void main() {
  group('AuthTokenService', () {
    final config = AuthTokenConfig(
      jwtSecret: 'test-secret-with-enough-length',
      accessTokenDuration: const Duration(minutes: 15),
      refreshTokenDuration: const Duration(days: 30),
    );
    final user = UserDatabaseModel(
      id: 'user-1',
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      passwordHash: 'password-hash',
      role: 'admin',
      status: 'active',
      facilityId: 'facility-1',
    );

    test('creates and verifies an access token', () {
      final service = AuthTokenService(config: config);
      final tokens = service.createTokenPair(
        user: user,
        sessionId: 'session-1',
        now: DateTime.utc(2026, 1, 1, 10),
      );

      final claims = service.verifyAccessToken(
        tokens.accessToken,
        now: DateTime.utc(2026, 1, 1, 10, 5),
      );

      expect(claims.userId, 'user-1');
      expect(claims.sessionId, 'session-1');
      expect(claims.role, 'admin');
      expect(claims.status, 'active');
      expect(claims.facilityId, 'facility-1');
    });

    test('rejects a tampered access token', () {
      final service = AuthTokenService(config: config);
      final tokens = service.createTokenPair(
        user: user,
        sessionId: 'session-1',
        now: DateTime.utc(2026, 1, 1, 10),
      );
      final tamperedToken =
          '${tokens.accessToken.substring(0, tokens.accessToken.length - 1)}x';

      expect(
        () => service.verifyAccessToken(tamperedToken),
        throwsA(isA<AuthTokenException>()),
      );
    });
  });
}
