import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class TugasBerulangScreen extends ConsumerStatefulWidget {
  const TugasBerulangScreen({super.key});

  @override
  ConsumerState<TugasBerulangScreen> createState() => _TugasBerulangScreenState();
}

class _TugasBerulangScreenState extends ConsumerState<TugasBerulangScreen> {
  Future<void> _createRepeating(String repeatKind, String title) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.taskTitle,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    final text = controller.text.trim();
    controller.dispose();
    if (confirmed != true || text.isEmpty || !mounted) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await ref.read(taskRepositoryProvider).insertTask(Task(
          id: const Uuid().v4(),
          title: text,
          priority: 1,
          status: 'todo',
          isGroup: false,
          pinned: false,
          inbox: false,
          repeatKind: repeatKind,
          repeatEvery: 1,
          createdAt: now,
          updatedAt: now,
        ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savedTasksCount(1))),
    );
  }

  Future<void> _createWeekdayRepeating() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final days = <int>{DateTime.now().weekday};
    final locale = Localizations.localeOf(context).toString();
    // A known Monday, so DateTime.weekday maps to the localized short name.
    final monday = DateTime(2026, 11, 23);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.repeatWeekdays),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.taskTitle,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: [
                    for (var weekday = 1; weekday <= 7; weekday++)
                      ChoiceChip(
                        label: Text(
                          DateFormat.E(locale).format(
                            monday.add(Duration(days: weekday - 1)),
                          ),
                        ),
                        selected: days.contains(weekday),
                        onSelected: (selected) => setDialogState(() {
                          if (selected) {
                            days.add(weekday);
                          } else {
                            days.remove(weekday);
                          }
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
    final text = controller.text.trim();
    controller.dispose();
    if (confirmed != true || text.isEmpty || days.isEmpty || !mounted) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await ref.read(taskRepositoryProvider).insertTask(Task(
          id: const Uuid().v4(),
          title: text,
          priority: 1,
          status: 'todo',
          isGroup: false,
          pinned: false,
          inbox: false,
          repeatKind: 'weekdays',
          repeatEvery: 1,
          repeatDays: (days.toList()..sort()).join(','),
          createdAt: now,
          updatedAt: now,
        ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savedTasksCount(1))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.simpleRecurringTasksTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.recurringTasksExplainer,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: Text(l10n.repeatDaily),
            subtitle: Text(l10n.repeatDailySubtitle),
            trailing: const Icon(Icons.repeat),
            onTap: () => _createRepeating('daily', l10n.repeatDaily),
          ),
          ListTile(
            title: Text(l10n.repeatWeekly),
            subtitle: Text(l10n.repeatWeeklySubtitle),
            trailing: const Icon(Icons.repeat),
            onTap: () => _createRepeating('weekly', l10n.repeatWeekly),
          ),
          ListTile(
            title: Text(l10n.repeatMonthly),
            subtitle: Text(l10n.repeatMonthlySubtitle),
            trailing: const Icon(Icons.repeat),
            onTap: () => _createRepeating('monthly', l10n.repeatMonthly),
          ),
          ListTile(
            title: Text(l10n.repeatWeekdays),
            subtitle: Text(l10n.repeatWeekdaysSubtitle),
            trailing: const Icon(Icons.repeat),
            onTap: _createWeekdayRepeating,
          ),
        ],
      ),
    );
  }
}
