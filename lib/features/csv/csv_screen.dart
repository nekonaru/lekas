import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/csv.dart';
import '../../l10n/app_localizations.dart';

/// Tasks as a spreadsheet: export every live task to a CSV file, and
/// import a CSV back into the inbox or straight onto its subject. Tags
/// are split by semicolons; unknown columns are ignored, and a missing
/// title column stops the import cold.
class CsvScreen extends ConsumerStatefulWidget {
  const CsvScreen({super.key});

  @override
  ConsumerState<CsvScreen> createState() => _CsvScreenState();
}

/// Imported rows beyond this cap are dropped with a note, so a hostile
/// file cannot balloon the inbox.
const int kMaxCsvImport = 1000;

class _CsvScreenState extends ConsumerState<CsvScreen> {
  bool _busy = false;

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final taskRepo = ref.read(taskRepositoryProvider);
      final spaceRepo = ref.read(spaceRepositoryProvider);
      final tagRepo = ref.read(tagRepositoryProvider);

      final tasks = await taskRepo.getTasks(includeInbox: true);
      final spaces = await spaceRepo.getSpaces();
      final spaceName = {for (final space in spaces) space.id: space.name};
      final tagMap =
          await tagRepo.tagsForTasks(tasks.map((task) => task.id));
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

      final buffer = StringBuffer('\uFEFF');
      buffer.write(csvRow(const [
        'title', 'type', 'deadline', 'priority', 'status',
        'space', 'weight_percent', 'tags',
      ]));
      for (final task in tasks) {
        final deadline = task.deadline == null
            ? ''
            : dateFormat.format(DateTime.fromMillisecondsSinceEpoch(task.deadline!));
        buffer.write(csvRow([
          task.title,
          task.type ?? '',
          deadline,
          '${task.priority}',
          task.status,
          task.spaceId == null ? '' : (spaceName[task.spaceId] ?? ''),
          task.weightPercent?.toString() ?? '',
          tagMap[task.id]?.join(';') ?? '',
        ]));
      }

