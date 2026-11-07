import 'package:flutter/material.dart';

import '../theme.dart';

/// A child that fades and slides up once when it first appears.
///
/// Every entrance in the app uses this so lists, sheets and empty states
/// share one motion. The animation is finite (at most [AppMotion.normal]
/// long, plus an optional delay), so widget tests can still pumpAndSettle
/// and the drawer test can still settle with its fixed pumps. Keep delays
/// tiny: the delay is scheduled through a timer, and a long one would leave
/// a pending timer behind when a test finishes.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 10,
  });

  final Widget child;

  /// Position in a staggered group (first rows move first). Capped at six
  /// steps so a long list never waits long before settling.
  final int index;

  /// Upward travel distance in logical pixels.
  final double offset;

  @override
  Widget build(BuildContext context) {
    final step = index.clamp(0, 6);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.normal + AppMotion.stagger * step,
      curve: AppMotion.ease,
      builder: (context, value, child) {
        // At rest the child returns bare: no opacity or transform layer is
        // left in the tree, so a settled list costs nothing extra.
        if (value >= 1) return child!;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Scales a child down slightly while it is pressed, so taps, cards and
/// rows answer back with one consistent press motion. Tooltips and pointer
/// routes below the child keep working because the state only changes the
/// transform, never the hit test.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.scale = 0.97});

  final Widget child;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.ease,
        child: widget.child,
      ),
    );
  }
}
