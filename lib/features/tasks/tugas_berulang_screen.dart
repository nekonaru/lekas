import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
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
          inbox: true,
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
        ],
      ),
    );
  }
}
