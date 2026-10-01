import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Thin metal shelf edge under a row of specimen labels.
class CaseShelfRail extends StatelessWidget {
  const CaseShelfRail({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: LinearGradient(
            colors: [
              AppColors.metalEdge.withValues(alpha: 0.15),
              AppColors.metalEdge.withValues(alpha: isDark ? 0.75 : 0.85),
              AppColors.caseIndigo.withValues(alpha: 0.45),
              AppColors.metalEdge.withValues(alpha: isDark ? 0.75 : 0.85),
              AppColors.metalEdge.withValues(alpha: 0.15),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.caseDeep.withValues(alpha: 0.18),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
