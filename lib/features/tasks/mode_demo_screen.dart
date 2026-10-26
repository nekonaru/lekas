import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class ModeDemoScreen extends ConsumerStatefulWidget {
  const ModeDemoScreen({super.key});

  @override
  ConsumerState<ModeDemoScreen> createState() => _ModeDemoScreenState();
}

class _ModeDemoScreenState extends ConsumerState<ModeDemoScreen> {
  /// Marks every row created by this screen so it can be removed again.
  static const _demoMarker = 'lekas:demo';

  Future<void> _createSampleData() async {
    final l10n = AppLocalizations.of(context)!;
    final spaceRepo = ref.read(spaceRepositoryProvider);
    final taskRepo = ref.read(taskRepositoryProvider);
    final now = DateTime.now();
    final spaceId = const Uuid().v4();
    await spaceRepo.insertSpace(Space(
      id: spaceId,
      name: l10n.trySampleData,
      color: AppTheme.containerColors[1].toARGB32(),
      kind: 'demo',
      archived: false,
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    ));
    final titles = [l10n.typeLabReport, l10n.typePaper, l10n.typePresentation];
    for (var i = 0; i < titles.length; i++) {
      final due = DateTime(now.year, now.month, now.day + i + 1, 17);
      await taskRepo.insertTask(Task(
        id: const Uuid().v4(),
        spaceId: spaceId,
        title: titles[i],
        priority: 1,
        status: 'todo',
        isGroup: false,
        pinned: false,
        inbox: false,
        deadline: due.millisecondsSinceEpoch,
        sourceText: _demoMarker,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      ));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savedTasksCount(titles.length))),
    );
  }

  Future<void> _deleteSampleData() async {
    final l10n = AppLocalizations.of(context)!;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteSampleData),
        content: Text(l10n.deleteSampleDataSubtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );
    if (proceed != true || !mounted) return;
    final taskRepo = ref.read(taskRepositoryProvider);
    final spaceRepo = ref.read(spaceRepositoryProvider);
    final tasks = await taskRepo.getTasks(includeInbox: true);
    for (final task in tasks.where((t) => t.sourceText == _demoMarker)) {
      // softDeleteTask also clears spaceId, so the demo space can be dropped.
      await taskRepo.softDeleteTask(task.id);
    }
    final spaces = await spaceRepo.getSpaces(includeArchived: true);
    for (final space in spaces.where((s) => s.kind == 'demo')) {
      await spaceRepo.deleteSpace(space.id);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.sampleDataRemoved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.demoModeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.trySampleData),
            subtitle: Text(l10n.trySampleDataSubtitle),
            trailing: const Icon(Icons.description),
            onTap: _createSampleData,
          ),
          ListTile(
            title: Text(l10n.deleteSampleData),
            subtitle: Text(l10n.deleteSampleDataSubtitle),
            trailing: const Icon(Icons.delete),
            onTap: _deleteSampleData,
          ),
        ],
      ),
    );
  }
}
