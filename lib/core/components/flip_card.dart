import 'package:flutter/material.dart';

import '../theme.dart';

/// A card that rotates on the Y axis when tapped. The face swaps at the
/// halfway point; the whole motion uses the shared finite curve and is
/// instant when the OS asks for reduced motion.
class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.color,
    this.onFlip,
  });

  final Widget front;
  final Widget back;
  final Color color;
  final ValueChanged<bool>? onFlip;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.normal + const Duration(milliseconds: 80),
  );
  bool _showBack = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    final next = !_showBack;
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _showBack = next);
    } else {
      if (next) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      setState(() => _showBack = next);
    }
    widget.onFlip?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final angle = reduced
              ? (_showBack ? 3.14159 : 0.0)
              : _controller.value * 3.14159;
          final showingBack = angle > 3.14159 / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(28),
              child: Center(
                child: SingleChildScrollView(
                  child: showingBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(3.14159),
                          child: widget.back,
                        )
                      : widget.front,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
