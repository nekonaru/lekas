import 'package:flutter/material.dart';

import '../theme.dart';

/// The empty list placeholder: a tinted circle with the icon and the
/// message, fading and scaling into view once. The animation is finite,
/// so tests can pumpAndSettle on it.
class EmptyState extends StatefulWidget {
  const EmptyState({super.key, required this.message, this.icon});

  final String message;

  /// Optional glyph above the message. Null keeps the old plain text.
  final IconData? icon;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppMotion.normal,
  )..forward();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final curve = CurvedAnimation(
      parent: _entrance,
      curve: AppMotion.ease,
    );
    return Center(
      child: FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1).animate(curve),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.25),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 36,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
