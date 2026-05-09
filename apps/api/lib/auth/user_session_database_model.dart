final class UserSessionDatabaseModel {
  const UserSessionDatabaseModel({
    required this.id,
    required this.userId,
    required this.refreshTokenHash,
    required this.createdAt,
    required this.expiresAt,
    this.deviceId,
    this.ipAddress,
    this.userAgent,
    this.lastUsedAt,
    this.revokedAt,
    this.replacedBySessionId,
  });

  static const tableName = 'user_sessions';

  static const idColumn = 'id';
  static const userIdColumn = 'user_id';
  static const refreshTokenHashColumn = 'refresh_token_hash';
  static const deviceIdColumn = 'device_id';
  static const ipAddressColumn = 'ip_address';
  static const userAgentColumn = 'user_agent';
  static const createdAtColumn = 'created_at';
  static const expiresAtColumn = 'expires_at';
  static const lastUsedAtColumn = 'last_used_at';
  static const revokedAtColumn = 'revoked_at';
  static const replacedBySessionIdColumn = 'replaced_by_session_id';

  final String id;
  final String userId;
  final String refreshTokenHash;
  final String? deviceId;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? lastUsedAt;
  final DateTime? revokedAt;
  final String? replacedBySessionId;

  bool get isRevoked => revokedAt != null;

  bool isExpired({DateTime? at}) {
    final referenceDate = (at ?? DateTime.now()).toUtc();
    return !expiresAt.toUtc().isAfter(referenceDate);
  }

  bool canRefresh({DateTime? at}) {
    return !isRevoked && !isExpired(at: at);
  }

  factory UserSessionDatabaseModel.fromRow(Map<String, dynamic> row) {
    return UserSessionDatabaseModel(
      id: row[idColumn] as String,
      userId: row[userIdColumn] as String,
      refreshTokenHash: row[refreshTokenHashColumn] as String,
      deviceId: row[deviceIdColumn] as String?,
      ipAddress: row[ipAddressColumn] as String?,
      userAgent: row[userAgentColumn] as String?,
      createdAt: _parseRequiredDateTime(row[createdAtColumn]),
      expiresAt: _parseRequiredDateTime(row[expiresAtColumn]),
      lastUsedAt: _parseDateTime(row[lastUsedAtColumn]),
      revokedAt: _parseDateTime(row[revokedAtColumn]),
      replacedBySessionId: row[replacedBySessionIdColumn] as String?,
    );
  }

  Map<String, dynamic> toRow() {
    return {
      idColumn: id,
      userIdColumn: userId,
      refreshTokenHashColumn: refreshTokenHash,
      deviceIdColumn: deviceId,
      ipAddressColumn: ipAddress,
      userAgentColumn: userAgent,
      createdAtColumn: createdAt.toUtc(),
      expiresAtColumn: expiresAt.toUtc(),
      lastUsedAtColumn: lastUsedAt?.toUtc(),
      revokedAtColumn: revokedAt?.toUtc(),
      replacedBySessionIdColumn: replacedBySessionId,
    };
  }

  static DateTime _parseRequiredDateTime(Object? value) {
    final parsedValue = _parseDateTime(value);

    if (parsedValue == null) {
      throw ArgumentError.value(value, 'value', 'Expected a valid date time');
    }

    return parsedValue;
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.parse(value as String);
  }
}
