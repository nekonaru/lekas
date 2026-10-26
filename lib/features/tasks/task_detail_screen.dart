import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../core/date_util.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'subtask_screen.dart';
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
                              _badge('Prioritas ${_priorityLabel(task.priority)}'),
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
                                  'Deadline: ${DateUtil.formatDateTime(DateTime.fromMillisecondsSinceEpoch(task.deadline!), locale)}',
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
                                Text('Estimasi: ${task.estimateMinutes} menit'),
                              ],
                            ),
                          ],
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
                            'Subtugas ($doneCount/${subtasks.length})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _addSubtask(context, task.id),
                            child: const Text('Tambah'),
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
                    }).toList(),
                  ],
                  const Divider(),
                  ListTile(
                    title: const Text('Riwayat Deadline'),
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
                    title: const Text('Cara Kumpul'),
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
                    title: const Text('Edit Tugas'),
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
                child: Icon(
                  task.status == 'done' ? Icons.restore : Icons.check,
                ),
                tooltip: task.status == 'done' ? 'Buka kembali' : 'Tandai selesai',
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
    switch (priority) {
      case 0: return 'Rendah';
      case 1: return 'Sedang';
      case 2: return 'Tinggi';
      default: return 'Sedang';
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'todo': return 'Belum';
      case 'doing': return 'Dikerjakan';
      case 'revision': return 'Revisi';
      case 'done': return 'Selesai';
      default: return 'Belum';
    }
  }

  Future<void> _addSubtask(BuildContext context, String taskId) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Subtugas'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Judul subtugas'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              await ref.read(subtaskRepositoryProvider).insertSubtask(Subtask(
                id: const Uuid().v4(),
                taskId: taskId,
                title: controller.text,
                done: false,
                sortOrder: 0,
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              ));
              if (mounted) Navigator.pop(context);
              if (mounted) setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
