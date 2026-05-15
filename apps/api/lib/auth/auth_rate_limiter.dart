/// Simple in-memory rate limiter keyed by arbitrary string (e.g. IP address).
///
/// This is intentionally a stateful singleton-compatible object so it can be
/// shared across request handlers without a database.  In production, swap to
/// a Redis-backed implementation by implementing the same interface.
///
/// Sliding-window strategy: attempts older than [window] are discarded on each
/// check, so limits reset naturally over time without a cron job.
final class AuthRateLimiter {
  AuthRateLimiter({
    int maxAttempts = 10,
    Duration window = const Duration(minutes: 15),
  }) : _maxAttempts = maxAttempts,
       _window = window;

  final int _maxAttempts;
  final Duration _window;

  // key → list of attempt timestamps (UTC)
  final Map<String, List<DateTime>> _log = {};

  /// Returns `true` if the key is within the allowed rate.
  bool isAllowed(String key) {
    _evict(key);
    return (_log[key]?.length ?? 0) < _maxAttempts;
  }

  /// Records one attempt for the given key.
  void record(String key) {
    _evict(key);
    (_log[key] ??= []).add(DateTime.now().toUtc());
  }

  /// Returns the seconds until the oldest attempt in the window expires,
  /// or 0 if the key is within the allowed rate.
  int retryAfterSeconds(String key) {
    final attempts = _log[key];
    if (attempts == null || attempts.isEmpty) return 0;
    final oldest = attempts.first;
    final elapsed = DateTime.now().toUtc().difference(oldest);
    final remaining = _window - elapsed;
    return remaining.isNegative ? 0 : remaining.inSeconds;
  }

  void _evict(String key) {
    final attempts = _log[key];
    if (attempts == null) return;
    final cutoff = DateTime.now().toUtc().subtract(_window);
    attempts.removeWhere((t) => t.isBefore(cutoff));
    if (attempts.isEmpty) _log.remove(key);
  }
}
