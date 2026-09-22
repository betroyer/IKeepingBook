import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Frosted pane — rare-book case glass, not decorative blur chrome.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
    this.radius = 18,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double radius;
  /// When true, soft shadow only (no border). Default: metal-edge border only.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AppColors.caseGlassFillDark : AppColors.caseGlassFill;
    final edge = borderColor ?? AppColors.metalEdge.withValues(alpha: 0.55);

    final pane = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(radius),
              border: elevated
                  ? null
                  : Border.all(color: edge, width: 1),
              boxShadow: elevated
                  ? [
                      BoxShadow(
                        color: AppColors.caseDeep.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );

    if (onTap == null) return pane;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: pane,
      ),
    );
  }
}