      final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
      final file = File(
          '${(await getApplicationDocumentsDirectory()).path}/lekas-tugas-$stamp.csv');
      await file.writeAsString(buffer.toString(), encoding: utf8);
      await Share.shareXFiles([XFile(file.path)], subject: l10n.csvTitle);
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.csvExportFailed)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Column names, lower-cased and spaces flattened to underscores.
  List<String> _normHeader(List<String> cells) =>
      cells.map((cell) => cell.trim().toLowerCase().replaceAll(' ', '_')).toList();

  /// A deadline cell like `2026-11-25` or `2026-11-25 23:59`.
  int? _parseDeadline(String raw) {
    final match = RegExp(
            r'^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?$')
        .firstMatch(raw.trim());
    if (match == null) return null;
    final date = DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      match.group(4) == null ? 23 : int.parse(match.group(4)!),
      match.group(5) == null ? 59 : int.parse(match.group(5)!),
      match.group(6) == null ? 0 : int.parse(match.group(6)!),
    );
    return date.millisecondsSinceEpoch;
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
      withData: true,
    );
    final bytes = result?.files.singleOrNull?.bytes;
    if (bytes == null) return;

    final String content;
    try {
      content = utf8.decode(bytes);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.csvImportInvalid)));
      return;
    }

    final rows = parseCsv(content);
    if (rows.length < 2) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.csvImportInvalid)));
      return;
    }
    final header = _normHeader(rows.first);
    final titleCol = header.indexOf('title');
    if (titleCol < 0) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.csvImportInvalid)));
      return;
    }
    int col(String name) => header.indexOf(name);

    final spaces = await ref.read(spaceRepositoryProvider).getSpaces();
    final spaceByName = <String, String>{
      for (final space in spaces) space.name.trim().toLowerCase(): space.id,
      for (final space in spaces)
        if (space.code != null && space.code!.trim().isNotEmpty)
          space.code!.trim().toLowerCase(): space.id,
    };

    final candidates = <_ImportRow>[];
    var skipped = 0;
    for (final raw in rows.skip(1)) {
      final cells = raw.map((cell) => cell.trim()).toList();
      if (cells.every((cell) => cell.isEmpty)) continue;
      final title = titleCol < cells.length ? cells[titleCol].trim() : '';
      if (title.isEmpty) {
        skipped += 1;
        continue;
      }
      candidates.add(_ImportRow(
        title: title.length > 500 ? title.substring(0, 500) : title,
        type: col('type') >= 0 && col('type') < cells.length
            ? cells[col('type')].toLowerCase()
            : null,
        deadline: col('deadline') >= 0 && col('deadline') < cells.length
            ? _parseDeadline(cells[col('deadline')])
            : null,
        priority: col('priority') >= 0 &&
                col('priority') < cells.length &&
                int.tryParse(cells[col('priority')]) != null
            ? int.parse(cells[col('priority')]).clamp(0, 10)
            : 1,
        done: const {'done', 'selesai', 'true', '1'}
            .contains(cells.isNotEmpty && col('status') >= 0 &&
                    col('status') < cells.length
                ? cells[col('status')].trim().toLowerCase()
                : 'todo'),
        spaceId: col('space') >= 0 && col('space') < cells.length
            ? spaceByName[cells[col('space')].trim().toLowerCase()]
            : null,
        weight: col('weight_percent') >= 0 &&
                col('weight_percent') < cells.length &&
                double.tryParse(cells[col('weight_percent')]) != null
            ? double.parse(cells[col('weight_percent')])
            : null,
        tags: col('tags') >= 0 && col('tags') < cells.length
            ? cells[col('tags')]
                .split(';')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList()
            : const [],
      ));
    }
    if (candidates.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.csvImported(0))));
      return;
    }
    final truncated = candidates.length > kMaxCsvImport;
    final batch = candidates.take(kMaxCsvImport).toList();

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.csvImportTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.csvImportConfirm(batch.length, skipped)),
            if (truncated) ...[
              const SizedBox(height: 8),
              Text(
                l10n.csvImportTooLarge,
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 12),
            for (final row in batch.take(3))
              Text(
                '- ${row.title}',
                style: Theme.of(dialogContext).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.importFileLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final now = DateTime.now().millisecondsSinceEpoch;
    final taskRepo = ref.read(taskRepositoryProvider);
    final tagRepo = ref.read(tagRepositoryProvider);
    var created = 0;
    for (final row in batch) {
      final taskId = const Uuid().v4();
      await taskRepo.insertTask(Task(
        id: taskId,
        spaceId: row.spaceId,
        title: row.title,
        type: row.type,
        deadline: row.deadline,
        priority: row.priority,
        status: row.done ? 'done' : 'todo',
        weightPercent: row.weight,
        isGroup: false,
        pinned: false,
        inbox: false,
        sourceText: 'lekas:csv-import',
        createdAt: now,
        updatedAt: now,
        completedAt: row.done ? now : null,
      ));
      if (row.tags.isNotEmpty) {
        await tagRepo.setTaskTags(taskId, row.tags);
      }
      created += 1;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(SnackBar(content: Text(l10n.csvImported(created))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.csvTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ],
          _CsvTile(
            icon: Icons.ios_share_outlined,
            tint: const Color(0xFF6366F1),
            title: l10n.csvExportTitle,
            subtitle: l10n.csvExportBody,
            onTap: _busy ? null : _export,
          ),
          const SizedBox(height: 12),
          _CsvTile(
            icon: Icons.file_download_outlined,
            tint: const Color(0xFF10B981),
            title: l10n.csvImportTitle,
            subtitle: l10n.csvImportBody,
            onTap: _busy ? null : _import,
          ),
        ],
      ),
    );
  }
}

class _CsvTile extends StatelessWidget {
  const _CsvTile({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: tint),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ImportRow {
  const _ImportRow({
    required this.title,
    required this.type,
    required this.deadline,
    required this.priority,
    required this.done,
    required this.spaceId,
    required this.weight,
    required this.tags,
  });

  final String title;
  final String? type;
  final int? deadline;
  final int priority;
  final bool done;
  final String? spaceId;
  final double? weight;
  final List<String> tags;
}
