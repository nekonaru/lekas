import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/components/empty_state.dart';
import '../../data/providers.dart';
import '../../domain/focus_log.dart';
import '../../l10n/app_localizations.dart';

/// A plain log of recorded focus sessions, grouped by day, with the task
/// each session belonged to. Read-only; recording happens in the timer.
class SessionLogScreen extends ConsumerStatefulWidget {
  const SessionLogScreen({super.key});

  @override
  ConsumerState<SessionLogScreen> createState() => _SessionLogScreenState();
}

class _SessionLogScreenState extends ConsumerState<SessionLogScreen> {
  late Future<_LogData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_LogData> _load() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessions = await ref
        .read(focusSessionRepositoryProvider)
        .getFocusSessionsSince(today.subtract(const Duration(days: 13)).millisecondsSinceEpoch);
    final tasks = await ref.read(taskRepositoryProvider).getTasks(includeInbox: true);
    return _LogData(groupFocusSessions(sessions, today: today), {
      for (final task in tasks) task.id: task.title,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final timeFormat = DateFormat.Hm(Localizations.localeOf(context).toString());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionLogTitle)),
      body: FutureBuilder<_LogData>(
        future: _data,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (data.days.isEmpty) {
            return EmptyState(
              message: l10n.sessionLogEmpty,
              icon: Icons.timer_outlined,
            );
          }
          final total = data.days.fold<int>(
            0,
            (sum, day) => sum + day.minutes,
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  l10n.sessionLogTotal(total),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onPrimaryContainer,
                      ),
                ),
              ),
              for (final day in data.days) ...[
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    day.key,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                for (final session in day.sessions)
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.timer_outlined, color: colors.primary),
                    title: Text(
                      data.names[session.taskId] ?? l10n.sessionLogTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      timeFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(session.startedAt),
                      ),
                    ),
                    trailing: Text(
                      '${session.durationSec ~/ 60}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LogData {
  const _LogData(this.days, this.names);

  final List<FocusLogDay> days;
  final Map<String, String> names;
}
