import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  String get _today =>
      DateTime.now().toIso8601String().split('T').first;

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
    setState(() => _todayStatus = status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.attendanceSavedToday(label))),
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
