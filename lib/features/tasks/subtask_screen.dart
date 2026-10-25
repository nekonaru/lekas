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
      appBar: AppBar(title: const Text('Subtugas')),
      body: FutureBuilder<List<Subtask>>(
        future: repo.getSubtasks(widget.taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final subtasks = snapshot.data ?? [];

          if (subtasks.isEmpty) {
            return const Center(child: Text('Belum ada subtugas.'));
          }

          return ListView.builder(
            itemCount: subtasks.length,
            itemBuilder: (context, index) {
              final subtask = subtasks[index];
              return CheckboxListTile(
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
                            title: const Text('Edit Subtugas'),
                            content: TextField(
                              controller: _titleController,
                              autofocus: true,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await repo.updateSubtask(subtask.copyWith(
                                    title: _titleController.text,
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
          await repo.insertSubtask(Subtask(
            id: const Uuid().v4(),
            taskId: widget.taskId,
            title: _titleController.text,
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
