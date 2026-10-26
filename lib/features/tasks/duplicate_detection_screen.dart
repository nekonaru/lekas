import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class DuplicateDetectionScreen extends ConsumerStatefulWidget {
  const DuplicateDetectionScreen({super.key});

  @override
  ConsumerState<DuplicateDetectionScreen> createState() => _DuplicateDetectionScreenState();
}

class _DuplicateDetectionScreenState extends ConsumerState<DuplicateDetectionScreen> {
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
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
