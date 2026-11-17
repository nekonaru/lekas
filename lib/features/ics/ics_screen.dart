import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/ics.dart';
import '../../l10n/app_localizations.dart';

/// The .ics bridge: export classes and deadlines as a calendar file any
/// calendar app can read, and import a .ics file back as inbox tasks.
/// Everything happens on device; no account, no network.
class IcsScreen extends ConsumerStatefulWidget {
  const IcsScreen({super.key});

  @override
  ConsumerState<IcsScreen> createState() => _IcsScreenState();
}

/// Imported events become tasks, but a hostile or huge file must not flood
/// the inbox, so the importer stops after this many events.
const int kMaxIcsImport = 500;

class _IcsScreenState extends ConsumerState<IcsScreen> {
  bool _busy = false;

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final taskRepo = ref.read(taskRepositoryProvider);
      final spaceRepo = ref.read(spaceRepositoryProvider);
      final slotRepo = ref.read(classSlotRepositoryProvider);

      final spaces = await spaceRepo.getSpaces();
      final nameOf = {for (final space in spaces) space.id: space.name};
      final tasks = await taskRepo.getTasks(includeInbox: true);
      final slots = await slotRepo.getAllClassSlots();

      final events = <IcsEvent>[];
      // Open tasks with a deadline: one all-day event each.
      for (final task in tasks) {
        if (task.status == 'done' || task.deadline == null) continue;
        final deadline = DateTime.fromMillisecondsSinceEpoch(task.deadline!);
        events.add(IcsEvent(
          uid: '${task.id}@lekas',
          start: DateTime(deadline.year, deadline.month, deadline.day),
          summary: task.title,
          description: task.notes,
          isAllDay: true,
        ));
      }
      // Weekly class slots: one recurring event each.
      final now = DateTime.now();
      for (final slot in slots) {
        final courseName = nameOf[slot.spaceId];
        if (courseName == null) continue;
        final start = _nextOccurrence(now, slot.weekday, slot.startMin);
        final durationMin = (slot.endMin - slot.startMin).clamp(5, 24 * 60);
        events.add(IcsEvent(
          uid: '${slot.id}@lekas',
          start: start,
          end: start.add(Duration(minutes: durationMin)),
          summary: courseName,
          location: slot.room,
          rrule: 'FREQ=WEEKLY;BYDAY=${weeklyByDay(slot.weekday)}',
        ));
      }

      final file = File(
        '${(await getApplicationDocumentsDirectory()).path}'
        '/lekas-kalender.ics',
      );
      await file.writeAsString(buildIcsCalendar(events), encoding: utf8);
      await Share.shareXFiles([XFile(file.path)], subject: l10n.calendarIcsTitle);
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.icsExportFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The next calendar date whose weekday is [weekday], at [minutes] past
  /// midnight. Today counts if the slot has not started or already passed;
  /// the export only needs one concrete instance for the recurrence.
  DateTime _nextOccurrence(DateTime now, int weekday, int minutes) {
    var daysToAdd = weekday - now.weekday;
    if (daysToAdd < 0) daysToAdd += 7;
    final day = DateTime(now.year, now.month, now.day + daysToAdd);
    return DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['ics', 'ical'],
      withData: true,
    );
    final bytes = result?.files.singleOrNull?.bytes;
    if (bytes == null) return;

    final String content;
    try {
      content = utf8.decode(bytes);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.icsImportInvalid)));
      return;
    }
    final parsed = parseIcs(content)
        .where((event) => event.summary.trim().isNotEmpty)
        .toList();
    if (parsed.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.icsImportInvalid)));
      return;
    }
    final limited = parsed.take(kMaxIcsImport).toList();
    final truncated = parsed.length > limited.length;

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.icsImportTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.icsImportConfirm(limited.length)),
            if (truncated) ...[
              const SizedBox(height: 8),
              Text(
                l10n.icsImportTooLarge,
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 12),
            for (final event in limited.take(3))
              Text(
                '- ${event.summary}',
                style: Theme.of(dialogContext).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.importFileLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    var created = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final taskRepo = ref.read(taskRepositoryProvider);
    for (final event in limited) {
      final deadline = event.isAllDay
          ? DateTime(event.start.year, event.start.month, event.start.day, 23, 59)
              .millisecondsSinceEpoch
          : event.start.millisecondsSinceEpoch;
      final String title = event.summary.trim();
      final safeTitle = title.length > 500 ? title.substring(0, 500) : title;
      await taskRepo.insertTask(Task(
        id: const Uuid().v4(),
        title: safeTitle,
        priority: 1,
        status: 'todo',
        isGroup: false,
        pinned: false,
        inbox: true,
        deadline: deadline,
        sourceText: 'lekas:ics-import',
        createdAt: now,
        updatedAt: now,
      ));
      created += 1;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(SnackBar(content: Text(l10n.icsImported(created))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.calendarIcsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ],
          _IcsTile(
            icon: Icons.ios_share_outlined,
            tint: const Color(0xFF6366F1),
            title: l10n.icsExportTitle,
            subtitle: l10n.icsExportBody,
            onTap: _busy ? null : _export,
          ),
          const SizedBox(height: 12),
          _IcsTile(
            icon: Icons.file_download_outlined,
            tint: const Color(0xFF10B981),
            title: l10n.icsImportTitle,
            subtitle: l10n.icsImportBody,
            onTap: _busy ? null : _import,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.icsImportSourceHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _IcsTile extends StatelessWidget {
  const _IcsTile({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: tint),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
