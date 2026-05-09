import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../users/user_database_model.dart';

final class AuthTokenConfig {
  const AuthTokenConfig({
    required this.jwtSecret,
    this.issuer = 'nhis-api',
    this.audience = 'nhis-mobile',
    this.accessTokenDuration = const Duration(minutes: 15),
    this.refreshTokenDuration = const Duration(days: 30),
  });

  final String jwtSecret;
  final String issuer;
  final String audience;
  final Duration accessTokenDuration;
  final Duration refreshTokenDuration;

  factory AuthTokenConfig.fromEnvironment([Map<String, String>? environment]) {
    final env = environment ?? Platform.environment;

    return AuthTokenConfig(
      jwtSecret: _requiredEnvironment(env, 'NHIS_JWT_SECRET'),
      issuer: env['NHIS_JWT_ISSUER'] ?? 'nhis-api',
      audience: env['NHIS_JWT_AUDIENCE'] ?? 'nhis-mobile',
      accessTokenDuration: Duration(
        minutes: int.parse(env['NHIS_ACCESS_TOKEN_MINUTES'] ?? '15'),
      ),
      refreshTokenDuration: Duration(
        days: int.parse(env['NHIS_REFRESH_TOKEN_DAYS'] ?? '30'),
      ),
    );
  }

  static String _requiredEnvironment(
    Map<String, String> environment,
    String name,
  ) {
    final value = environment[name];

    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing required environment variable: $name');
    }

    return value;
  }
}

