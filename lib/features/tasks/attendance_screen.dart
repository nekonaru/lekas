import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/date_util.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/attendance.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_service.dart';

/// Attendance and the absence quota of design section 5.19: how many
/// meetings were attended, how many absences are still allowed, and the
/// marks for today's class.
class AttendanceScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const AttendanceScreen({super.key, required this.spaceId});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String? _todayStatus;

  /// Memoized so rebuilds of the nested future builders do not requery the
  /// attendance table on every state flip; reset after any write.
  Future<List<AttendanceData>>? _recordsFuture;

  String get _today =>
      DateTime.now().toIso8601String().split('T').first;

  void _invalidateRecords() {
    _recordsFuture = null;
  }

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    final records = await ref
        .read(attendanceRepositoryProvider)
        .getForSpace(widget.spaceId);
    if (!mounted) return;
    String? status;
    for (final record in records) {
      if (record.date == _today) status = record.status;
    }
    setState(() => _todayStatus = status);
  }

  Future<void> _mark(String status, String label) async {
    final l10n = AppLocalizations.of(context)!;
    await ref.read(attendanceRepositoryProvider).mark(
          spaceId: widget.spaceId,
          date: _today,
          status: status,
        );
    if (!mounted) return;
    setState(() {
      _todayStatus = status;
      _invalidateRecords();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.attendanceSavedToday(label))),
    );
  }

  /// Reopens one row for editing: a date picker (today or any earlier
  /// day), the four status chips and an optional note.
  Future<void> _editRecord(AttendanceData record) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    DateTime pickedDate = DateTime.tryParse(record.date) ?? DateTime.now();
    final noteController = TextEditingController(text: record.note ?? '');
    String status = record.status;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.editAttendanceRecord),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(DateUtil.formatDate(pickedDate, locale)),
                  subtitle: Text(l10n.dateLabel),
                  onTap: () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: dialogContext,
                      initialDate: pickedDate,
                      firstDate: DateTime(now.year - 3),
                      lastDate: now,
                    );
                    if (date == null) return;
                    setDialogState(() => pickedDate = date);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.statusLabel,
                  style: Theme.of(dialogContext)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(dialogContext).colorScheme.primary,
                        letterSpacing: 0.8,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in const [
                      'present',
                      'absent',
                      'excused',
                      'sick',
                    ])
                      ChoiceChip(
                        label: Text(_statusLabel(l10n, option)),
                        selected: status == option,
                        onSelected: (_) => setDialogState(() => status = option),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: l10n.attendanceNoteLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
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
      ),
    );
    if (saved != true || !mounted) {
      Future<void>.delayed(
        const Duration(milliseconds: 400),
        noteController.dispose,
      );
      return;
    }
    final isoDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    ).toIso8601String().split('T').first;
    final note = noteController.text.trim();
    Future<void>.delayed(
      const Duration(milliseconds: 400),
      noteController.dispose,
    );
    await ref.read(attendanceRepositoryProvider).updateRecord(
          record.id,
          date: isoDate,
          status: status,
          note: note.isEmpty ? null : note,
        );
    if (!mounted) return;
    setState(() {
      _recordsFuture = null;
      if (record.date == _today) _loadToday();
    });
  }

  /// Removes one record for good after the user confirms; the app stays
  /// quiet about it until the next sync, which recounts the quota.
  Future<void> _deleteRecord(AttendanceData record) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateUtil.formatDate(
      DateTime.tryParse(record.date) ?? DateTime.now(),
      locale,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAttendanceRecord),
        content: Text(
          '${l10n.deleteAttendanceRecordBody}\n${_statusLabel(l10n, record.status)} · $date',
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
    if (confirmed != true) return;
    await ref.read(attendanceRepositoryProvider).deleteRecord(record.id);
    if (!mounted) return;
    setState(() {
      _recordsFuture = null;
      if (record.date == _today) _loadToday();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.attendanceRecordDeleted)),
    );
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'present':
        return l10n.presentLabel;
      case 'absent':
        return l10n.absentLabel;
      case 'excused':
        return l10n.excusedLabel;
      case 'sick':
        return l10n.sickLabel;
      default:
        return status;
    }
  }

  ({IconData icon, Color color}) _statusStyle(BuildContext context, String status) {
    final colors = Theme.of(context).colorScheme;
    switch (status) {
      case 'present':
        return (icon: Icons.check_circle_outline, color: Colors.green.shade600);
      case 'absent':
        return (icon: Icons.cancel_outlined, color: colors.error);
      case 'excused':
        return (icon: Icons.event_available_outlined, color: colors.primary);
      case 'sick':
        return (icon: Icons.medical_services_outlined, color: Colors.orange.shade700);
      default:
        return (icon: Icons.help_outline, color: colors.onSurfaceVariant);
    }
  }

  /// The history section: every record, newest first, with per-row edit and
  /// delete. The whole block only renders when there is something to show.
  Widget _historySection(BuildContext context, Space space) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    _recordsFuture ??= ref
        .read(attendanceRepositoryProvider)
        .getForSpace(space.id);
    return FutureBuilder<List<AttendanceData>>(
      future: _recordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final records = snapshot.data ?? const <AttendanceData>[];
        if (records.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              l10n.attendanceHistoryEmpty,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.attendanceHistory,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${records.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            for (final record in records.take(40))
              ListTile(
                leading: Builder(
                  builder: (context) {
                    final style = _statusStyle(context, record.status);
                    return Icon(style.icon, color: style.color);
                  },
                ),
                title: Text(_statusLabel(l10n, record.status)),
                subtitle: Text(
                  [
                    DateUtil.formatDate(
                      DateTime.tryParse(record.date) ?? DateTime.now(),
                      locale,
                    ),
                    if (record.note != null && record.note!.isNotEmpty)
                      record.note!,
                  ].join(' · '),
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: l10n.editAttendanceRecord,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editRecord(record);
                    } else {
                      _deleteRecord(record);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(l10n.editLabel),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        l10n.deleteLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _editRecord(record),
              ),
          ],
        );
      },
    );
  }

  Widget _markButton({
    required String status,
    required String statusLabel,
    Color? background,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final selected = _todayStatus == status;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selected)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.check_circle, color: Colors.green),
          ),
        ElevatedButton(
          onPressed: () => _mark(status, statusLabel),
          style: background == null
              ? null
              : ElevatedButton.styleFrom(backgroundColor: background),
          child: Text(l10n.markLabel),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spaceRepo = ref.watch(spaceRepositoryProvider);
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);

    return FutureBuilder<Space>(
      future: spaceRepo.getSpace(widget.spaceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final space = snapshot.data;
        if (space == null) {
          // The course was deleted while this screen was open.
          return Scaffold(
            appBar: AppBar(title: Text(l10n.attendanceTitle)),
            body: Center(child: Text(l10n.recordNotFound)),
          );
        }

        return FutureBuilder<AttendanceSummary>(
          future: attendanceRepo.summaryFor(space),
          builder: (context, summarySnapshot) {
            final summary = summarySnapshot.data;
            return Scaffold(
              appBar: AppBar(title: Text(l10n.attendanceTitle)),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(space.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  if (summary != null) ...[
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.fact_check_outlined),
                        title: Text(
                          l10n.attendanceProgress(
                            summary.attended,
                            summary.planned,
                          ),
                        ),
                        subtitle: Text(
                          l10n.attendanceLimitNote(
                            space.maxAbsentPercent ??
                                kDefaultMaxAbsentPercent,
                            summary.limit,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: summary.exhausted
                          ? Colors.red.shade50
                          : summary.lastOne
                              ? Colors.orange.shade50
                              : null,
                      child: ListTile(
                        leading: Icon(
                          summary.exhausted
                              ? Icons.error
                              : summary.lastOne
                                  ? Icons.warning_amber
                                  : Icons.shield_outlined,
                          color: summary.exhausted
                              ? Colors.red
                              : summary.lastOne
                                  ? Colors.orange
                                  : null,
                        ),
                        title: Text(
                          l10n.attendanceRemaining(summary.remaining),
                        ),
                        subtitle: summary.exhausted
                            ? Text(
                                l10n.attendanceExhausted,
                                style: const TextStyle(color: Colors.red),
                              )
                            : summary.lastOne
                                ? Text(
                                    l10n.attendanceLastOne,
                                    style:
                                        const TextStyle(color: Colors.orange),
                                  )
                                : null,
                      ),
                    ),
                  ],
                  const Divider(),
                  ListTile(
                    title: Text(l10n.presentLabel),
                    trailing: _markButton(
                      status: 'present',
                      statusLabel: l10n.presentLabel,
                    ),
                  ),
                  ListTile(
                    title: Text(l10n.absentLabel),
                    trailing: _markButton(
                      status: 'absent',
                      statusLabel: l10n.absentLabel,
                      background: Colors.red,
                    ),
                  ),
                  ListTile(
                    title: Text(l10n.excusedLabel),
                    trailing: _markButton(
                      status: 'excused',
                      statusLabel: l10n.excusedLabel,
                    ),
                  ),
                  ListTile(
                    title: Text(l10n.sickLabel),
                    trailing: _markButton(
                      status: 'sick',
                      statusLabel: l10n.sickLabel,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.numbers),
                    title: Text(l10n.totalMeetingsLabel),
                    subtitle: Text(
                      (space.totalMeetings ?? kDefaultTotalMeetings)
                          .toString(),
                    ),
                    onTap: () => _pickNumber(
                      title: l10n.totalMeetingsLabel,
                      initial: space.totalMeetings ?? kDefaultTotalMeetings,
                      min: 1,
                      max: 100,
                      onSaved: (value) => spaceRepo.setAttendanceSettings(
                        widget.spaceId,
                        totalMeetings: value,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.percent),
                    title: Text(l10n.absentLimitLabel),
                    subtitle: Text(
                      (space.maxAbsentPercent ?? kDefaultMaxAbsentPercent)
                          .toString(),
                    ),
                    onTap: () => _pickNumber(
                      title: l10n.absentLimitLabel,
                      initial: space.maxAbsentPercent ??
                          kDefaultMaxAbsentPercent,
                      min: 0,
                      max: 100,
                      onSaved: (value) => spaceRepo.setAttendanceSettings(
                        widget.spaceId,
                        maxAbsentPercent: value,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.medical_information_outlined),
                    title: Text(l10n.excusedCountsLabel),
                    value: space.excusedCountsAbsent ?? false,
                    onChanged: (value) => spaceRepo.setAttendanceSettings(
                      widget.spaceId,
                      excusedCountsAbsent: value,
                    ),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_none),
                    title: Text(l10n.attendPromptToggle),
                    subtitle: Text(l10n.attendPromptToggleHint),
                    value: space.attendPrompt ?? false,
                    onChanged: (value) async {
                      await spaceRepo.setAttendanceSettings(
                        widget.spaceId,
                        attendPrompt: value,
                      );
                      // Reschedules or drops the prompts right away.
                      ref.read(reminderServiceProvider).syncAll();
                      if (mounted) setState(() {});
                    },
                  ),
                  _historySection(context, space),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// A small number dialog for the per course attendance settings.
  Future<void> _pickNumber({
    required String title,
    required int initial,
    required int min,
    required int max,
    required Future<void> Function(int) onSaved,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: '$initial');
    final saved = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value == null) return;
              Navigator.pop(dialogContext, value.clamp(min, max));
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved == null || !mounted) return;
    await onSaved(saved);
    if (mounted) setState(() {});
  }
}
