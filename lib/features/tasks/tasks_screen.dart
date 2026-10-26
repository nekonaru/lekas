import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'task_detail_screen.dart';
import 'task_form_sheet.dart';

/// Every task in one list, sorted by deadline (design section 4.3).
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taskListTitle)),
      body: StreamBuilder<List<Task>>(
        stream: repository.watchTasks(includeInbox: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = (snapshot.data ?? <Task>[])
            ..sort((a, b) => (a.deadline ?? 1 << 62)
                .compareTo(b.deadline ?? 1 << 62));
          if (tasks.isEmpty) {
            return Center(child: Text(l10n.emptyTaskList));
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final done = task.status == 'done';
              return ListTile(
                leading: IconButton(
                  icon: Icon(
                    done
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked_outlined,
                    color: done ? Theme.of(context).colorScheme.primary : null,
                  ),
                  tooltip: l10n.markLabel,
                  onPressed: () async {
                    final repo = ref.read(taskRepositoryProvider);
                    if (done) {
                      await repo.updateTask(task.copyWith(
                        status: 'todo',
                        completedAt: const Value(null),
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      ));
                    } else {
                      await repo.markDone(task.id);
                    }
                  },
                ),
                title: Text(
                  task.title,
                  style: done
                      ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                        )
                      : null,
                ),
                subtitle: task.deadline == null
                    ? null
                    : Text(DateTime.fromMillisecondsSinceEpoch(task.deadline!)
                        .toLocal()
                        .toString()
                        .split('T')
                        .first),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => TaskDetailScreen(taskId: task.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const TaskFormSheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
