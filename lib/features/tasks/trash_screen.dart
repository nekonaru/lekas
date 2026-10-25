import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../core/components/undo_snackbar.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);

    return FutureBuilder<List<Task>>(
      future: repo.getTasks(includeInbox: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final deletedTasks = snapshot.data?.where((t) => t.deletedAt != null).toList() ?? [];

        if (deletedTasks.isEmpty) {
          return const Center(child: Text('Sampah kosong.'));
        }

        return ListView.builder(
          itemCount: deletedTasks.length,
          itemBuilder: (context, index) {
            final task = deletedTasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text('Dihapus: ${DateTime.fromMillisecondsSinceEpoch(task.deletedAt!)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restore, color: Colors.green),
                    onPressed: () async {
                      await repo.restoreTask(task.id);
                      if (mounted) setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () async {
                      // Permanent delete
                      await repo.softDeleteTask(task.id); // Already soft deleted, this is a stub for permanent
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
