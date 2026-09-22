import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Coral splash with the brand book logo and a rotating load arc
/// matching the provided animated logo.
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

  static const _coral = Color(0xFFFF6F57);

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
      duration: const Duration(milliseconds: 2200),
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
      backgroundColor: _coral,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_arc, _pulse]),
                  builder: (context, child) {
                    final scale = 0.96 + (_pulse.value * 0.06);
                    return Transform.scale(
                      scale: scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          child!,
                          CustomPaint(
                            size: const Size(220, 220),
                            painter: _LoadArcPainter(progress: _arc.value),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/branding/splash_book.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'I-Keeping Books',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Opening your library…',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
              ),
            ],
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
    final radius = size.shortestSide * 0.42;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final start = progress * math.pi * 2 - math.pi / 2;
    const sweep = math.pi * 0.7;
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

/// Tiny brand token for reuse (coral from logo).
class BrandColors {
  BrandColors._();
  static const coral = Color(0xFFFF6F57);
  static const indigo = AppColors.caseIndigo;
}
