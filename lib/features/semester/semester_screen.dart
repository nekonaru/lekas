import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../core/components/undo_snackbar.dart';
import '../spaces/space_detail_screen.dart';
import '../spaces/spaces_screen.dart';
import '../spaces/space_form_dialog.dart';

/// The Semester tab: the active semester as a hero, the courses in it, and
/// every other semester one tap away. Replaces the old categories tab as
/// the anchor of the academic flow; [embedded] sheds the app bar when the
/// shell hosts it as a tab, and keeps a back arrow when pushed from the
/// settings screen instead.
class SemesterScreen extends ConsumerWidget {
  const SemesterScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final semesterRepo = ref.watch(semesterRepositoryProvider);
    final spaceRepo = ref.watch(spaceRepositoryProvider);
    final taskRepo = ref.watch(taskRepositoryProvider);

    final body = StreamBuilder<List<Semester>>(
      stream: semesterRepo.watchSemesters(),
      builder: (context, semesterSnapshot) {
        if (semesterSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final semesters = semesterSnapshot.data ?? const <Semester>[];
        final active = semesters.where((s) => s.isActive).firstOrNull;
        final others = semesters.where((s) => !s.isActive).toList();
        if (semesters.isEmpty) {
          return _NoSemester(onCreate: () => _createSemester(context, ref));
        }
        return StreamBuilder<List<Space>>(
          stream: spaceRepo.watchSpaces(),
          builder: (context, spaceSnapshot) {
            final spaces = spaceSnapshot.data ?? const <Space>[];
            return StreamBuilder<List<Task>>(
              stream: taskRepo.watchTasks(includeInbox: true),
              builder: (context, taskSnapshot) {
                final tasks = taskSnapshot.data ?? const <Task>[];
                final stats = _statsBySemester(spaces, tasks);
                return ListView(
                  padding: EdgeInsets.only(
                    bottom: 96,
                    top: embedded ? 12 : 0,
                  ),
                  children: [
                    if (active != null) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: _ActiveSemesterHero(
                          semester: active,
                          stats: stats[active.id] ?? const _Stats(),
                          onRename: () =>
                              _renameSemester(context, ref, active),
                          onDelete: () =>
                              _deleteSemester(context, ref, active),
                          onManage: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const SpacesScreen(view: SpaceView.courses),
                            ),
                          ),
                        ),
                      ),
                      _SectionHeader(label: l10n.courseListTitle),
                      for (final space
                          in spaces.where((s) => s.semesterId == active.id))
                        _CourseRow(
                          space: space,
                          openTasks: _openTasks(tasks, space.id),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  SpaceDetailScreen(spaceId: space.id),
                            ),
                          ),
                          onEdit: () => showSpaceFormDialog(
                            context,
                            ref,
                            existing: space,
                          ),
                          onArchive: () =>
                              _archiveCourse(context, ref, space),
                          onDelete: () => _deleteCourse(context, ref, space),
                        ),
                      if (spaces.where((s) => s.semesterId == active.id).isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                          child: Text(
                            l10n.emptySpaces,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: _NoActiveSemester(
                          onCreate: () => _createSemester(context, ref),
                        ),
                      ),
                    if (others.isNotEmpty) ...[
                      _SectionHeader(label: l10n.semesterOtherLabel),
                      for (final other in others)
                        _OtherSemesterRow(
                          semester: other,
                          stats: stats[other.id] ?? const _Stats(),
                          onActivate: () => ref
                              .read(semesterRepositoryProvider)
                              .setActive(other.id),
                          onDelete: () =>
                              _deleteSemester(context, ref, other),
                        ),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: embedded ? null : AppBar(title: Text(l10n.semesterTitle)),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createSemester(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.newSemester),
        tooltip: l10n.newSemester,
      ),
    );
  }

  Map<String, _Stats> _statsBySemester(List<Space> spaces, List<Task> tasks) {
    final spacesBySemester = <String, List<Space>>{};
    for (final space in spaces) {
      final semesterId = space.semesterId;
      if (semesterId != null) {
        (spacesBySemester[semesterId] ??= <Space>[]).add(space);
      }
    }
    final tasksBySpace = <String, List<Task>>{};
    for (final task in tasks) {
      final spaceId = task.spaceId;
      if (spaceId != null) {
        (tasksBySpace[spaceId] ??= <Task>[]).add(task);
      }
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      for (final entry in spacesBySemester.entries)
        entry.key: _statsFor(entry.value, tasksBySpace, now),
    };
  }

  _Stats _statsFor(
    List<Space> spaces,
    Map<String, List<Task>> tasksBySpace,
    int now,
  ) {
    var total = 0;
    var done = 0;
    var overdue = 0;
    for (final space in spaces) {
      for (final task in tasksBySpace[space.id] ?? const <Task>[]) {
        total++;
        if (task.status == 'done') {
          done++;
          continue;
        }
        if (task.deadline != null && task.deadline! < now) overdue++;
      }
    }
    return _Stats(
      courses: spaces.length,
      totalTasks: total,
      doneTasks: done,
      overdueTasks: overdue,
    );
  }

  int _openTasks(List<Task> tasks, String spaceId) => tasks
      .where((task) => task.spaceId == spaceId && task.status != 'done')
      .length;
}

/// How far one semester's courses and tasks have come (design 4.3).
class _Stats {
  const _Stats({
    this.courses = 0,
    this.totalTasks = 0,
    this.doneTasks = 0,
    this.overdueTasks = 0,
  });

  final int courses;
  final int totalTasks;
  final int doneTasks;
  final int overdueTasks;

  double get progress => totalTasks == 0 ? 0 : doneTasks / totalTasks;
}

/// The gradient hero carrying the active semester: name, how far the tasks
/// got, how many courses sit inside, and the two management actions.
class _ActiveSemesterHero extends StatelessWidget {
  const _ActiveSemesterHero({
    required this.semester,
    required this.stats,
    required this.onRename,
    required this.onDelete,
    required this.onManage,
  });

  final Semester semester;
  final _Stats stats;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_outlined, size: 16, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: 8),
              Text(
                l10n.semesterActiveLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: Colors.white.withValues(alpha: 0.9),
                tooltip: l10n.editSemesterLabel,
                onPressed: onRename,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.white.withValues(alpha: 0.9),
                tooltip: l10n.semesterDeleteTitle,
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              semester.name,
              style: text.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              l10n.courseCount(stats.courses),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: stats.progress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  l10n.tasksDoneOf(stats.doneTasks, stats.totalTasks),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (stats.overdueTasks > 0) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.semesterOverdue(stats.overdueTasks),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4338CA),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onManage,
                icon: const Icon(Icons.manage_search, size: 20),
                label: Text(
                  l10n.manageCoursesLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The small caps section label used above each group on the tab.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

/// One course of the active semester: initial avatar, name, how many tasks
/// still stand open in it.
class _CourseRow extends StatelessWidget {
  const _CourseRow({
    required this.space,
    required this.openTasks,
    required this.onTap,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final Space space;
  final int openTasks;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final code = space.code?.trim();
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(space.color),
        child: Text(
          space.name.isNotEmpty ? space.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(space.name),
      subtitle: Text(
        code != null && code.isNotEmpty
            ? '$code · ${l10n.openTasksCount(openTasks)}'
            : l10n.openTasksCount(openTasks),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        tooltip: l10n.editLabel,
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit();
            case 'archive':
              onArchive();
            case 'delete':
              onDelete();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Text(l10n.editSpaceTitle),
          ),
          PopupMenuItem(
            value: 'archive',
            child: Text(l10n.archiveLabel),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text(
              l10n.deleteSpaceTitle,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// One inactive semester: its name, how much is inside it, and the two
/// moves: promote it to active, or delete it for good.
class _OtherSemesterRow extends StatelessWidget {
  const _OtherSemesterRow({
    required this.semester,
    required this.stats,
    required this.onActivate,
    required this.onDelete,
  });

  final Semester semester;
  final _Stats stats;
  final VoidCallback onActivate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.school_outlined),
      title: Text(semester.name),
      subtitle: Text(
        '${l10n.courseCount(stats.courses)} · '
        '${l10n.tasksDoneOf(stats.doneTasks, stats.totalTasks)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: onActivate,
            child: Text(l10n.makeActiveLabel),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.semesterDeleteTitle,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/// The empty state when no semester exists at all (only reachable after
/// deleting the last one).
class _NoSemester extends StatelessWidget {
  const _NoSemester({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noSemesterTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noSemesterBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(l10n.newSemester),
            ),
          ],
        ),
      ),
    );
  }
}

/// The empty state when semesters exist but none is flagged active (also
/// only reachable by deleting the active one when another remains in some
/// edge path).
class _NoActiveSemester extends StatelessWidget {
  const _NoActiveSemester({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.school_outlined),
        title: Text(l10n.noSemesterTitle),
        subtitle: Text(l10n.noSemesterBody),
        trailing: FilledButton(
          onPressed: onCreate,
          child: Text(l10n.newSemester),
        ),
      ),
    );
  }
}

Future<void> _createSemester(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  final created = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.newSemester),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: l10n.semesterPeriodExample,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (controller.text.trim().isEmpty) return;
            Navigator.pop(dialogContext, true);
          },
          child: Text(l10n.createNewSemester),
        ),
      ],
    ),
  );
  final name = controller.text.trim();
  Future<void>.delayed(const Duration(milliseconds: 400), controller.dispose);
  if (created != true || name.isEmpty) return;
  await ref.read(semesterRepositoryProvider).createSemester(name);
  HapticFeedback.lightImpact();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.semesterCreated)),
  );
}

