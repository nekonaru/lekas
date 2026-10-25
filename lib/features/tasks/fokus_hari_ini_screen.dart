import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class FokusHariIniScreen extends ConsumerStatefulWidget {
  const FokusHariIniScreen({super.key});

  @override
  ConsumerState<FokusHariIniScreen> createState() => _FokusHariIniScreenState();
}

class _FokusHariIniScreenState extends ConsumerState<FokusHariIniScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fokus Hari Ini')),
      body: FutureBuilder<List<Task>>(
        future: repo.getTasks(includeInbox: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data?.where((t) => t.focusDate != null).toList() ?? [];

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return CheckboxListTile(
                title: Text(task.title),
                value: task.status == 'done',
                onChanged: (v) async {
                  await repo.markDone(task.id,
                      completedAt: v == true ? DateTime.now().millisecondsSinceEpoch : null);
                  if (mounted) setState(() {});
                },
                secondary: const Icon(Icons.star, color: Colors.amber),
              );
            },
          );
        },
      ),
    );
  }
}
