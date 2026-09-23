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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  AppColors.caseDeep,
                  Color(0xFF3D2418),
                  Color(0xFF4A2C30),
                ]
              : const [
                  AppColors.creamWash,
                  AppColors.peachWash,
                  AppColors.roseWash,
                ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _Glow(
              color: AppColors.purpleSecondary.withValues(
                alpha: isDark ? 0.22 : 0.20,
              ),
              size: 220,
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: _Glow(
              color: (isDark ? AppColors.caseIndigo : AppColors.mintAccent)
                  .withValues(alpha: isDark ? 0.30 : 0.22),
              size: 260,
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
