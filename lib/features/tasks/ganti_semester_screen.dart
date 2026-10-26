import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

class GantiSemesterScreen extends ConsumerStatefulWidget {
  const GantiSemesterScreen({super.key});

  @override
  ConsumerState<GantiSemesterScreen> createState() => _GantiSemesterScreenState();
}

class _GantiSemesterScreenState extends ConsumerState<GantiSemesterScreen> {
  final _periodController = TextEditingController();

  /// One of 'archive', 'move' or 'delete'. Null means nothing chosen yet.
  String? _unfinishedOption;

  @override
  void dispose() {
    _periodController.dispose();
    super.dispose();
  }

  /// Applies the chosen option to every task that is not done yet and returns
  /// how many tasks were touched.
  Future<int> _applyUnfinishedOption(String newSpaceId) async {
    final option = _unfinishedOption;
    if (option == null || option == 'archive') return 0;
    final taskRepo = ref.read(taskRepositoryProvider);
    final tasks = await taskRepo.getTasks(includeInbox: true);
    final unfinished = tasks.where((t) => t.status != 'done').toList();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final task in unfinished) {
      if (option == 'move') {
        await taskRepo.updateTask(
          task.copyWith(spaceId: Value(newSpaceId), updatedAt: now),
        );
      } else {
        await taskRepo.softDeleteTask(task.id);
      }
    }
    return unfinished.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changeSemesterTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.newSemester,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _periodController,
              decoration: InputDecoration(
                labelText: l10n.semesterPeriodExample,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.unfinishedTasksOptionsLabel,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              title: Text(l10n.keepInArchive),
              leading: const Icon(Icons.archive),
              trailing: _unfinishedOption == 'archive'
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () => setState(() => _unfinishedOption = 'archive'),
            ),
            ListTile(
              title: Text(l10n.moveToNewSpace),
              leading: const Icon(Icons.folder_copy),
              trailing: _unfinishedOption == 'move'
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () => setState(() => _unfinishedOption = 'move'),
            ),
            ListTile(
              title: Text(l10n.deleteLabel),
              leading: const Icon(Icons.delete, color: Colors.red),
              trailing: _unfinishedOption == 'delete'
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () => setState(() => _unfinishedOption = 'delete'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(spaceRepositoryProvider);
                final period = _periodController.text.isEmpty
                    ? l10n.newSemester
                    : _periodController.text;
                final now = DateTime.now().millisecondsSinceEpoch;
                final newSpace = Space(
                  id: const Uuid().v4(),
                  name: period,
                  period: period,
                  color: AppTheme.containerColors[0].toARGB32(),
                  kind: 'course',
                  archived: false,
                  createdAt: now,
                  updatedAt: now,
                );
                await repo.insertSpace(newSpace);
                final affected = await _applyUnfinishedOption(newSpace.id);
                if (!context.mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                if (affected > 0) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.tasksProcessed(affected))),
                  );
                }
              },
              child: Text(l10n.createNewSemester),
            ),
          ],
        ),
      ),
    );
  }
}
