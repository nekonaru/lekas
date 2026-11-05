import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Adds and removes the prerequisites of one task (design section 5.27):
/// the list shows what has to finish first, the picker adds another
/// prerequisite, and a save that would close a loop is refused.
class DependensiTugasScreen extends ConsumerStatefulWidget {
  final String taskId;
  const DependensiTugasScreen({super.key, required this.taskId});

  @override
  ConsumerState<DependensiTugasScreen> createState() =>
      _DependensiTugasScreenState();
}

class _DependensiTugasScreenState extends ConsumerState<DependensiTugasScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final depRepo = ref.watch(taskDepRepositoryProvider);
    final taskRepo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taskDependenciesTitle)),
      body: StreamBuilder<List<TaskDep>>(
        stream: depRepo.watchTaskDeps(widget.taskId),
        builder: (context, depSnapshot) {
          if (depSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final deps = depSnapshot.data ?? const <TaskDep>[];

          return StreamBuilder<List<Task>>(
            stream: taskRepo.watchTasks(includeInbox: true),
            builder: (context, taskSnapshot) {
              if (taskSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final byId = {
                for (final task in taskSnapshot.data ?? const <Task>[])
                  task.id: task,
              };

              if (deps.isEmpty) {
                return Center(child: Text(l10n.noDependenciesYet));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    l10n.taskDependenciesBody,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  for (final dep in deps)
                    ListTile(
                      // A finished prerequisite no longer holds the task
                      // back, so it is shown as done instead of removed.
                      leading: Icon(
                        byId[dep.dependsOn]?.status == 'done'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(
                        byId[dep.dependsOn]?.title ?? l10n.recordNotFound,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: l10n.deleteLabel,
                        onPressed: () =>
                            depRepo.deleteTaskDep(widget.taskId, dep.dependsOn),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addPrerequisiteLabel,
        onPressed: () => _openPicker(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PrerequisitePicker(taskId: widget.taskId),
    );
  }
}

/// One search field over every other task: tapping a row saves the edge,
/// and a save that would close a loop reports the reason right here
/// instead of closing the sheet (design section 5.27).
class _PrerequisitePicker extends ConsumerStatefulWidget {
  const _PrerequisitePicker({required this.taskId});

  final String taskId;

  @override
  ConsumerState<_PrerequisitePicker> createState() =>
      _PrerequisitePickerState();
}

class _PrerequisitePickerState extends ConsumerState<_PrerequisitePicker> {
  String _query = '';
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final depRepo = ref.watch(taskDepRepositoryProvider);
    final taskRepo = ref.watch(taskRepositoryProvider);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.addPrerequisiteLabel,
                hintText: l10n.searchTaskLabel,
                prefixIcon: const Icon(Icons.search),
                errorText: _error,
              ),
              onChanged: (value) => setState(() {
                _query = value.trim().toLowerCase();
                _error = null;
              }),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TaskDep>>(
              stream: depRepo.watchTaskDeps(widget.taskId),
              builder: (context, depSnapshot) {
                if (depSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final taken = {
                  for (final dep in depSnapshot.data ?? const <TaskDep>[])
                    dep.dependsOn,
                };
                return StreamBuilder<List<Task>>(
                  stream: taskRepo.watchTasks(includeInbox: true),
                  builder: (context, taskSnapshot) {
                    if (taskSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final candidates = (taskSnapshot.data ?? const <Task>[])
                        .where((task) =>
                            task.id != widget.taskId &&
                            !taken.contains(task.id) &&
                            task.status != 'done' &&
                            (_query.isEmpty ||
                                task.title.toLowerCase().contains(_query)))
                        .toList();
                    if (candidates.isEmpty) {
                      return Center(
                        child: Text(_query.isEmpty
                            ? l10n.noOtherTasks
                            : l10n.recordNotFound),
                      );
                    }
                    return ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final task = candidates[index];
                        return ListTile(
                          title: Text(task.title),
                          onTap: () => _add(task),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add(Task task) async {
    final depRepo = ref.read(taskDepRepositoryProvider);
    final added = await depRepo.insertTaskDep(TaskDep(
      taskId: widget.taskId,
      dependsOn: task.id,
    ));
    if (!mounted) return;
    if (!added) {
      setState(() => _error = AppLocalizations.of(context)!.dependencyCycleError);
      return;
    }
    Navigator.pop(context);
  }
}
