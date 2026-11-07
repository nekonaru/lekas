import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/components/empty_state.dart';
import '../../core/components/motion.dart';
import '../../l10n/app_localizations.dart';
import '../tasks/task_detail_screen.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);

    return FutureBuilder<List<Task>>(
      future: repo.getTasks(includeInbox: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final tasks = snapshot.data?.where((t) => t.inbox).toList() ?? [];

        if (tasks.isEmpty) {
          return EmptyState(message: l10n.emptyInboxNote, icon: Icons.inbox);
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return FadeSlideIn(
              index: index,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.notes ?? l10n.noNotesLabel),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(taskId: task.id),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
