import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/core/constants.dart';

/// The version shown in settings must be the release version of the package
/// (rules section 9), so a bump in pubspec.yaml never ships with an old
/// number on screen.
void main() {
  test('appVersion mirrors the pubspec release version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*(\S+)', multiLine: true)
        .firstMatch(pubspec)!
        .group(1)!;
    final release = version.split('+').first;
    expect(appVersion, release,
        reason: 'lib/core/constants.dart appVersion must match pubspec');
  });
}
