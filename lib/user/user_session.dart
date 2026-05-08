import 'user_model.dart';

class UserSession {
  const UserSession({
    required this.user,
    required this.accessToken,
    required this.expiresAt,
    required this.createdAt,
    this.refreshToken,
    this.refreshExpiresAt,
    this.lastActivityAt,
  });

  final UserModel user;
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final DateTime? refreshExpiresAt;
  final DateTime createdAt;
  final DateTime? lastActivityAt;

  bool get hasAccessToken => accessToken.trim().isNotEmpty;

  bool get hasRefreshToken {
    return refreshToken != null && refreshToken!.trim().isNotEmpty;
  }

  bool isExpired({DateTime? at}) {
    final referenceDate = at ?? DateTime.now();
    return !expiresAt.isAfter(referenceDate);
  }

  bool canRefresh({DateTime? at}) {
    if (!hasRefreshToken) {
      return false;
    }

    if (refreshExpiresAt == null) {
      return true;
    }

    final referenceDate = at ?? DateTime.now();
    return refreshExpiresAt!.isAfter(referenceDate);
  }

  bool isAuthenticated({DateTime? at}) {
    return user.isActive && hasAccessToken && !isExpired(at: at);
  }

  UserSession copyWith({
    UserModel? user,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    DateTime? refreshExpiresAt,
    DateTime? createdAt,
    DateTime? lastActivityAt,
  }) {
    return UserSession(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      refreshExpiresAt: refreshExpiresAt ?? this.refreshExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: _parseRequiredDateTime(json['expires_at']),
      refreshExpiresAt: _parseDateTime(json['refresh_expires_at']),
      createdAt: _parseRequiredDateTime(json['created_at']),
      lastActivityAt: _parseDateTime(json['last_activity_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
      'refresh_expires_at': refreshExpiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'last_activity_at': lastActivityAt?.toIso8601String(),
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
