import 'package:flutter/material.dart';

/// A compact circular progress with an optional value label in the middle.
/// Used by report cards, GPA projection and weekly goals so every ratio in
/// the app reads the same way.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.strokeWidth = 8,
    this.center,
    this.color,
  });

  /// 0..1, saturated internally.
  final double value;

  final double size;
  final double strokeWidth;

  /// Optional short text, for example "87" or "80%".
  final String? center;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = value.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              color: color ?? colors.primary,
              backgroundColor: colors.primaryContainer.withValues(alpha: 0.45),
              strokeCap: StrokeCap.round,
            ),
          ),
          if (center != null)
            FittedBox(
              child: Text(
                center!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
