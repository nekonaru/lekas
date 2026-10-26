import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class PintasanIkonScreen extends ConsumerStatefulWidget {
  const PintasanIkonScreen({super.key});

  @override
  ConsumerState<PintasanIkonScreen> createState() => _PintasanIkonScreenState();
}

class _PintasanIkonScreenState extends ConsumerState<PintasanIkonScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.iconShortcutsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.appIconShortcut),
            subtitle: Text(l10n.appIconShortcutSubtitle),
            trailing: const Icon(Icons.shortcut),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.quickSettingsTile),
            subtitle: Text(l10n.quickSettingsTileSubtitle),
            trailing: const Icon(Icons.settings),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.optionalPersistentNotification),
            subtitle: Text(l10n.optionalPersistentNotificationSubtitle),
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }
}
