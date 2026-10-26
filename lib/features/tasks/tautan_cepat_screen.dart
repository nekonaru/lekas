import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../l10n/app_localizations.dart';

class TautanCepatScreen extends ConsumerStatefulWidget {
  const TautanCepatScreen({super.key});

  @override
  ConsumerState<TautanCepatScreen> createState() => _TautanCepatScreenState();
}

class _TautanCepatScreenState extends ConsumerState<TautanCepatScreen> {
  Future<void> _openLink(String host, String title) async {
    // No url_launcher dependency, so the link is handed to the system share
    // sheet where the user can open it in a browser or an app.
    await Share.share('https://$host', subject: title);
  }

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
            onTap: () => _openLink('siakad.kampus.ac.id', l10n.quickLinkSiakad),
          ),
          ListTile(
            title: Text(l10n.quickLinkELearning),
            subtitle: const Text('elearning.kampus.ac.id'),
            trailing: const Icon(Icons.launch),
            onTap: () => _openLink('elearning.kampus.ac.id', l10n.quickLinkELearning),
          ),
          ListTile(
            title: Text(l10n.quickLinkLibrary),
            subtitle: const Text('library.kampus.ac.id'),
            trailing: const Icon(Icons.launch),
            onTap: () => _openLink('library.kampus.ac.id', l10n.quickLinkLibrary),
          ),
        ],
      ),
    );
  }
}
