import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/core/constants.dart';
import 'package:lekas/core/version_checker.dart';

void main() {
  group('normalizeVersion', () {
    test('strips the leading v', () {
      expect(VersionChecker.normalizeVersion('v1.2.3'), '1.2.3');
    });

    test('strips build metadata', () {
      expect(VersionChecker.normalizeVersion('v1.10.0+16'), '1.10.0');
      expect(VersionChecker.normalizeVersion('1.10.0+16'), '1.10.0');
    });

    test('leaves plain versions alone', () {
      expect(VersionChecker.normalizeVersion('2.0.0'), '2.0.0');
    });
  });

  group('compareVersions', () {
    test('numeric, not lexical', () {
      expect(VersionChecker.compareVersions('1.10.0', '1.9.0'), greaterThan(0));
      expect(VersionChecker.compareVersions('1.9.0', '1.10.0'), lessThan(0));
    });

    test('missing parts count as zero', () {
      expect(VersionChecker.compareVersions('1.10', '1.10.0'), 0);
      expect(VersionChecker.compareVersions('1.10.0', '1.10'), 0);
    });

    test('equal versions compare equal', () {
      expect(VersionChecker.compareVersions('2.3.4', '2.3.4'), 0);
    });

    test('accepts tags and build metadata', () {
      expect(VersionChecker.compareVersions('v1.10.1+3', 'v1.10.0+2'), greaterThan(0));
    });

    test('garbage parts fall back to zero instead of throwing', () {
      expect(VersionChecker.compareVersions('1.x.0', '1.0.0'), 0);
    });
  });

  group('parseLatestRelease', () {
    Map<String, dynamic> payload({
      Object? tag = 'v99.0.0',
      List<dynamic>? assets,
      Object? htmlUrl = 'https://github.com/nekonaru/lekas/releases/latest',
    }) {
      return <String, dynamic>{
        'tag_name': tag,
        'html_url': ?htmlUrl,
        'assets': ?assets,
      };
    }

    test('a newer tag means an update is available', () {
      final result = VersionChecker().parseLatestRelease(payload());
      expect(result, isA<UpdateAvailable>());
      expect((result as UpdateAvailable).version, '99.0.0');
    });

    test('an older tag means up to date', () {
      final result =
          VersionChecker().parseLatestRelease(payload(tag: 'v0.1.0'));
      expect(result, isA<UpToDate>());
    });

    test('the installed version itself is up to date', () {
      final result = VersionChecker().parseLatestRelease(
        payload(tag: 'v$appVersion'),
      );
      expect(result, isA<UpToDate>());
    });

    test('a missing tag fails instead of throwing', () {
      expect(
        VersionChecker().parseLatestRelease(payload(tag: null)),
        isA<UpdateCheckFailed>(),
      );
    });

    test('a tag without a v prefix is accepted', () {
      final result =
          VersionChecker().parseLatestRelease(payload(tag: '99.0.0'));
      expect(result, isA<UpdateAvailable>());
    });

    test('the arm64 asset is preferred for the download link', () {
      final result = VersionChecker().parseLatestRelease(payload(
        assets: [
          {
            'name': 'app-armeabi-v7a-release.apk',
            'browser_download_url': 'https://example.com/v7a.apk',
          },
          {
            'name': 'app-arm64-v8a-release.apk',
            'browser_download_url': 'https://example.com/arm64.apk',
          },
        ],
      ));
      expect((result as UpdateAvailable).url, 'https://example.com/arm64.apk');
    });

    test('falls back to the release page when no asset matches', () {
      final result = VersionChecker().parseLatestRelease(payload(
        assets: [
          {
            'name': 'app-armeabi-v7a-release.apk',
            'browser_download_url': 'https://example.com/v7a.apk',
          },
        ],
        htmlUrl: 'https://github.com/nekonaru/lekas/releases/tag/v99.0.0',
      ));
      expect((result as UpdateAvailable).url,
          'https://github.com/nekonaru/lekas/releases/tag/v99.0.0');
    });

    test('falls back to the latest page when the payload is bare', () {
      final result = VersionChecker().parseLatestRelease(
        payload(assets: null, htmlUrl: null),
      );
      expect((result as UpdateAvailable).url,
          'https://github.com/nekonaru/lekas/releases/latest');
    });
  });
}
