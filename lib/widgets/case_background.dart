import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CaseBackground extends StatelessWidget {
  const CaseBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  AppColors.caseDeep,
                  Color(0xFF301C16),
                  Color(0xFF3A2228),
                ]
              : const [
                  AppColors.creamWash,
                  AppColors.peachWash,
                  AppColors.roseWash,
                ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: _Glow(
              color: AppColors.purpleSecondary.withValues(
                alpha: isDark ? 0.12 : 0.10,
              ),
              size: 200,
            ),
          ),
          Positioned(
            bottom: 80,
            left: -70,
            child: _Glow(
              color: AppColors.caseIndigo.withValues(
                alpha: isDark ? 0.18 : 0.07,
              ),
              size: 240,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
