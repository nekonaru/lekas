import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class DaftarBawaanScreen extends ConsumerStatefulWidget {
  const DaftarBawaanScreen({super.key});

  @override
  ConsumerState<DaftarBawaanScreen> createState() => _DaftarBawaanScreenState();
}

class _DaftarBawaanScreenState extends ConsumerState<DaftarBawaanScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.defaultChecklistTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.checklistLaptop),
            trailing: Checkbox(value: false, onChanged: (v) {}),
          ),
          ListTile(
            title: Text(l10n.checklistLanCable),
            trailing: Checkbox(value: false, onChanged: (v) {}),
          ),
          ListTile(
            title: Text(l10n.checklistPrintReport),
            trailing: Checkbox(value: false, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }
}
