import '../users/user_database_model.dart';
import '../users/user_database_table.dart';
import 'auth_token_service.dart';
import 'user_session_database_model.dart';
import 'user_session_database_table.dart';

final class AuthSessionResult {
  const AuthSessionResult({
    required this.user,
    required this.tokens,
    required this.session,
  });

  final UserDatabaseModel user;
  final AuthTokenPair tokens;
  final UserSessionDatabaseModel session;
}

final class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

final class AuthService {
  AuthService({AuthTokenService? tokenService})
    : _tokenService = tokenService ?? AuthTokenService();

  final AuthTokenService _tokenService;

  Future<AuthSessionResult> createSession({
    required UserDatabaseModel user,
    String? deviceId,
    String? ipAddress,
    String? userAgent,
    DateTime? now,
  }) async {
    _ensureUserCanAuthenticate(user);

    final issuedAt = (now ?? DateTime.now()).toUtc();
    final sessionId = _tokenService.createSessionId();
    final tokens = _tokenService.createTokenPair(
      user: user,
      sessionId: sessionId,
      now: issuedAt,
    );
    final session = UserSessionDatabaseModel(
      id: sessionId,
      userId: user.id,
      refreshTokenHash: _tokenService.hashRefreshToken(tokens.refreshToken),
      deviceId: deviceId,
      ipAddress: ipAddress,
      userAgent: userAgent,
      createdAt: issuedAt,
      expiresAt: tokens.refreshTokenExpiresAt,
      lastUsedAt: issuedAt,
    );

    await UserSessionDatabaseTable.insert(session);

    return AuthSessionResult(user: user, tokens: tokens, session: session);
  }

  Future<AuthSessionResult> refreshSession({
    required String refreshToken,
    String? deviceId,
    String? ipAddress,
    String? userAgent,
    DateTime? now,
  }) async {
    final referenceDate = (now ?? DateTime.now()).toUtc();
    final refreshTokenHash = _tokenService.hashRefreshToken(refreshToken);
    final currentSession =
        await UserSessionDatabaseTable.selectByRefreshTokenHash(
          refreshTokenHash,
        );

    if (currentSession == null) {
      throw const AuthException('Refresh token session was not found');
    }

    if (!currentSession.canRefresh(at: referenceDate)) {
      throw const AuthException('Refresh token session is no longer valid');
    }

    await UserSessionDatabaseTable.updateLastUsedAt(
      id: currentSession.id,
      lastUsedAt: referenceDate,
    );

    final user = await UserDatabaseTable.selectById(currentSession.userId);

    if (user == null) {
      throw const AuthException('Refresh token user was not found');
    }

    final nextSession = await createSession(
      user: user,
      deviceId: deviceId ?? currentSession.deviceId,
      ipAddress: ipAddress ?? currentSession.ipAddress,
      userAgent: userAgent ?? currentSession.userAgent,
      now: referenceDate,
    );

    await UserSessionDatabaseTable.revokeById(
      id: currentSession.id,
      revokedAt: referenceDate,
      replacedBySessionId: nextSession.session.id,
    );

    return nextSession;
  }

  Future<void> logout({required String refreshToken, DateTime? now}) async {
    final refreshTokenHash = _tokenService.hashRefreshToken(refreshToken);
    final session = await UserSessionDatabaseTable.selectByRefreshTokenHash(
      refreshTokenHash,
    );

    if (session == null || session.isRevoked) {
      return;
    }

    await UserSessionDatabaseTable.revokeById(
      id: session.id,
      revokedAt: (now ?? DateTime.now()).toUtc(),
    );
  }

  Future<UserDatabaseModel> authenticateAccessToken(String accessToken) async {
    final claims = _tokenService.verifyAccessToken(accessToken);
    final session = await UserSessionDatabaseTable.selectById(claims.sessionId);

    if (session == null || session.isRevoked) {
      throw const AuthException('Access token session is not valid');
    }

    final user = await UserDatabaseTable.selectById(claims.userId);

    if (user == null) {
      throw const AuthException('Access token user was not found');
    }

    _ensureUserCanAuthenticate(user);

    return user;
  }

  void _ensureUserCanAuthenticate(UserDatabaseModel user) {
    if (user.status != 'active') {
      throw const AuthException('User account is not active');
    }
  }
}
