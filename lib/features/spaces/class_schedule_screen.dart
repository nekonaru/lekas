import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';

/// Minutes since midnight of a TimeOfDay (used by the schedule form).
int timeOfDayMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

/// The weekly class schedule of one course: grouped per weekday, laid out
/// as cards with a colored kind bar, edited and deleted per card instead of
/// through a spartan typed form (design section 5.12).
class ClassScheduleScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const ClassScheduleScreen({super.key, required this.spaceId});

  @override
  ConsumerState<ClassScheduleScreen> createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends ConsumerState<ClassScheduleScreen> {
  String _kindLabel(AppLocalizations l10n, String kind) {
    switch (kind) {
      case 'lab':
        return l10n.kindLab;
      default:
        return l10n.kindLecture;
    }
  }

  Color _kindColor(String kind) {
    switch (kind) {
      case 'lab':
        return const Color(0xFF10B981);
      case 'lecture':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  String _weekdayName(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return l10n.monday;
      case DateTime.tuesday:
        return l10n.tuesday;
      case DateTime.wednesday:
        return l10n.wednesday;
      case DateTime.thursday:
        return l10n.thursday;
      case DateTime.friday:
        return l10n.friday;
      case DateTime.saturday:
        return l10n.saturday;
      case DateTime.sunday:
        return l10n.sunday;
      default:
        return '';
    }
  }

  Future<void> _openSlotDialog({ClassSlot? existing}) async {
    final result = await showDialog<_SlotForm>(
      context: context,
      builder: (_) => _SlotFormDialog(existing: existing),
    );
    if (result == null) return;
    final repo = ref.read(classSlotRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    if (existing == null) {
      await repo.insertClassSlot(ClassSlot(
        id: const Uuid().v4(),
        spaceId: widget.spaceId,
        weekday: result.weekday,
        startMin: timeOfDayMinutes(result.start),
        endMin: timeOfDayMinutes(result.end),
        kind: result.kind,
        room: result.room.isEmpty ? null : result.room,
        updatedAt: now,
      ));
    } else {
      await repo.updateClassSlot(existing.copyWith(
        weekday: result.weekday,
        startMin: timeOfDayMinutes(result.start),
        endMin: timeOfDayMinutes(result.end),
        kind: result.kind,
        room: Value(result.room.isEmpty ? null : result.room),
        updatedAt: now,
      ));
    }
    if (mounted) setState(() {});
  }

  Future<void> _confirmDelete(ClassSlot slot) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final summary =
        '${_weekdayName(l10n, slot.weekday)} · '
        '${DateUtil.formatTime(DateTime(2026, 1, 1, slot.startMin ~/ 60, slot.startMin % 60), locale)}–'
        '${DateUtil.formatTime(DateTime(2026, 1, 1, slot.endMin ~/ 60, slot.endMin % 60), locale)}'
        '${slot.room == null || slot.room!.isEmpty ? '' : ' · ${slot.room}'}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteClassSlot),
        content: Text(
          '${l10n.deleteClassSlotBody}\n$summary',
        ),
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
    if (confirmed != true || !mounted) return;
    await ref.read(classSlotRepositoryProvider).deleteClassSlot(slot.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(classSlotRepositoryProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.classScheduleTitle)),
      body: FutureBuilder<List<ClassSlot>>(
        future: repo.getClassSlots(widget.spaceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final slots = (snapshot.data ?? <ClassSlot>[]).toList()
            ..sort((a, b) {
              final byDay = a.weekday.compareTo(b.weekday);
              return byDay != 0 ? byDay : a.startMin.compareTo(b.startMin);
            });

          // Group by weekday, keeping only the days that have classes.
          final byWeekday = <int, List<ClassSlot>>{};
          for (final slot in slots) {
            (byWeekday[slot.weekday] ??= <ClassSlot>[]).add(slot);
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: _AddSlotCallout(
                  onAdd: () => _openSlotDialog(),
                ),
              ),
              if (slots.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_view_week_outlined,
                        size: 56,
                        color: colors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.emptyClassSchedule,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              for (final weekday in byWeekday.keys.toList()..sort()) ...[
                _SectionHeader(
                  label: _weekdayName(l10n, weekday),
                  count: byWeekday[weekday]!.length,
                ),
                for (final slot in byWeekday[weekday]!)
                  _SlotCard(
                    slot: slot,
                    accent: _kindColor(slot.kind),
                    kindLabel: _kindLabel(l10n, slot.kind),
                    locale: locale,
                    onEdit: () => _openSlotDialog(existing: slot),
                    onDelete: () => _confirmDelete(slot),
                  ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSlotDialog(),
        icon: const Icon(Icons.add),
        label: Text(l10n.addClassSlot),
      ),
    );
  }
}

/// The empty style callout that teaches what the schedule is for; the FAB
/// and the callout both open the same dialog.
class _AddSlotCallout extends StatelessWidget {
  const _AddSlotCallout({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: const Icon(Icons.calendar_month_outlined),
        title: Text(l10n.addClassSlot),
        subtitle: Text(l10n.classScheduleHint),
        trailing: const Icon(Icons.chevron_right),
        onTap: onAdd,
      ),
    );
  }
}

/// The small section header above each weekday's classes.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: colors.primary,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One class slot: colored kind bar, time range, kind chip, room, and the
/// quiet edit and delete actions on the trailing edge.
class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.accent,
    required this.kindLabel,
    required this.locale,
    required this.onEdit,
    required this.onDelete,
  });

  final ClassSlot slot;
  final Color accent;
  final String kindLabel;
  final String locale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final start = DateUtil.formatTime(
      DateTime(2026, 1, 1, slot.startMin ~/ 60, slot.startMin % 60),
      locale,
    );
    final end = DateUtil.formatTime(
      DateTime(2026, 1, 1, slot.endMin ~/ 60, slot.endMin % 60),
      locale,
    );
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 52,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$start–$end',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.1,
                              ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            kindLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (slot.room != null && slot.room!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.meeting_room_outlined,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            slot.room!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: l10n.editClassSlot,
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: l10n.deleteLabel,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the slot dialog hands back to the screen.
class _SlotForm {
  const _SlotForm({
    required this.weekday,
    required this.start,
    required this.end,
    required this.kind,
    required this.room,
  });

  final int weekday;
  final TimeOfDay start;
  final TimeOfDay end;
  final String kind;
  final String room;
}

/// The add/edit dialog for one class slot: weekday chips, time pickers,
/// room and kind. Edits reuse the same fields as adds.
class _SlotFormDialog extends StatefulWidget {
  const _SlotFormDialog({this.existing});

  final ClassSlot? existing;

  @override
  State<_SlotFormDialog> createState() => _SlotFormDialogState();
}

class _SlotFormDialogState extends State<_SlotFormDialog> {
  int _weekday = DateTime.now().weekday;
  TimeOfDay _start = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 9, minute: 40);
  String _kind = 'lecture';
  final _roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _weekday = existing.weekday;
      _start = TimeOfDay(
        hour: existing.startMin ~/ 60,
        minute: existing.startMin % 60,
      );
      _end = TimeOfDay(
        hour: existing.endMin ~/ 60,
        minute: existing.endMin % 60,
      );
      _kind = existing.kind;
      _roomController.text = existing.room ?? '';
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  int get _startMin => timeOfDayMinutes(_start);
  int get _endMin => timeOfDayMinutes(_end);

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final valid = _startMin < _endMin;
    return AlertDialog(
      title: Text(widget.existing == null ? l10n.addClassSlot : l10n.editClassSlot),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.weekdayLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.8,
                  ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var day = 1; day <= 7; day++)
                  ChoiceChip(
                    label: Text(_weekdayShort(l10n, day)),
                    selected: _weekday == day,
                    onSelected: (_) => setState(() => _weekday = day),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.startTimeLabel),
                    subtitle: Text(
                      _start.format(context),
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    leading: const Icon(Icons.schedule),
                    onTap: () => _pickTime(start: true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.endTimeLabel),
                    subtitle: Text(
                      _end.format(context),
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    leading: const Icon(Icons.schedule_outlined),
                    onTap: () => _pickTime(start: false),
                  ),
                ),
              ],
            ),
            if (!valid)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.classTimeOrderError,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _roomController,
              decoration: InputDecoration(
                labelText: l10n.roomLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.classKindLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.8,
                  ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final kind in const ['lecture', 'lab'])
                  ChoiceChip(
                    label: Text(_kindLabel(context, kind)),
                    selected: _kind == kind,
                    onSelected: (_) => setState(() => _kind = kind),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: valid
              ? () => Navigator.pop(
                    context,
                    _SlotForm(
                      weekday: _weekday,
                      start: _start,
                      end: _end,
                      kind: _kind,
                      room: _roomController.text.trim(),
                    ),
                  )
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  String _weekdayShort(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return l10n.monShort;
      case DateTime.tuesday:
        return l10n.tueShort;
      case DateTime.wednesday:
        return l10n.wedShort;
      case DateTime.thursday:
        return l10n.thuShort;
      case DateTime.friday:
        return l10n.friShort;
      case DateTime.saturday:
        return l10n.satShort;
      case DateTime.sunday:
        return l10n.sunShort;
      default:
        return '';
    }
  }

  String _kindLabel(BuildContext context, String kind) {
    final l10n = AppLocalizations.of(context)!;
    switch (kind) {
      case 'lab':
        return l10n.kindLab;
      default:
        return l10n.kindLecture;
    }
  }
}
