import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// The undo snackbar: one banner at a time, gone after five seconds.
///
/// Two habits used to make it feel stuck: a new banner queued behind the
/// old one instead of replacing it (so the banner stayed on screen for one
/// more full duration), and in this Flutter version a banner with an action
/// never closed on the built-in timer alone. Both are fixed here: the
/// current banner is removed first so the newest undo is always the one on
/// screen, and a five second timer hides it again so the banner always
/// clears, action or not.
class UndoSnackbar {
  static Timer? _closeTimer;

  static void show(BuildContext context, String message, VoidCallback onUndo) {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: onUndo,
        ),
      ),
    );
    // A newer banner cancels this timer, so it can only hide the newest
    // one. Hiding while nothing is shown is a no-op, so a banner closed
    // earlier (undo tap, swipe) is harmless too.
    _closeTimer?.cancel();
    _closeTimer = Timer(
      const Duration(seconds: 5),
      () => messenger.hideCurrentSnackBar(),
    );
  }
}
