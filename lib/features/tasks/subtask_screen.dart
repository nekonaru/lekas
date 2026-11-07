import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class SubtaskScreen extends ConsumerStatefulWidget {
  final String taskId;
  const SubtaskScreen({super.key, required this.taskId});

  @override
  ConsumerState<SubtaskScreen> createState() => _SubtaskScreenState();
}

class _SubtaskScreenState extends ConsumerState<SubtaskScreen> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(subtaskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.subtasksTitle)),
      body: FutureBuilder<List<Subtask>>(
        future: repo.getSubtasks(widget.taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final subtasks = snapshot.data ?? [];

          if (subtasks.isEmpty) {
            return Center(child: Text(l10n.noSubtasksYet));
          }

          return ReorderableListView.builder(
            itemCount: subtasks.length,
            onReorderItem: (oldIndex, newIndex) async {
              setState(() {
                final moved = subtasks.removeAt(oldIndex);
                subtasks.insert(newIndex, moved);
              });
              // Persist the drop position as an explicit sort order so the
              // list reopens in the same sequence.
              for (var i = 0; i < subtasks.length; i++) {
                await repo.updateSubtask(subtasks[i].copyWith(sortOrder: i));
              }
            },
            itemBuilder: (context, index) {
              final subtask = subtasks[index];
              return CheckboxListTile(
                key: ValueKey('subtask:${subtask.id}'),
                title: Text(subtask.title),
                value: subtask.done,
                onChanged: (v) async {
                  await repo.toggleSubtask(subtask.id, v ?? false);
                  if (mounted) setState(() {});
                },
                secondary: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () async {
                        _titleController.text = subtask.title;
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(l10n.editSubtaskTitle),
                            content: TextField(
                              controller: _titleController,
                              autofocus: true,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final navigator = Navigator.of(context);
                                  await repo.updateSubtask(subtask.copyWith(
                                    title: _titleController.text,
                                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                                  ));
                                  navigator.pop();
                                  if (mounted) setState(() {});
                                },
                                child: Text(l10n.save),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () async {
                        await repo.deleteSubtask(subtask.id);
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_titleController.text.isEmpty) return;
          // New rows append after the last one the list shows instead of
          // all starting at zero and scrambling the order.
          final existing = await ref
              .read(subtaskRepositoryProvider)
              .getSubtasks(widget.taskId);
          await repo.insertSubtask(Subtask(
            id: const Uuid().v4(),
            taskId: widget.taskId,
            title: _titleController.text,
            done: false,
            sortOrder: existing.length,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ));
          _titleController.clear();
          if (mounted) setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
