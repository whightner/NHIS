import 'dart:io';

import '../http/json_http.dart';
import '../users/user_database_model.dart';
import 'auth_rate_limiter.dart';
import 'auth_registration_service.dart';
import 'auth_service.dart';
import 'auth_token_service.dart';
import 'registration_models.dart';

final class AuthApi {
  AuthApi({
    AuthService? authService,
    AuthRegistrationService? registrationService,
    AuthRateLimiter? loginLimiter,
    AuthRateLimiter? registerLimiter,
  }) : _authService = authService ?? AuthService(),
       _registrationService =
           registrationService ?? AuthRegistrationService(),
       _loginLimiter = loginLimiter ?? AuthRateLimiter(maxAttempts: 10),
       _registerLimiter = registerLimiter ?? AuthRateLimiter(maxAttempts: 5);

  final AuthService _authService;
  final AuthRegistrationService _registrationService;
  final AuthRateLimiter _loginLimiter;
  final AuthRateLimiter _registerLimiter;

  Future<bool> handle(HttpRequest request) async {
    final path = _normalizedPath(request.uri.path);

    if (!path.startsWith('/auth')) {
      return false;
    }

    try {
      switch ((request.method, path)) {
        case ('POST', '/auth/register'):
          await _register(request);
        case ('POST', '/auth/login'):
          await _login(request);
        case ('POST', '/auth/refresh'):
          await _refresh(request);
        case ('POST', '/auth/logout'):
          await _logout(request);
        case ('GET', '/auth/me'):
          await _me(request);
        default:
          await writeJson(
            request.response,
            statusCode: HttpStatus.notFound,
            body: {'message': 'Auth route not found'},
          );
      }
    } on ApiRequestException catch (error) {
      await writeJson(
        request.response,
        statusCode: error.statusCode,
        body: {'message': error.message},
      );
    } on AuthException catch (error) {
      await writeJson(
        request.response,
        statusCode: HttpStatus.unauthorized,
        body: {'message': error.message},
      );
    } on AuthTokenException catch (error) {
      await writeJson(
        request.response,
        statusCode: HttpStatus.unauthorized,
        body: {'message': error.message},
      );
    } on RegistrationValidationException catch (error) {
      await writeJson(
        request.response,
        statusCode: HttpStatus.unprocessableEntity,
        body: {'message': error.message},
      );
    } on RegistrationPolicyException catch (error) {
      await writeJson(
        request.response,
        statusCode: HttpStatus.forbidden,
        body: {'message': error.message},
      );
    }

    return true;
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _register(HttpRequest request) async {
    final ip = _remoteIp(request);

    if (!_registerLimiter.isAllowed(ip)) {
      await writeJson(
        request.response,
        statusCode: HttpStatus.tooManyRequests,
        body: {
          'message': 'Too many registration attempts. Try again later.',
          'retry_after': _registerLimiter.retryAfterSeconds(ip),
        },
      );
      return;
    }
    _registerLimiter.record(ip);

    final body = await readJsonObject(request);
    final user = await _registrationService.register(body);

    await writeJson(
      request.response,
      statusCode: HttpStatus.created,
      body: {
        'message': 'Account created successfully.',
        'user': _userToJson(user),
      },
    );
  }

  Future<void> _login(HttpRequest request) async {
    final ip = _remoteIp(request);

    if (!_loginLimiter.isAllowed(ip)) {
      await writeJson(
        request.response,
        statusCode: HttpStatus.tooManyRequests,
        body: {
          'message': 'Too many login attempts. Try again later.',
          'retry_after': _loginLimiter.retryAfterSeconds(ip),
        },
      );
      return;
    }
    _loginLimiter.record(ip);

    final body = await readJsonObject(request);
    final result = await _authService.login(
      email: readRequiredString(body, 'email'),
      password: readRequiredString(body, 'password'),
      deviceId: readOptionalString(body, 'device_id'),
      ipAddress: request.connectionInfo?.remoteAddress.address,
      userAgent: request.headers.value(HttpHeaders.userAgentHeader),
    );

    await writeJson(
      request.response,
      statusCode: HttpStatus.ok,
      body: _sessionToJson(result),
    );
  }

  Future<void> _refresh(HttpRequest request) async {
    final body = await readJsonObject(request);
    final result = await _authService.refreshSession(
      refreshToken: readRequiredString(body, 'refresh_token'),
      deviceId: readOptionalString(body, 'device_id'),
      ipAddress: request.connectionInfo?.remoteAddress.address,
      userAgent: request.headers.value(HttpHeaders.userAgentHeader),
    );

    await writeJson(
      request.response,
      statusCode: HttpStatus.ok,
      body: _sessionToJson(result),
    );
  }

  Future<void> _logout(HttpRequest request) async {
    final body = await readJsonObject(request);
    await _authService.logout(
      refreshToken: readRequiredString(body, 'refresh_token'),
    );

    await writeJson(
      request.response,
      statusCode: HttpStatus.ok,
      body: {'message': 'Logged out'},
    );
  }

  Future<void> _me(HttpRequest request) async {
    final user = await _authService.authenticateAccessToken(
      readBearerToken(request),
    );

    await writeJson(
      request.response,
      statusCode: HttpStatus.ok,
      body: {'user': _userToJson(user)},
    );
  }

  // ── Serialisation helpers ─────────────────────────────────────────────────

  static Map<String, dynamic> _sessionToJson(AuthSessionResult result) {
    return {
      'user': _userToJson(result.user),
      'access_token': result.tokens.accessToken,
      'refresh_token': result.tokens.refreshToken,
      'expires_at': result.tokens.accessTokenExpiresAt.toIso8601String(),
      'refresh_expires_at':
          result.tokens.refreshTokenExpiresAt.toIso8601String(),
      'created_at': result.session.createdAt.toIso8601String(),
      'last_activity_at': result.session.lastUsedAt?.toIso8601String(),
    };
  }

  static Map<String, dynamic> _userToJson(UserDatabaseModel user) {
    return {
      'id': user.id,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'email': user.email,
      'phone_number': user.phoneNumber,
      'role': user.role,
      'status': user.status,
      'specialty': user.specialty,
      'facility_id': user.facilityId,
      'organization_id': user.organizationId,
      'patient_id': user.patientId,
      'created_at': user.createdAt?.toIso8601String(),
      'updated_at': user.updatedAt?.toIso8601String(),
      'last_login_at': user.lastLoginAt?.toIso8601String(),
    };
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  static String _remoteIp(HttpRequest request) {
    return request.connectionInfo?.remoteAddress.address ?? 'unknown';
  }

  static String _normalizedPath(String path) {
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }
}