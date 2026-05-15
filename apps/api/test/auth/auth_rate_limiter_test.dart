import 'package:nhis_api/auth/auth_rate_limiter.dart';
import 'package:test/test.dart';

void main() {
  group('AuthRateLimiter', () {
    test('allows requests below the max', () {
      final limiter = AuthRateLimiter(maxAttempts: 3, window: const Duration(minutes: 1));
      expect(limiter.isAllowed('127.0.0.1'), isTrue);
      limiter.record('127.0.0.1');
      limiter.record('127.0.0.1');
      expect(limiter.isAllowed('127.0.0.1'), isTrue);
    });

    test('blocks after max attempts reached', () {
      final limiter = AuthRateLimiter(maxAttempts: 2, window: const Duration(minutes: 1));
      limiter.record('10.0.0.1');
      limiter.record('10.0.0.1');
      expect(limiter.isAllowed('10.0.0.1'), isFalse);
    });

    test('different keys are independent', () {
      final limiter = AuthRateLimiter(maxAttempts: 1, window: const Duration(minutes: 1));
      limiter.record('192.168.1.1');
      expect(limiter.isAllowed('192.168.1.2'), isTrue);
    });

    test('retryAfterSeconds returns 0 when under limit', () {
      final limiter = AuthRateLimiter(maxAttempts: 5, window: const Duration(minutes: 1));
      expect(limiter.retryAfterSeconds('key'), equals(0));
    });
  });
}
