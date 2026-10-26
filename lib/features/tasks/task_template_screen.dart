import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../data/task_template_repository.dart' show decodeSubtaskTitles;
import '../../l10n/app_localizations.dart';
import 'task_detail_screen.dart';

/// Lists the saved task templates and starts a new task from one
/// (design section 5.9).
class TaskTemplateScreen extends ConsumerWidget {
  const TaskTemplateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskTemplateRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taskTemplatesTitle)),
      body: StreamBuilder<List<TaskTemplate>>(
        stream: repo.watchTaskTemplates(),
        builder: (context, snapshot) {
          final templates = snapshot.data ?? const <TaskTemplate>[];
          if (templates.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.emptyTemplates, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              final subtasks = decodeSubtaskTitles(template.subtasksJson);
              final minutes = template.estimateMinutes;
              return ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(template.name),
                subtitle: Text(
                  minutes != null
                      ? l10n.templateSummary(subtasks.length, minutes)
                      : l10n.templateSubtaskCount(subtasks.length),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.deleteLabel,
                  onPressed: () => _confirmDelete(context, ref, template),
                ),
                onTap: () => _useTemplate(context, ref, template),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _useTemplate(
    BuildContext context,
    WidgetRef ref,
    TaskTemplate template,
  ) async {
    final task = await ref
        .read(taskRepositoryProvider)
        .createFromTemplate(template);
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.templateUsedToast)));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TaskTemplate template,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteLabel),
        content: Text(template.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(taskTemplateRepositoryProvider).deleteTaskTemplate(template.id);
  }
}
