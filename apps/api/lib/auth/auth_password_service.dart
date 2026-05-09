import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

final class AuthPasswordService {
  const AuthPasswordService();

  static const algorithm = 'pbkdf2_sha256';
  static const defaultIterations = 120000;
  static const saltByteLength = 16;
  static const keyByteLength = 32;

  String hashPassword(
    String password, {
    int iterations = defaultIterations,
    String? salt,
  }) {
    final resolvedSalt = salt ?? _generateSalt();
    final passwordBytes = utf8.encode(password);
    final saltBytes = _base64UrlDecode(resolvedSalt);
    final key = _pbkdf2(
      passwordBytes: passwordBytes,
      saltBytes: saltBytes,
      iterations: iterations,
      keyLength: keyByteLength,
    );

    return '$algorithm\$$iterations\$$resolvedSalt\$${_base64UrlEncode(key)}';
  }

  bool verifyPassword({
    required String password,
    required String passwordHash,
  }) {
    final parts = passwordHash.split(r'$');

    if (parts.length != 4 || parts.first != algorithm) {
      return false;
    }

    final iterations = int.tryParse(parts[1]);

    if (iterations == null || iterations <= 0) {
      return false;
    }

    final expectedHash = hashPassword(
      password,
      iterations: iterations,
      salt: parts[2],
    );

    return _constantTimeEquals(
      utf8.encode(expectedHash),
      utf8.encode(passwordHash),
    );
  }

  static List<int> _pbkdf2({
    required List<int> passwordBytes,
    required List<int> saltBytes,
    required int iterations,
    required int keyLength,
  }) {
    final hmac = Hmac(sha256, passwordBytes);
    final hashLength = sha256.convert(const <int>[]).bytes.length;
    final blockCount = (keyLength + hashLength - 1) ~/ hashLength;
    final derivedKey = <int>[];

    for (var blockIndex = 1; blockIndex <= blockCount; blockIndex++) {
      var block =
          hmac.convert([...saltBytes, ..._int32Bytes(blockIndex)]).bytes;
      final output = List<int>.from(block);

      for (var iteration = 1; iteration < iterations; iteration++) {
        block = hmac.convert(block).bytes;

        for (var index = 0; index < output.length; index++) {
          output[index] ^= block[index];
        }
      }

      derivedKey.addAll(output);
    }

    return derivedKey.take(keyLength).toList(growable: false);
  }

  static List<int> _int32Bytes(int value) {
    return [
      (value >> 24) & 0xff,
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
      value & 0xff,
    ];
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(
      saltByteLength,
      (_) => random.nextInt(256),
    );

    return _base64UrlEncode(bytes);
  }

  static String _base64UrlEncode(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static List<int> _base64UrlDecode(String value) {
    return base64Url.decode(base64Url.normalize(value));
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
