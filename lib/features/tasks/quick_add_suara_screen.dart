import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class QuickAddSuaraScreen extends ConsumerStatefulWidget {
  const QuickAddSuaraScreen({super.key});

  @override
  ConsumerState<QuickAddSuaraScreen> createState() => _QuickAddSuaraScreenState();
}

class _QuickAddSuaraScreenState extends ConsumerState<QuickAddSuaraScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.voiceQuickAddTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.voiceQuickAddHint),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              // Not implemented yet: no speech recognition plugin is declared
              // in pubspec.yaml, so recording can not start.
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.featureNotAvailable)),
                );
              },
              icon: const Icon(Icons.mic),
              label: Text(l10n.startRecording),
            ),
          ],
        ),
      ),
    );
  }
}
