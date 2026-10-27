import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/focus.dart';
import '../../l10n/app_localizations.dart';

/// Picks up to three focus tasks for today and checks them off
/// (design section 5.24). The list follows the database, so a pick from
/// the morning notification appears at once.
class FokusHariIniScreen extends ConsumerStatefulWidget {
  const FokusHariIniScreen({super.key});

  @override
  ConsumerState<FokusHariIniScreen> createState() =>
      _FokusHariIniScreenState();
}

class _FokusHariIniScreenState extends ConsumerState<FokusHariIniScreen> {
  /// Deadlines sort first, tasks without one last.
  static const int _noDeadline = 9223372036854775807;

  Future<void> _openPicker() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (sheetContext, scrollController) => StreamBuilder<List<Task>>(
          stream:
              ref.read(taskRepositoryProvider).watchTasks(includeInbox: true),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? const <Task>[];
            final now = DateTime.now();
            final focused = {
              for (final task in tasks)
                if (isFocusOnDay(task.focusDate, now)) task.id,
            };
            final candidates = tasks
                .where((task) =>
                    task.status != 'done' && !focused.contains(task.id))
                .toList()
              ..sort((a, b) =>
                  (a.deadline ?? _noDeadline).compareTo(b.deadline ?? _noDeadline));
            return ListView.builder(
              controller: scrollController,
              itemCount: candidates.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: Text(
                      l10n.pickFocusLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }
                final task = candidates[index - 1];
                return ListTile(
                  leading: const Icon(Icons.star_outline),
                  title: Text(task.title),
                  trailing: const Icon(Icons.add),
                  onTap: () => _pick(task),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Adds one task to today's focus, refusing once three are picked
  /// (design section 5.24).
  Future<void> _pick(Task task) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(taskRepositoryProvider);
    final now = DateTime.now();
    final tasks = await repo.getTasks(includeInbox: true);
    final picked = tasks.where((t) => isFocusOnDay(t.focusDate, now)).length;
    if (!focusHasRoom(picked)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.focusLimitToast)));
      return;
    }
    await repo.setFocusDate(task.id, startOfDayMs(now));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.todayFocusTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPicker,
        icon: const Icon(Icons.add),
        label: Text(l10n.pickFocusLabel),
      ),
      body: StreamBuilder<List<Task>>(
        stream: repo.watchTasks(includeInbox: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final now = DateTime.now();
          final focus = (snapshot.data ?? const <Task>[])
              .where((task) => isFocusOnDay(task.focusDate, now))
              .toList()
            ..sort((a, b) =>
                (a.deadline ?? _noDeadline).compareTo(b.deadline ?? _noDeadline));
          if (focus.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.focusEmpty, textAlign: TextAlign.center),
              ),
            );
          }

          // The small celebration of design section 5.24, no badge or score.
          final doneFlags = [for (final task in focus) task.status == 'done'];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (focusAllDone(doneFlags))
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.focusAllDoneMsg)),
                  ],
                ),
              for (final task in focus)
                CheckboxListTile(
                  title: Text(task.title),
                  value: task.status == 'done',
                  secondary: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.focusRemoveTooltip,
                    onPressed: () =>
                        repo.setFocusDate(task.id, null),
                  ),
                  onChanged: (value) async {
                    if (value == true) {
                      await repo.markDone(
                        task.id,
                        completedAt: DateTime.now().millisecondsSinceEpoch,
                      );
                    } else {
                      await repo.reopenTask(task.id);
                    }
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
