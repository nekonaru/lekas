import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: l10n.quickAddHint,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => Navigator.pop(context),
      ),
    );
  }
}
