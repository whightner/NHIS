import 'user_session.dart';

final class SessionController {
  SessionController._();

  static final instance = SessionController._();

  UserSession? _session;

  UserSession? get session => _session;

  bool get hasValidSession {
    final currentSession = _session;
    return currentSession != null && currentSession.isAuthenticated();
  }

  void save(UserSession session) {
    _session = session;
  }

  void clear() {
    _session = null;
  }
}
