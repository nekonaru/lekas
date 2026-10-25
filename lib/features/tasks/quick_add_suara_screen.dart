import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      appBar: AppBar(title: const Text('Quick Add Suara')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Tekan mikrofon untuk berbicara tugas'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mic),
              label: const Text('Mulai Rekaman'),
            ),
          ],
        ),
      ),
    );
  }
}
