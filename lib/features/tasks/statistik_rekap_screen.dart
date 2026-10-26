import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class StatistikRekapScreen extends ConsumerStatefulWidget {
  const StatistikRekapScreen({super.key});

  @override
  ConsumerState<StatistikRekapScreen> createState() => _StatistikRekapScreenState();
}

class _StatistikRekapScreenState extends ConsumerState<StatistikRekapScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.semesterStatsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.onTimePercentage),
            trailing: const Icon(Icons.access_time),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.busiestCourse),
            trailing: const Icon(Icons.school),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.attendanceRecap),
            trailing: const Icon(Icons.check_circle),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.weeklyTrend),
            trailing: const Icon(Icons.trending_up),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