final class AuthTokenPair {
  const AuthTokenPair({
    required this.sessionId,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  final String sessionId;
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;
}

final class AuthTokenClaims {
  const AuthTokenClaims({
    required this.userId,
    required this.sessionId,
    required this.role,
    required this.status,
    required this.issuer,
    required this.audience,
    required this.jwtId,
    required this.issuedAt,
    required this.expiresAt,
    this.facilityId,
    this.organizationId,
    this.patientId,
  });

  final String userId;
  final String sessionId;
  final String role;
  final String status;
  final String issuer;
  final String audience;
  final String jwtId;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String? facilityId;
  final String? organizationId;
  final String? patientId;

  factory AuthTokenClaims.fromPayload(Map<String, dynamic> payload) {
    return AuthTokenClaims(
      userId: payload['sub'] as String,
      sessionId: payload['sid'] as String,
      role: payload['role'] as String,
      status: payload['status'] as String,
      issuer: payload['iss'] as String,
      audience: payload['aud'] as String,
      jwtId: payload['jti'] as String,
      issuedAt: _fromUnixSeconds(payload['iat'] as int),
      expiresAt: _fromUnixSeconds(payload['exp'] as int),
      facilityId: payload['facility_id'] as String?,
      organizationId: payload['organization_id'] as String?,
      patientId: payload['patient_id'] as String?,
    );
  }

  static DateTime _fromUnixSeconds(int seconds) {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }
}

final class AuthTokenException implements Exception {
  const AuthTokenException(this.message);

  final String message;

  @override
  String toString() => 'AuthTokenException: $message';
}

final class AuthTokenService {
  AuthTokenService({AuthTokenConfig? config})
    : _config = config ?? AuthTokenConfig.fromEnvironment();

  final AuthTokenConfig _config;
  final Random _random = Random.secure();

  AuthTokenPair createTokenPair({
    required UserDatabaseModel user,
    required String sessionId,
    DateTime? now,
  }) {
    final issuedAt = (now ?? DateTime.now()).toUtc();
    final accessTokenExpiresAt = issuedAt.add(_config.accessTokenDuration);
    final refreshTokenExpiresAt = issuedAt.add(_config.refreshTokenDuration);

    return AuthTokenPair(
      sessionId: sessionId,
      accessToken: _createAccessToken(
        user: user,
        sessionId: sessionId,
        issuedAt: issuedAt,
        expiresAt: accessTokenExpiresAt,
      ),
      refreshToken: generateSecureToken(byteLength: 64),
      accessTokenExpiresAt: accessTokenExpiresAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt,
    );
  }

  String createSessionId() {
    return generateSecureToken(byteLength: 24);
  }

  String hashRefreshToken(String refreshToken) {
    return sha256.convert(utf8.encode(refreshToken)).toString();
  }

  AuthTokenClaims verifyAccessToken(String token, {DateTime? now}) {
    final parts = token.split('.');

    if (parts.length != 3) {
      throw const AuthTokenException('Invalid access token format');
    }

    final signature = _sign('${parts[0]}.${parts[1]}');
    final actualSignature = _base64UrlDecode(parts[2]);

    if (!_constantTimeEquals(signature, actualSignature)) {
      throw const AuthTokenException('Invalid access token signature');
    }

    final header = _decodeJsonPart(parts[0]);

    if (header['alg'] != 'HS256' || header['typ'] != 'JWT') {
      throw const AuthTokenException('Unsupported access token header');
    }

    final payload = _decodeJsonPart(parts[1]);
    final claims = AuthTokenClaims.fromPayload(payload);
    final referenceDate = (now ?? DateTime.now()).toUtc();

    if (!claims.expiresAt.isAfter(referenceDate)) {
      throw const AuthTokenException('Access token has expired');
    }

    if (claims.issuer != _config.issuer) {
      throw const AuthTokenException('Invalid access token issuer');
    }

    if (claims.audience != _config.audience) {
      throw const AuthTokenException('Invalid access token audience');
    }

    return claims;
  }

  String generateSecureToken({int byteLength = 32}) {
    final bytes = List<int>.generate(byteLength, (_) => _random.nextInt(256));
    return _base64UrlEncode(bytes);
  }

  String _createAccessToken({
    required UserDatabaseModel user,
    required String sessionId,
    required DateTime issuedAt,
    required DateTime expiresAt,
  }) {
    final header = {'alg': 'HS256', 'typ': 'JWT'};
    final payload = <String, dynamic>{
      'sub': user.id,
      'sid': sessionId,
      'role': user.role,
      'status': user.status,
      'iss': _config.issuer,
      'aud': _config.audience,
      'iat': _toUnixSeconds(issuedAt),
      'exp': _toUnixSeconds(expiresAt),
      'jti': generateSecureToken(byteLength: 16),
      if (user.facilityId != null) 'facility_id': user.facilityId,
      if (user.organizationId != null) 'organization_id': user.organizationId,
      if (user.patientId != null) 'patient_id': user.patientId,
    };

    final encodedHeader = _base64UrlEncode(utf8.encode(jsonEncode(header)));
    final encodedPayload = _base64UrlEncode(utf8.encode(jsonEncode(payload)));
    final signingInput = '$encodedHeader.$encodedPayload';
    final encodedSignature = _base64UrlEncode(_sign(signingInput));

    return '$signingInput.$encodedSignature';
  }

  List<int> _sign(String input) {
    final hmac = Hmac(sha256, utf8.encode(_config.jwtSecret));
    return hmac.convert(utf8.encode(input)).bytes;
  }

  static Map<String, dynamic> _decodeJsonPart(String part) {
    final Object? value;

    try {
      final decoded = utf8.decode(_base64UrlDecode(part));
      value = jsonDecode(decoded);
    } on FormatException {
      throw const AuthTokenException('Invalid access token encoding');
    }

    if (value is! Map<String, dynamic>) {
      throw const AuthTokenException('Invalid JSON token part');
    }

    return value;
  }

  static String _base64UrlEncode(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static List<int> _base64UrlDecode(String value) {
    try {
      return base64Url.decode(base64Url.normalize(value));
    } on FormatException {
      throw const AuthTokenException('Invalid access token encoding');
    }
  }

  static int _toUnixSeconds(DateTime value) {
    return value.toUtc().millisecondsSinceEpoch ~/ 1000;
  }

  static bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) {
      return false;
    }

    var result = 0;

    for (var index = 0; index < left.length; index++) {
      result |= left[index] ^ right[index];
    }

    return result == 0;
  }
}
