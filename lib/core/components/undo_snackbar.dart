import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class UndoSnackbar {
  static void show(BuildContext context, String message, VoidCallback onUndo) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
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
  }
}
