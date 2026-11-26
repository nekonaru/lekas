import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/components/activity_heatmap.dart';
import '../../core/components/empty_state.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/habits.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_service.dart';

/// Habit tracker: a list of habits with a 7-day check grid and a streak.
/// Deliberately small: one tap checks today, one tap unchecks it, and the
/// streak walks back from yesterday when today has no check yet.
class KebiasaanScreen extends ConsumerStatefulWidget {
  const KebiasaanScreen({super.key});

  @override
  ConsumerState<KebiasaanScreen> createState() => _KebiasaanScreenState();
}

/// The palette offered when adding a habit.
const _palette = [
  '#6366F1', // indigo
  '#10B981', // emerald
  '#F59E0B', // amber
  '#EC4899', // pink
  '#06B6D4', // cyan
  '#8B5CF6', // violet
];

class _KebiasaanScreenState extends ConsumerState<KebiasaanScreen> {
  late Future<_HabitData> _data;
  _HabitData? _lastData;

  bool _reminderOn = false;
  int _reminderHour = 20;
  int _reminderMinute = 0;

  @override
  void initState() {
    super.initState();
    _data = _load();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final settings = ref.read(settingsRepositoryProvider);
    final on = await settings.get('habit_reminder_enabled') == '1';
    final hour = int.tryParse(await settings.get('habit_reminder_hour') ?? '');
    final minute =
        int.tryParse(await settings.get('habit_reminder_minute') ?? '');
    if (!mounted) return;
    setState(() {
      _reminderOn = on;
      _reminderHour = (hour ?? 20).clamp(0, 23);
      _reminderMinute = (minute ?? 0).clamp(0, 59);
    });
  }

  Future<void> _applyReminder({bool? enabled, TimeOfDay? time}) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final on = enabled ?? _reminderOn;
    final hour = time?.hour ?? _reminderHour;
    final minute = time?.minute ?? _reminderMinute;
    setState(() {
      _reminderOn = on;
      _reminderHour = hour;
      _reminderMinute = minute;
    });

    final settings = ref.read(settingsRepositoryProvider);
    await settings.set('habit_reminder_enabled', on ? '1' : '0');
    await settings.set('habit_reminder_hour', '$hour');
    await settings.set('habit_reminder_minute', '$minute');

    try {
      final service = ref.read(reminderServiceProvider);
      if (on && await service.notificationsEnabled() == false) {
        await service.requestNotificationPermission();
      }
      await service.syncHabitReminder(
        enabled: on,
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.habitReminderFailed)),
      );
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
    );
    if (picked == null || !mounted) return;
    await _applyReminder(time: picked);
  }

  Widget _buildReminderCard(AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;
    final time = '${_reminderHour.toString().padLeft(2, '0')}:'
        '${_reminderMinute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(Icons.alarm_outlined, color: colors.primary),
          title: Text(
            l10n.habitReminderTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            l10n.habitReminderBody,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_reminderOn)
                TextButton(
                  onPressed: _pickReminderTime,
                  child: Text(time),
                ),
              Switch(
                value: _reminderOn,
                onChanged: (value) => _applyReminder(enabled: value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reload() => setState(() => _data = _load());

  Future<_HabitData> _load() async {
    final repo = ref.read(habitRepositoryProvider);
    final habits = await repo.watchActiveHabits().first;
    final checks = <String, Set<String>>{};
    final skips = <String, Set<String>>{};
    for (final habit in habits) {
      final rows = await repo.allChecksOf(habit.id);
      checks[habit.id] = {
        for (final row in rows)
          if (row.kind == 'check') row.date,
      };
      skips[habit.id] = {
        for (final row in rows)
          if (row.kind == 'skip') row.date,
      };
    }
    return _HabitData(habits, checks, skips);
  }

  Future<void> _addHabit() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    var color = _palette.first;
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.habitAdd),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.habitName,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setDialogState(() {}),
                onSubmitted: (_) {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(dialogContext, true);
                  }
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: [
                  for (final hex in _palette)
                    GestureDetector(
                      onTap: () => setDialogState(() => color = hex),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _hexColor(hex),
                          border: color == hex
                              ? Border.all(
                                  color: Theme.of(dialogContext)
                                      .colorScheme
                                      .onSurface,
                                  width: 2.5,
                                )
                              : null,
                        ),
                        child: color == hex
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: controller.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
    final habitName = controller.text.trim();
    controller.dispose();
    if (created != true || !mounted) return;
    await ref.read(habitRepositoryProvider).createHabit(
          name: habitName,
          color: color,
        );
    if (mounted) _reload();
  }

  Future<void> _deleteHabit(Habit habit) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.habitDeleteTitle),
        content: Text(l10n.habitDeleteBody),
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
    if (confirmed != true) return;
    await ref.read(habitRepositoryProvider).deleteHabit(habit.id);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.kebiasaanTitle)),
      body: Column(
        children: [
          _buildReminderCard(l10n),
          Expanded(
            child: FutureBuilder<_HabitData>(
              future: _data,
              initialData: _lastData,
              builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data != null) _lastData = data;
          final today = DateTime.now();
          if (data == null || data.habits.isEmpty) {
            return Column(
              children: [
                Expanded(
                  child: EmptyState(
                    message: l10n.noHabitsYet,
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 88),
                  child: FilledButton.icon(
                    onPressed: _addHabit,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.habitAdd),
                  ),
                ),
              ],
            );
          }

          final weekKeys = lastNDayKeys(7, end: today);
          var checkedThisWeek = 0;
          for (final set in data.checks.values) {
            checkedThisWeek += weekKeys.where(set.contains).length;
          }
          final possible = data.habits.length * 7;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            children: [
              for (final habit in data.habits)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HabitCard(
                    habit: habit,
                    checked: data.checks[habit.id] ?? const <String>{},
                    skipped: data.skips[habit.id] ?? const <String>{},
                    weekKeys: weekKeys,
                    onToggle: (dayKey) async {
                      HapticFeedback.selectionClick();
                      await ref
                          .read(habitRepositoryProvider)
                          .toggleCheck(habit.id, dayKey);
                      _reload();
                    },
                    onSkip: (dayKey) async {
                      HapticFeedback.mediumImpact();
                      await ref
                          .read(habitRepositoryProvider)
                          .toggleSkip(habit.id, dayKey);
                      _reload();
                    },
                    onDelete: () => _deleteHabit(habit),
                  ),
                ),
              const SizedBox(height: 6),
              ActivityHeatmap(
                counts: data.checkCounts(),
                endDay: DateTime.now(),
                title: l10n.habitHistoryTitle,
                lessLabel: l10n.heatmapLess,
                moreLabel: l10n.heatmapMore,
              ),
              const SizedBox(height: 18),
              // The weekly promise in one line.
              Material(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.habitWeekSummary(checkedThisWeek, possible),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: possible == 0 ? 0 : checkedThisWeek / possible,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.habitRestDay,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
          },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addHabit,
        icon: const Icon(Icons.add),
        label: Text(l10n.habitAdd),
      ),
    );
  }
}

