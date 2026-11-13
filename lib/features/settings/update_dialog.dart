import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

/// The dialog shown when a newer release exists: it names the version and
/// hands off to the https link (the arm64 APK when present, the release
/// page otherwise), opened through the same platform channel family the
/// app already uses for system screens.
Future<void> showUpdateAvailableDialog(
  BuildContext context, {
  required String version,
  required String url,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.updateAvailableTitle),
      content: Text(l10n.updateAvailableBody(version)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.updateLater),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            openUpdateUrl(url);
          },
          child: Text(l10n.updateDownload),
        ),
      ],
    ),
  );
}

/// Opens [url] in the system browser; the channel refuses non-https links,
/// so a crafted string stays inert.
Future<void> openUpdateUrl(String url) async {
  try {
    await const MethodChannel('lekas/platform')
        .invokeMethod<void>('openUrl', url);
  } on MissingPluginException {
    // Platform channel absent (e.g. in widget tests): stay quiet.
  } on PlatformException {
    // The browser could not be opened; the link is also visible in the dialog.
  }
}
