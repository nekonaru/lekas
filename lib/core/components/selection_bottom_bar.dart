import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// The bar shown at the bottom of a list while rows are selected: how many
/// are picked on the left, the shared action icons on the right. It lives
/// in the body, not in the app bar, so the tab identity does not vanish
/// under the selection.
class SelectionBottomBar extends StatelessWidget {
  const SelectionBottomBar({
    super.key,
    required this.count,
    required this.child,
  });

  final int count;

  /// The action buttons (usually a [BulkSelectionBar]), kept right aligned.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Text(
                l10n.selectedCount(count),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              child,
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
