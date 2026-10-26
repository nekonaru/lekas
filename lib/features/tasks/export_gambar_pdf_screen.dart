import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

class ExportGambarPDFScreen extends ConsumerStatefulWidget {
  const ExportGambarPDFScreen({super.key});

  @override
  ConsumerState<ExportGambarPDFScreen> createState() => _ExportGambarPDFScreenState();
}

class _ExportGambarPDFScreenState extends ConsumerState<ExportGambarPDFScreen> {
  String _hhmm(int minutes) {
    final hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final minute = (minutes % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showHint(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _shareWeekSchedule() async {
    final l10n = AppLocalizations.of(context)!;
    final spaceRepo = ref.read(spaceRepositoryProvider);
    final slotRepo = ref.read(classSlotRepositoryProvider);
    final weekdays = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];
    final spaces = await spaceRepo.getSpaces(includeArchived: true);
    final lines = <String>[];
    for (final space in spaces) {
      final slots = await slotRepo.getClassSlots(space.id);
      for (final slot in slots) {
        final day = slot.weekday >= 1 && slot.weekday <= 7
            ? weekdays[slot.weekday - 1]
            : '';
        final room = (slot.room == null || slot.room!.isEmpty) ? '' : ' (${slot.room})';
        lines.add(
          '$day ${_hhmm(slot.startMin)}-${_hhmm(slot.endMin)} ${space.name}$room',
        );
      }
    }
    if (!mounted) return;
    if (lines.isEmpty) {
      _showHint(l10n.emptyClassSchedule);
      return;
    }
    lines.sort();
    await Share.share(lines.join('\n'), subject: l10n.exportWeekSchedule);
  }

  Future<void> _shareTaskList() async {
    final l10n = AppLocalizations.of(context)!;
    final tasks = await ref.read(taskRepositoryProvider).getTasks(includeInbox: true);
    final dated = tasks.where((t) => t.deadline != null).toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
    if (!mounted) return;
    if (dated.isEmpty) {
      _showHint(l10n.emptyTaskList);
      return;
    }
    final format = DateFormat('dd/MM/yyyy');
    final lines = [
      for (final task in dated)
        '${task.title} - ${format.format(DateTime.fromMillisecondsSinceEpoch(task.deadline!).toLocal())}',
    ];
    await Share.share(lines.join('\n'), subject: l10n.exportTaskList);
  }

  Future<void> _shareGradeRecap() async {
    final l10n = AppLocalizations.of(context)!;
    final labels = <String, String>{
      'midterm': l10n.midtermLabel,
      'final': l10n.finalExamLabel,
      'assignment': l10n.assignmentLabel,
      'quiz': l10n.quizLabel,
      'attendance': l10n.attendanceLabel,
      'other': l10n.othersLabel,
    };
    final spaceRepo = ref.read(spaceRepositoryProvider);
    final gradeRepo = ref.read(gradeComponentRepositoryProvider);
    final spaces = await spaceRepo.getSpaces(includeArchived: true);
    final lines = <String>[];
    for (final space in spaces) {
      final components = await gradeRepo.getGradeComponents(space.id);
      if (components.isEmpty) continue;
      lines.add(space.name);
      for (final component in components) {
        lines.add(
          '  ${labels[component.key] ?? component.key}: ${component.weightPercent}%',
        );
      }
    }
    if (!mounted) return;
    if (lines.isEmpty) {
      _showHint(l10n.noGradeComponents);
      return;
    }
    await Share.share(lines.join('\n'), subject: l10n.exportGradeRecap);
  }

  Future<void> _shareDeadlineHistory() async {
    final l10n = AppLocalizations.of(context)!;
    final taskRepo = ref.read(taskRepositoryProvider);
    final eventRepo = ref.read(taskEventRepositoryProvider);
    final tasks = await taskRepo.getTasks(includeInbox: true);
    final format = DateFormat('dd/MM/yyyy HH:mm');
    final lines = <String>[];
    for (final task in tasks) {
      if (task.deadline == null) continue;
      final events = await eventRepo.getTaskEvents(task.id);
      for (final event in events) {
        if (!event.kind.contains('deadline')) continue;
        final when =
            format.format(DateTime.fromMillisecondsSinceEpoch(event.createdAt).toLocal());
        lines.add(
          '${task.title} - $when - ${l10n.deadlineChangeLabel(event.oldValue ?? '-', event.newValue ?? '-')}',
        );
      }
    }
    if (!mounted) return;
    if (lines.isEmpty) {
      _showHint(l10n.emptyDeadlineHistory);
      return;
    }
    await Share.share(lines.join('\n'), subject: l10n.exportDeadlineHistory);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportImagePdfTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.exportWeekSchedule),
            subtitle: Text(l10n.exportWeekScheduleSubtitle),
            trailing: const Icon(Icons.image),
            onTap: _shareWeekSchedule,
          ),
          ListTile(
            title: Text(l10n.exportTaskList),
            subtitle: Text(l10n.exportTaskListSubtitle),
            trailing: const Icon(Icons.image),
            onTap: _shareTaskList,
          ),
          ListTile(
            title: Text(l10n.exportGradeRecap),
            subtitle: Text(l10n.exportGradeRecapSubtitle),
            trailing: const Icon(Icons.picture_as_pdf),
            onTap: _shareGradeRecap,
          ),
          ListTile(
            title: Text(l10n.exportDeadlineHistory),
            subtitle: Text(l10n.exportDeadlineHistorySubtitle),
            trailing: const Icon(Icons.picture_as_pdf),
            onTap: _shareDeadlineHistory,
          ),
        ],
      ),
    );
  }
}
