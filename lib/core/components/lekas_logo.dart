import 'package:flutter/material.dart';

/// The Lekas logo used in the app: a white bolt on an indigo to violet
/// gradient, generated from one master drawing (see tool/generate_logo.py).
/// Falls back to a plain bolt icon if the bundled image is missing, so the
/// shell and onboarding never render a broken image.
class LekasLogo extends StatelessWidget {
  const LekasLogo({super.key, this.size = 44, this.radius});

  /// The displayed square size in logical pixels.
  final double size;

  /// Corner radius. Null defaults to 22 percent of the size, matching the
  /// launcher icon's rounded square.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? size * 0.22),
        child: Image.asset(
          'assets/branding/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => ColoredBox(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.bolt,
              size: size * 0.5,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
