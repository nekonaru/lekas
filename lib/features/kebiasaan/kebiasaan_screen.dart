import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/habits.dart';
import '../../l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  void _reload() => setState(() => _data = _load());

  Future<_HabitData> _load() async {
    final repo = ref.read(habitRepositoryProvider);
    final habits = await repo.watchActiveHabits().first;
    final checks = <String, Set<String>>{};
    for (final habit in habits) {
      final rows = await repo.allChecksOf(habit.id);
      checks[habit.id] = {for (final row in rows) row.date};
    }
    return _HabitData(habits, checks);
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
    controller.dispose();
    if (created != true || !mounted) return;
    await ref.read(habitRepositoryProvider).createHabit(
          name: controller.text.trim(),
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
      body: FutureBuilder<_HabitData>(
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_outlined,
                      size: 56,
                      color: colors.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noHabitsYet,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _addHabit,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.habitAdd),
                    ),
                  ],
                ),
              ),
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
                    weekKeys: weekKeys,
                    onToggle: (dayKey) async {
                      HapticFeedback.selectionClick();
                      await ref
                          .read(habitRepositoryProvider)
                          .toggleCheck(habit.id, dayKey);
                      _reload();
                    },
                    onDelete: () => _deleteHabit(habit),
                  ),
                ),
              const SizedBox(height: 6),
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
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
  _HabitData(this.habits, this.checks);

  final List<Habit> habits;
  final Map<String, Set<String>> checks;
}

Color _hexColor(String hex) {
  final value = hex.replaceFirst('#', '');
  return Color(int.parse('FF$value', radix: 16));
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.checked,
    required this.weekKeys,
    required this.onToggle,
    required this.onDelete,
  });

  final Habit habit;
  final Set<String> checked;
  final List<String> weekKeys;
  final ValueChanged<String> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final weekdayFormat = DateFormat('E', locale);
    final streak = habitStreak(checked, today: DateTime.now());
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
                        .format(DateTime.now().subtract(
                            Duration(days: weekKeys.length - 1 - i)))
                        .substring(0, 1),
                    date: dayFromKey(weekKeys[i])!,
                    checked: checked.contains(weekKeys[i]),
                    color: _hexColor(habit.color),
                    isToday: weekKeys[i] == dayKeyOf(DateTime.now()),
                    onTap: () => onToggle(weekKeys[i]),
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
    required this.color,
    required this.isToday,
    required this.onTap,
  });

  final String keyLabel;
  final DateTime date;
  final bool checked;
  final Color color;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? color : Colors.transparent,
                border: Border.all(
                  color: checked
                      ? color
                      : (isToday ? colors.primary : colors.outlineVariant),
                  width: isToday ? 2 : 1.4,
                ),
              ),
              alignment: Alignment.center,
              child: checked
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isToday ? colors.primary : colors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
