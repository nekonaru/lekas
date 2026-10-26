import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class TautanCepatScreen extends ConsumerStatefulWidget {
  const TautanCepatScreen({super.key});

  @override
  ConsumerState<TautanCepatScreen> createState() => _TautanCepatScreenState();
}

class _TautanCepatScreenState extends ConsumerState<TautanCepatScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.globalQuickLinksTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.quickLinkSiakad),
            subtitle: const Text('siakad.kampus.ac.id'),
            trailing: const Icon(Icons.launch),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.quickLinkELearning),
            subtitle: const Text('elearning.kampus.ac.id'),
            trailing: const Icon(Icons.launch),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.quickLinkLibrary),
            subtitle: const Text('library.kampus.ac.id'),
            trailing: const Icon(Icons.launch),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
