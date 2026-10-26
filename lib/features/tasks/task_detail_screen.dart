import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/date_util.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'deadline_history_screen.dart';
import 'submission_screen.dart';
import 'task_form_sheet.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(taskRepositoryProvider);
    final subtaskRepo = ref.watch(subtaskRepositoryProvider);

    return FutureBuilder<Task>(
      future: repo.getTask(widget.taskId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final task = snapshot.data!;

        return FutureBuilder<List<Subtask>>(
          future: subtaskRepo.getSubtasks(widget.taskId),
          builder: (context, subtaskSnapshot) {
            if (subtaskSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final subtasks = subtaskSnapshot.data ?? [];
            final doneCount = subtasks.where((s) => s.done).length;

            return Scaffold(
              appBar: AppBar(title: Text(task.title)),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          if (task.notes != null && task.notes!.isNotEmpty)
                            Text(task.notes!),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _badge(task.type ?? '-'),
                              const SizedBox(width: 8),
                              _badge(
                                l10n.priorityBadgeLabel(_priorityLabel(task.priority)),
                              ),
                              const SizedBox(width: 8),
                              _badge(_statusLabel(task.status)),
                            ],
                          ),
                          if (task.deadline != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.deadlineAtLabel(
                                    DateUtil.formatDateTime(
                                      DateTime.fromMillisecondsSinceEpoch(task.deadline!),
                                      locale,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (task.estimateMinutes != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.timer, size: 16),
                                const SizedBox(width: 8),
                                Text(l10n.estimateMinutesLabel(task.estimateMinutes!)),
                              ],
                            ),
                          ],
                          FutureBuilder<List<Tag>>(
                            future:
                                ref.read(tagRepositoryProvider).tagsForTask(task.id),
                            builder: (context, tagSnapshot) {
                              final tags = tagSnapshot.data ?? const <Tag>[];
                              if (tags.isEmpty) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    for (final tag in tags)
                                      Chip(
                                        label: Text('#${tag.name}'),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (subtasks.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            l10n.subtaskProgressLabel(doneCount, subtasks.length),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _addSubtask(context, task.id),
                            child: Text(l10n.addLabel),
                          ),
                        ],
                      ),
                    ),
                    LinearProgressIndicator(
                      value: subtasks.isEmpty ? 0 : doneCount / subtasks.length,
                    ),
                    ...subtasks.map((subtask) {
                      return CheckboxListTile(
                        title: Text(subtask.title),
                        value: subtask.done,
                        onChanged: (v) async {
                          await subtaskRepo.toggleSubtask(subtask.id, v ?? false);
                          if (mounted) setState(() {});
                        },
                        secondary: const Icon(Icons.check_box),
                      );
                    }),
                  ],
                  const Divider(),
                  ListTile(
                    title: Text(l10n.deadlineHistoryTitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeadlineHistoryScreen(taskId: task.id),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(l10n.submissionMethodTitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubmissionScreen(taskId: task.id),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy),
                    title: Text(l10n.duplicateTask),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _duplicate(task),
                  ),
                  ListTile(
                    leading: const Icon(Icons.save_alt),
                    title: Text(l10n.saveAsTemplate),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _saveAsTemplate(task, subtasks),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.push_pin),
                    title: Text(l10n.pinTaskLabel),
                    value: task.pinned,
                    onChanged: (value) async {
                      await repo.setPinned(task.id, value);
                      if (mounted) setState(() {});
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.label_outline),
                    title: Text(l10n.tagsLabel),
                    subtitle: Text(l10n.tagsHint),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _editTags(task),
                  ),
                  ListTile(
                    title: Text(l10n.editTask),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => TaskFormSheet(task: task),
                      );
                    },
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  final status = task.status == 'done' ? 'todo' : 'done';
                  repo.markDone(widget.taskId,
                      completedAt: status == 'done'
                          ? DateTime.now().millisecondsSinceEpoch
                          : null);
                  Navigator.pop(context);
                },
                tooltip: task.status == 'done' ? l10n.reopenTooltip : l10n.markDoneTooltip,
                child: Icon(
                  task.status == 'done' ? Icons.restore : Icons.check,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  String _priorityLabel(int priority) {
    final l10n = AppLocalizations.of(context)!;
    switch (priority) {
      case 0: return l10n.priorityLow;
      case 1: return l10n.priorityMedium;
      case 2: return l10n.priorityHigh;
      default: return l10n.priorityMedium;
    }
  }

  String _statusLabel(String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'todo': return l10n.statusTodo;
      case 'doing': return l10n.statusDoing;
      case 'revision': return l10n.statusRevision;
      case 'done': return l10n.done;
      default: return l10n.statusTodo;
    }
  }

  /// Design section 5.9: duplicating a weekly lab report takes one tap.
  Future<void> _duplicate(Task task) async {
    final copy =
        await ref.read(taskRepositoryProvider).duplicateTask(task.id);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.duplicatedToast)));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: copy.id)),
    );
  }

  /// Design section 5.9: keep the shape of this task, name and subtasks,
  /// so the next weekly report starts pre filled.
  Future<void> _saveAsTemplate(Task task, List<Subtask> subtasks) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: task.title);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.saveAsTemplate),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.templateNameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (saved != true || controller.text.isEmpty || !mounted) return;
    await ref.read(taskTemplateRepositoryProvider).saveFromTask(
          task,
          controller.text,
          [for (final subtask in subtasks) subtask.title],
        );
    controller.dispose();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.templateSavedToast)));
  }

  /// Design section 5.9: free tags, edited as a comma separated list.
  Future<void> _editTags(Task task) async {
    final repo = ref.read(tagRepositoryProvider);
    final current = await repo.tagsForTask(task.id);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: current.map((tag) => tag.name).join(', '),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editTagsTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.tagsHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (saved != true || !mounted) return;
    final names = [
      for (final part in controller.text.split(',')) part.trim(),
    ];
    await repo.setTaskTags(task.id, names);
    controller.dispose();
    if (mounted) setState(() {});
  }

  Future<void> _addSubtask(BuildContext context, String taskId) async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addSubtaskTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.subtaskTitleHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              final navigator = Navigator.of(context);
              await ref.read(subtaskRepositoryProvider).insertSubtask(Subtask(
                id: const Uuid().v4(),
                taskId: taskId,
                title: controller.text,
                done: false,
                sortOrder: 0,
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
  }
}
