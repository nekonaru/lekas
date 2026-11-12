import 'package:flutter/material.dart';

import '../../core/task_filter.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

/// Shows the shared task filter sheet: category, status and sort order,
/// combined. Changes apply live through [onChanged] so the list under the
/// sheet updates as the user flips chips, matching every other picker in
/// the app.
Future<void> showTaskFilterSheet({
  required BuildContext context,
  required List<Space> spaces,
  required TaskFilter current,
  required ValueChanged<TaskFilter> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _TaskFilterSheet(
      spaces: spaces,
      filter: current,
      onChanged: onChanged,
    ),
  );
}

class _TaskFilterSheet extends StatefulWidget {
  const _TaskFilterSheet({
    required this.spaces,
    required this.filter,
    required this.onChanged,
  });

  final List<Space> spaces;
  final TaskFilter filter;
  final ValueChanged<TaskFilter> onChanged;

  @override
  State<_TaskFilterSheet> createState() => _TaskFilterSheetState();
}

class _TaskFilterSheetState extends State<_TaskFilterSheet> {
  late TaskFilter _filter = widget.filter;

  void _update(TaskFilter next) {
    setState(() => _filter = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    // Extra bottom padding for the home gesture inset without an AppBar.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return SafeArea(
      top: false,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 8),
        children: [
          // Handle row: title and a reset that only shows when anything is on.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
            child: Row(
              children: [
                Text(
                  l10n.filterLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (!_filter.isDefault)
                  TextButton(
                    onPressed: () => _update(TaskFilter.none),
                    child: Text(l10n.resetLabel),
                  ),
              ],
            ),
          ),
          const Divider(height: 20),
          _SectionLabel(label: l10n.taskContainer),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  avatar: const Icon(Icons.all_inbox, size: 18),
                  label: Text(l10n.allLabel),
                  selected: _filter.spaceId == null,
                  onSelected: (_) =>
                      _update(_filter.copyWith(spaceId: null)),
                ),
                for (final space in widget.spaces)
                  ChoiceChip(
                    avatar: Icon(
                      Icons.folder_outlined,
                      size: 18,
                      color: Color(space.color),
                    ),
                    label: Text(space.name),
                    selected: _filter.spaceId == space.id,
                    onSelected: (_) => _update(_filter.copyWith(
                      spaceId: _filter.spaceId == space.id ? null : space.id,
                    )),
                  ),
              ],
            ),
          ),
          _SectionLabel(label: l10n.statusLabel),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  avatar: const Icon(Icons.list, size: 18),
                  label: Text(l10n.allLabel),
                  selected: _filter.status == TaskStatusFilter.all,
                  onSelected: (_) =>
                      _update(_filter.copyWith(status: TaskStatusFilter.all)),
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.radio_button_unchecked, size: 18),
                  label: Text(l10n.pendingLabel),
                  selected: _filter.status == TaskStatusFilter.pending,
                  onSelected: (_) => _update(
                    _filter.copyWith(status: TaskStatusFilter.pending),
                  ),
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(l10n.doneLabel),
                  selected: _filter.status == TaskStatusFilter.done,
                  onSelected: (_) => _update(
                    _filter.copyWith(status: TaskStatusFilter.done),
                  ),
                ),
              ],
            ),
          ),
          _SectionLabel(label: l10n.sortLabel),
          for (final entry in _sortOptions(l10n))
            ListTile(
              leading: Icon(
                entry.key,
                color: _filter.sort == entry.value ? colors.primary : null,
              ),
              title: Text(entry.label),
              selected: _filter.sort == entry.value,
              trailing: _filter.sort == entry.value
                  ? Icon(Icons.check, color: colors.primary)
                  : null,
              onTap: () => _update(_filter.copyWith(sort: entry.value)),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<({IconData key, TaskSort value, String label})> _sortOptions(
    AppLocalizations l10n,
  ) {
    return [
      (
        key: Icons.south,
        value: TaskSort.deadlineAsc,
        label: l10n.sortDeadlineAsc,
      ),
      (
        key: Icons.north,
        value: TaskSort.deadlineDesc,
        label: l10n.sortDeadlineDesc,
      ),
      (
        key: Icons.schedule,
        value: TaskSort.createdDesc,
        label: l10n.sortCreatedDesc,
      ),
      (
        key: Icons.flag_outlined,
        value: TaskSort.priorityHighFirst,
        label: l10n.sortPriorityHighFirst,
      ),
    ];
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
