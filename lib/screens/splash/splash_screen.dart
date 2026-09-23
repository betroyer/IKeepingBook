import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Warm splash with the circular brand logo and a soft load arc.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _arc;
  late final AnimationController _pulse;
  late final AnimationController _hold;

  @override
  void initState() {
    super.initState();
    _arc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _hold = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward().whenComplete(() {
        if (mounted) widget.onFinished();
      });
  }

  @override
  void dispose() {
    _arc.dispose();
    _pulse.dispose();
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.creamWash,
              AppColors.peachWash,
              AppColors.roseWash,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_arc, _pulse]),
                    builder: (context, child) {
                      final scale = 0.96 + (_pulse.value * 0.05);
                      return Transform.scale(
                        scale: scale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            child!,
                            CustomPaint(
                              size: const Size(240, 240),
                              painter: _LoadArcPainter(progress: _arc.value),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/branding/logo.png',
                      width: 210,
                      height: 210,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'I-Keeping Books',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.labelInk,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: 8),
                  Text(
                    'Opening your library…',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.labelMuted,
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

class _LoadArcPainter extends CustomPainter {
  _LoadArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.48;
    final paint = Paint()
      ..color = AppColors.caseIndigo.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final start = progress * math.pi * 2 - math.pi / 2;
    const sweep = math.pi * 0.65;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoadArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Brand tokens derived from the circular logo.
class BrandColors {
  BrandColors._();
  static const rose = AppColors.purpleSecondary;
  static const rosewood = AppColors.caseIndigo;
  static const cream = AppColors.creamWash;
}
