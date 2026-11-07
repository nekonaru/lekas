import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/lock/sha256.dart';

/// The app lock hashes PINs with SHA-256, so a wrong constant or a broken
/// round shows up as a mismatch here. Vectors are the NIST examples.
void main() {
  test('sha256 of the empty string matches the NIST vector', () {
    expect(
      sha256Hex(utf8.encode('')),
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    );
  });

  test('sha256 of abc matches the NIST vector', () {
    expect(
      sha256Hex(utf8.encode('abc')),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });

  test('sha256 of a 56 byte message matches the NIST vector', () {
    expect(
      sha256Hex(utf8.encode(
          'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq')),
      '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1',
    );
  });

  test('the salt changes the PIN hash and it stays stable', () {
    expect(hashPin('1234', 's1'), hashPin('1234', 's1'));
    expect(hashPin('1234', 's1'), isNot(hashPin('1234', 's2')));
    expect(hashPin('1234', 's1'), isNot(hashPin('0000', 's1')));
  });
}
