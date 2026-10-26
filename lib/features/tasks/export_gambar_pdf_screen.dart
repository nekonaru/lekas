import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class ExportGambarPDFScreen extends ConsumerStatefulWidget {
  const ExportGambarPDFScreen({super.key});

  @override
  ConsumerState<ExportGambarPDFScreen> createState() => _ExportGambarPDFScreenState();
}

class _ExportGambarPDFScreenState extends ConsumerState<ExportGambarPDFScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportImagePdfTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.exportWeekSchedule),
            subtitle: Text(l10n.exportWeekScheduleSubtitle),
            trailing: const Icon(Icons.image),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.exportTaskList),
            subtitle: Text(l10n.exportTaskListSubtitle),
            trailing: const Icon(Icons.image),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.exportGradeRecap),
            subtitle: Text(l10n.exportGradeRecapSubtitle),
            trailing: const Icon(Icons.picture_as_pdf),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.exportDeadlineHistory),
            subtitle: Text(l10n.exportDeadlineHistorySubtitle),
            trailing: const Icon(Icons.picture_as_pdf),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
