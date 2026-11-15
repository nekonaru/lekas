import 'package:flutter/services.dart';

/// Opens an https link in the system browser via the platform channel.
/// The channel refuses non-https links, so a crafted string stays inert.
Future<void> openExternalLink(String url) async {
  try {
    await const MethodChannel('lekas/platform')
        .invokeMethod<void>('openUrl', url);
  } on MissingPluginException {
    // Channel absent (e.g. in widget tests): stay quiet.
  } on PlatformException {
    // The browser could not be opened.
  }
}
