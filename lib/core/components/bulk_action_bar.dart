import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// The action bar that replaces the app bar while rows are selected: how
/// many are picked, then one button per action the list supports. Every
/// selection screen (Today, Inbox, Tasks, Search, Trash, Spaces) shares
/// this, so the buttons and their tooltips read the same everywhere.
class BulkSelectionBar extends StatelessWidget {
  const BulkSelectionBar({
    super.key,
    required this.count,
    this.onSelectAll,
    this.onComplete,
    this.onPriority,
    this.onSpace,
    this.onRestore,
    this.onArchive,
    this.onDelete,
    required this.onClose,
  });

  final int count;
  final VoidCallback? onSelectAll;
  final VoidCallback? onComplete;
  final VoidCallback? onPriority;
  final VoidCallback? onSpace;
  final VoidCallback? onRestore;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onSelectAll != null)
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: l10n.selectAllLabel,
            onPressed: onSelectAll,
          ),
        if (onComplete != null)
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: l10n.markLabel,
            onPressed: onComplete,
          ),
        if (onPriority != null)
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: l10n.priorityMedium,
            onPressed: onPriority,
          ),
        if (onSpace != null)
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            tooltip: l10n.taskContainer,
            onPressed: onSpace,
          ),
        if (onRestore != null)
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: l10n.restoreLabel,
            onPressed: onRestore,
          ),
        if (onArchive != null)
          IconButton(
            icon: const Icon(Icons.archive),
            tooltip: l10n.archiveLabel,
            onPressed: onArchive,
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.deleteLabel,
            onPressed: onDelete,
          ),
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.closeLabel,
          onPressed: onClose,
        ),
      ],
    );
  }
}
