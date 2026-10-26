import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/calendar_screen.dart';
import 'exam_screen.dart';
import 'fokus_hari_ini_screen.dart';
import 'tasks_screen.dart';

class WidgetLanjutanScreen extends ConsumerStatefulWidget {
  const WidgetLanjutanScreen({super.key});

  @override
  ConsumerState<WidgetLanjutanScreen> createState() => _WidgetLanjutanScreenState();
}

class _WidgetLanjutanScreenState extends ConsumerState<WidgetLanjutanScreen> {
  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
  }

  /// The exam countdown widget tracks the course with the next deadline, so
  /// the tile opens the exam list of that course.
  Future<void> _openExamCountdown() async {
    final l10n = AppLocalizations.of(context)!;
    final tasks = await ref.read(taskRepositoryProvider).getTasks(includeInbox: false);
    final now = DateTime.now().millisecondsSinceEpoch;
    final upcoming = tasks
        .where((t) => t.spaceId != null && t.deadline != null && t.deadline! > now)
        .toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
    if (!mounted) return;
    if (upcoming.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noExamsYet)),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExamScreen(spaceId: upcoming.first.spaceId!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.advancedWidgetsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.taskListTitle),
            subtitle: Text(l10n.widgetTaskListSubtitle),
            trailing: const Icon(Icons.list),
            onTap: () => _push(const TasksScreen()),
          ),
          ListTile(
            title: Text(l10n.widgetTodayClasses),
            subtitle: Text(l10n.widgetTodayClassesSubtitle),
            trailing: const Icon(Icons.school),
            onTap: () => _push(const CalendarScreen()),
          ),
          ListTile(
            title: Text(l10n.widgetExamCountdown),
            subtitle: Text(l10n.widgetExamCountdownSubtitle),
            trailing: const Icon(Icons.timer),
            onTap: _openExamCountdown,
          ),
          ListTile(
            title: Text(l10n.widgetTodayFocus),
            subtitle: Text(l10n.widgetTodayFocusSubtitle),
            trailing: const Icon(Icons.star),
            onTap: () => _push(const FokusHariIniScreen()),
          ),
        ],
      ),
    );
  }
}
