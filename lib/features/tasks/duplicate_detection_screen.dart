import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'task_detail_screen.dart';

/// Lowercased title with punctuation removed, used to spot lookalikes.
String _normalizeTitle(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();

class DuplicateDetectionScreen extends ConsumerStatefulWidget {
  const DuplicateDetectionScreen({super.key});

  @override
  ConsumerState<DuplicateDetectionScreen> createState() => _DuplicateDetectionScreenState();
}

class _DuplicateDetectionScreenState extends ConsumerState<DuplicateDetectionScreen> {
  /// Shows every other task whose normalized title matches, or says that
  /// this task has no twin yet (design section 7.9).
  void _showDuplicates(Task task, List<Task> tasks) {
    final l10n = AppLocalizations.of(context)!;
    final needle = _normalizeTitle(task.title);
    final matches = tasks
        .where((other) =>
            other.id != task.id && _normalizeTitle(other.title) == needle)
        .toList();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(task.title),
        content: matches.isEmpty
            ? Text(l10n.noDuplicateFound)
            : SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final match in matches)
                      ListTile(
                        title: Text(match.title),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  TaskDetailScreen(taskId: match.id),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.duplicateDetectionTitle)),
      body: FutureBuilder<List<Task>>(
        future: repo.getTasks(includeInbox: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data ?? [];
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(l10n.duplicateDetectionItemSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDuplicates(task, tasks),
              );
            },
          );
        },
      ),
    );
  }
}
