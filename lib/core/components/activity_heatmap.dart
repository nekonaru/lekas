import 'package:flutter/material.dart';

import '../date_util.dart';
import '../../domain/habits.dart';

/// A GitHub-style 12-week grid of daily activity. Callers supply the
/// count per local day key; the widget owns the layout, the four-shade
/// scale and the labels, so every heatmap in the app reads the same.
class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({
    super.key,
    required this.counts,
    required this.endDay,
    required this.title,
    required this.lessLabel,
    required this.moreLabel,
  });

  /// Number of events per day key (`YYYY-MM-DD`).
  final Map<String, int> counts;

  /// The last day shown (normally today).
  final DateTime endDay;

  /// Section caption and the two ends of the legend.
  final String title;
  final String lessLabel;
  final String moreLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final start = DateUtil.heatmapStart(endDay);

    Color cellColor(int count) {
      if (count <= 0) return colors.surfaceContainerHighest;
      if (count == 1) return colors.primaryContainer;
      if (count <= 3) return colors.primary.withValues(alpha: 0.55);
      return colors.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: colors.primary,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    for (var week = 0; week < 12; week++)
                      Column(
                        children: [
                          for (var day = 0; day < 7; day++)
                            Container(
                              width: 15,
                              height: 15,
                              margin: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: cellColor(counts[dayKeyOf(
                                      start.add(Duration(days: week * 7 + day)),
                                    )] ??
                                    0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    lessLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 6),
                  for (final level in const [0, 1, 2, 4])
                    Container(
                      width: 13,
                      height: 13,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: cellColor(level),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  const SizedBox(width: 6),
                  Text(
                    moreLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
