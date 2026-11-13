import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'constants.dart';

/// What one update check found on the public GitHub releases page.
sealed class UpdateCheckResult {
  const UpdateCheckResult();
}

/// Installed version is the newest published one.
class UpToDate extends UpdateCheckResult {
  const UpToDate(this.version);

  final String version;
}

/// A newer release exists; [url] prefers the arm64 APK and falls back to
/// the release page, so the link lands on the right download.
class UpdateAvailable extends UpdateCheckResult {
  const UpdateAvailable(this.version, this.url);

  final String version;
  final String url;
}

/// No network, GitHub down, or an unexpected payload; the caller says so.
class UpdateCheckFailed extends UpdateCheckResult {
  const UpdateCheckFailed();
}

/// Checks the public GitHub release list for a version newer than the
/// installed one. Read-only, sends nothing, and the caller can catch any
/// failure as [UpdateCheckFailed]; tests drive the pure parsing and
/// comparison paths directly.
class VersionChecker {
  VersionChecker({HttpClientFactory? clientFactory})
      : _clientFactory = clientFactory ?? _defaultClient;

  static const String _apiUrl =
      'https://api.github.com/repos/nekonaru/lekas/releases/latest';
  static const String _fallbackUrl =
      'https://github.com/nekonaru/lekas/releases/latest';

  static HttpClient _defaultClient() {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    client.idleTimeout = const Duration(seconds: 1);
    return client;
  }

  final HttpClientFactory _clientFactory;

  /// Fetches the latest release tag and compares it against the installed
  /// [appVersion]; every failure mode maps to [UpdateCheckFailed].
  Future<UpdateCheckResult> check() async {
    final client = _clientFactory();
    try {
      final request = await client.getUrl(Uri.parse(_apiUrl));
      request.headers.set(HttpHeaders.userAgentHeader, 'lekas-android');
      request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      final response = await request.close();
      if (response.statusCode != 200) {
        await response.drain();
        return const UpdateCheckFailed();
      }
      final body = await utf8.decoder.bind(response).join();
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        return const UpdateCheckFailed();
      }
      return parseLatestRelease(decoded);
    } catch (_) {
      return const UpdateCheckFailed();
    } finally {
      client.close(force: true);
    }
  }

  /// Reads the release payload; separated from the socket so tests can
  /// drive it directly. Missing or malformed fields collapse into
  /// [UpdateCheckFailed] instead of throwing.
  UpdateCheckResult parseLatestRelease(Map<String, dynamic> json) {
    final tag = json['tag_name'];
    if (tag is! String || tag.trim().isEmpty) {
      return const UpdateCheckFailed();
    }
    final latest = normalizeVersion(tag);
    if (compareVersions(latest, appVersion) <= 0) {
      return UpToDate(latest);
    }
    // The arm64 APK is the right asset for almost every phone; the release
    // page is the honest fallback for anything else.
    String? url;
    final assets = json['assets'];
    if (assets is List) {
      for (final asset in assets) {
        if (asset is Map && asset['name']?.toString().contains('arm64-v8a') == true) {
          final download = asset['browser_download_url'];
          if (download is String && download.isNotEmpty) {
            url = download;
            break;
          }
        }
      }
    }
    final page = json['html_url'];
    url ??= page is String ? page : null;
    if (url == null || !url.startsWith('https://')) {
      url = _fallbackUrl;
    }
    return UpdateAvailable(latest, url);
  }

  /// Strips the leading `v` and any `+build` suffix from a release tag.
  static String normalizeVersion(String tag) {
    var version = tag.trim();
    if (version.startsWith('v')) version = version.substring(1);
    final plus = version.indexOf('+');
    if (plus >= 0) version = version.substring(0, plus);
    return version;
  }

  /// Numeric comparison of dot separated versions; a missing part counts
  /// as 0, so 1.10 beats 1.9 and 1.10.0 equals 1.10.
  static int compareVersions(String a, String b) {
    final left = normalizeVersion(a).split('.');
    final right = normalizeVersion(b).split('.');
    final length = left.length > right.length ? left.length : right.length;
    for (var i = 0; i < length; i++) {
      final l = int.tryParse(i < left.length ? left[i] : '0') ?? 0;
      final r = int.tryParse(i < right.length ? right[i] : '0') ?? 0;
      if (l != r) return l.compareTo(r);
    }
    return 0;
  }
}

/// Builds the HTTP client (injectable for tests).
typedef HttpClientFactory = HttpClient Function();
