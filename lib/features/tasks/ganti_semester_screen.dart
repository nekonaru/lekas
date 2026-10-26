import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void dispose() {
    _periodController.dispose();
    super.dispose();
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
              onTap: () {},
            ),
            ListTile(
              title: Text(l10n.moveToNewSpace),
              leading: const Icon(Icons.folder_copy),
              onTap: () {},
            ),
            ListTile(
              title: Text(l10n.deleteLabel),
              leading: const Icon(Icons.delete, color: Colors.red),
              onTap: () {},
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(spaceRepositoryProvider);
                final period = _periodController.text.isEmpty
                    ? l10n.newSemester
                    : _periodController.text;
                await repo.insertSpace(Space(
                  id: const Uuid().v4(),
                  name: period,
                  period: period,
                  color: AppTheme.containerColors[0].toARGB32(),
                  kind: 'course',
                  archived: false,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                ));
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: Text(l10n.createNewSemester),
            ),
          ],
        ),
      ),
    );
  }
}
