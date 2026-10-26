import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class WidgetLanjutanScreen extends ConsumerStatefulWidget {
  const WidgetLanjutanScreen({super.key});

  @override
  ConsumerState<WidgetLanjutanScreen> createState() => _WidgetLanjutanScreenState();
}

class _WidgetLanjutanScreenState extends ConsumerState<WidgetLanjutanScreen> {
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
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.widgetTodayClasses),
            subtitle: Text(l10n.widgetTodayClassesSubtitle),
            trailing: const Icon(Icons.school),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.widgetExamCountdown),
            subtitle: Text(l10n.widgetExamCountdownSubtitle),
            trailing: const Icon(Icons.timer),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.widgetTodayFocus),
            subtitle: Text(l10n.widgetTodayFocusSubtitle),
            trailing: const Icon(Icons.star),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
