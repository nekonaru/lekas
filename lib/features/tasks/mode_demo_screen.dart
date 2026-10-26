import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class ModeDemoScreen extends ConsumerStatefulWidget {
  const ModeDemoScreen({super.key});

  @override
  ConsumerState<ModeDemoScreen> createState() => _ModeDemoScreenState();
}

class _ModeDemoScreenState extends ConsumerState<ModeDemoScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.demoModeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.trySampleData),
            subtitle: Text(l10n.trySampleDataSubtitle),
            trailing: const Icon(Icons.description),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.deleteSampleData),
            subtitle: Text(l10n.deleteSampleDataSubtitle),
            trailing: const Icon(Icons.delete),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