Future<void> _renameSemester(
  BuildContext context,
  WidgetRef ref,
  Semester semester,
) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController(text: semester.name);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.editSemesterLabel),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: l10n.semesterPeriodExample,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  final name = controller.text.trim();
  Future<void>.delayed(const Duration(milliseconds: 400), controller.dispose);
  if (confirmed != true || name.isEmpty || name == semester.name) return;
  await ref.read(semesterRepositoryProvider).rename(semester.id, name);
}

Future<void> _deleteSemester(
  BuildContext context,
  WidgetRef ref,
  Semester semester,
) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.semesterDeleteTitle),
      content: Text(l10n.semesterDeleteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
            foregroundColor: Theme.of(dialogContext).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.deleteLabel),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(semesterRepositoryProvider).deleteSemester(semester.id);
  HapticFeedback.mediumImpact();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.semesterDeleted)),
  );
}

/// Archives one course with an undo, mirroring the spaces list.
Future<void> _archiveCourse(
  BuildContext context,
  WidgetRef ref,
  Space space,
) async {
  final l10n = AppLocalizations.of(context)!;
  await ref.read(spaceRepositoryProvider).archiveSpace(space.id);
  if (!context.mounted) return;
  UndoSnackbar.show(
    context,
    l10n.spacesArchivedUndo(1),
    () async {
      await ref.read(spaceRepositoryProvider).updateSpace(
            space.copyWith(
              archived: false,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    },
  );
}

/// Deletes one course with a confirm dialog: children go with it, its
/// tasks move to the inbox, and the semester list refreshes live.
Future<void> _deleteCourse(
  BuildContext context,
  WidgetRef ref,
  Space space,
) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteSpaceTitle),
      content: Text(l10n.deleteSpaceBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
            foregroundColor: Theme.of(dialogContext).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.deleteLabel),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(spaceRepositoryProvider).deleteSpaceCascade(space.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.deleted)),
  );
}