class _HabitData {
  _HabitData(this.habits, this.checks, this.skips);

  final List<Habit> habits;
  final Map<String, Set<String>> checks;
  final Map<String, Set<String>> skips;

  /// How many habits were checked on each day, across every habit.
  Map<String, int> checkCounts() {
    final counts = <String, int>{};
    for (final days in checks.values) {
      for (final day in days) {
        counts[day] = (counts[day] ?? 0) + 1;
      }
    }
    return counts;
  }
}

Color _hexColor(String hex) {
  final value = hex.replaceFirst('#', '');
  return Color(int.parse('FF$value', radix: 16));
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.checked,
    required this.skipped,
    required this.weekKeys,
    required this.onToggle,
    required this.onSkip,
    required this.onDelete,
  });

  final Habit habit;
  final Set<String> checked;
  final Set<String> skipped;
  final List<String> weekKeys;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onSkip;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final weekdayFormat = DateFormat('E', locale);
    final now = DateTime.now();
    final streak = habitStreak(
      checked,
      today: now,
      skippedDays: skipped,
    );
    final weekCount = checked.where(weekKeys.contains).length;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _hexColor(habit.color),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.local_fire_department_outlined,
                    size: 18, color: colors.primary),
                const SizedBox(width: 2),
                Text('$streak',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    l10n.habitStreakLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.deleteLabel,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < weekKeys.length; i++)
                  _DayCell(
                    keyLabel: weekdayFormat
                        .format(now.subtract(
                            Duration(days: weekKeys.length - 1 - i)))
                        .substring(0, 1),
                    date: dayFromKey(weekKeys[i])!,
                    checked: checked.contains(weekKeys[i]),
                    skipped: skipped.contains(weekKeys[i]),
                    color: _hexColor(habit.color),
                    isToday: weekKeys[i] == dayKeyOf(now),
                    onTap: () => onToggle(weekKeys[i]),
                    onLongPress: () => onSkip(weekKeys[i]),
                  ),
                const Spacer(),
                Text(
                  l10n.habitThisWeek(weekCount, weekKeys.length),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.keyLabel,
    required this.date,
    required this.checked,
    required this.skipped,
    required this.color,
    required this.isToday,
    required this.onTap,
    required this.onLongPress,
  });

  final String keyLabel;
  final DateTime date;
  final bool checked;
  final bool skipped;
  final Color color;
  final bool isToday;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Text(
            keyLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Tooltip(
            message: l10n.habitRestDay,
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: checked
                      ? color
                      : skipped
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.22)
                          : Colors.transparent,
                  border: Border.all(
                    color: checked
                        ? color
                        : skipped
                            ? const Color(0xFFF59E0B)
                            : (isToday ? colors.primary : colors.outlineVariant),
                    width: isToday ? 2 : 1.4,
                  ),
                ),
                alignment: Alignment.center,
                child: checked
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : skipped
                        ? const Icon(Icons.local_cafe_outlined,
                            size: 17, color: Color(0xFFF59E0B))
                        : Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isToday
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight:
                                  isToday ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
