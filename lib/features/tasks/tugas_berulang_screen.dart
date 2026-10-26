import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class TugasBerulangScreen extends ConsumerStatefulWidget {
  const TugasBerulangScreen({super.key});

  @override
  ConsumerState<TugasBerulangScreen> createState() => _TugasBerulangScreenState();
}

class _TugasBerulangScreenState extends ConsumerState<TugasBerulangScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.simpleRecurringTasksTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.repeatDaily),
            subtitle: Text(l10n.repeatDailySubtitle),
            trailing: const Icon(Icons.repeat),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.repeatWeekly),
            subtitle: Text(l10n.repeatWeeklySubtitle),
            trailing: const Icon(Icons.repeat),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.repeatMonthly),
            subtitle: Text(l10n.repeatMonthlySubtitle),
            trailing: const Icon(Icons.repeat),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
