import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';

class DeadlineHistoryScreen extends ConsumerStatefulWidget {
  final String taskId;
  const DeadlineHistoryScreen({super.key, required this.taskId});

  @override
  ConsumerState<DeadlineHistoryScreen> createState() => _DeadlineHistoryScreenState();
}

class _DeadlineHistoryScreenState extends ConsumerState<DeadlineHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(taskEventRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Deadline')),
      body: FutureBuilder<List<TaskEvent>>(
        future: repo.getTaskEvents(widget.taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data?.where((e) => e.kind == 'deadline_changed').toList() ?? [];

          if (events.isEmpty) {
            return const Center(child: Text('Belum ada riwayat perubahan deadline.'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text('${event.oldValue ?? '-'} → ${event.newValue ?? '-'}'),
                subtitle: Text(
                  '${DateUtil.formatDateTime(DateTime.fromMillisecondsSinceEpoch(event.createdAt), locale)}\n${event.note ?? ''}',
                ),
                trailing: const Icon(Icons.access_time),
              );
            },
          );
        },
      ),
    );
  }
}
