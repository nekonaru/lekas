import 'package:flutter/material.dart';

import '../../core/components/lekas_logo.dart';
import '../../core/theme.dart';

/// The cold start opener: a brief brand reveal (logo scales in, the word
/// and tagline fade up, then the whole cover cross fades into the app).
/// Finite and self removing, driven once per process launch.
class IntroSplash extends StatefulWidget {
  const IntroSplash({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<IntroSplash> createState() => _IntroSplashState();
}

class _IntroSplashState extends State<IntroSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logo;
  late final Animation<double> _word;
  late final Animation<double> _tagline;
  late final Animation<double> _exit;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    )..forward().then((_) => widget.onDone());
    // Logo pops first, word second, tagline third, cover out last.
    _logo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: AppMotion.ease),
    );
    _word = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.6, curve: AppMotion.ease),
    );
    _tagline = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.36, 0.72, curve: AppMotion.ease),
    );
    _exit = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 1.0, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Opacity(
        opacity: 1 - _exit.value,
        // The whole cover fades as one, revealing the app underneath.
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
          ),
          child: Stack(
            children: [
              // A soft halo behind the mark, for depth.
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.62 + 0.38 * _logo.value,
                      child: Opacity(
                        opacity: _logo.value,
                        child: const LekasLogo(size: 108),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Transform.translate(
                      offset: Offset(0, 14 * (1 - _word.value)),
                      child: Opacity(
                        opacity: _word.value,
                        child: Text(
                          'Lekas',
                          style: text.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: _tagline.value,
                      child: Text(
                        'Tugas, beres.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
