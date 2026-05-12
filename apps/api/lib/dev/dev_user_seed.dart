import 'dart:io';

import '../auth/auth_password_service.dart';
import '../users/user_database_model.dart';
import '../users/user_database_table.dart';

final class DevUserSeed {
  const DevUserSeed({
    AuthPasswordService passwordService = const AuthPasswordService(),
  }) : _passwordService = passwordService;

  static const email = 'admin@nhis.local';
  static const password = 'Admin123!';

  final AuthPasswordService _passwordService;

  Future<void> run() async {
    if (!_enabled) {
      return;
    }

    final existingUser = await UserDatabaseTable.selectByEmail(email);

    if (existingUser != null) {
      return;
    }

    final now = DateTime.now().toUtc();
    await UserDatabaseTable.insert(
      UserDatabaseModel(
        id: 'dev-admin',
        firstName: 'NHIS',
        lastName: 'Admin',
        email: email,
        passwordHash: _passwordService.hashPassword(password),
        role: 'admin',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  bool get _enabled {
    final value = Platform.environment['NHIS_SEED_DEV_USER'];

    if (value == null || value.trim().isEmpty) {
      return true;
    }

    return value.trim().toLowerCase() != 'false';
  }
}
