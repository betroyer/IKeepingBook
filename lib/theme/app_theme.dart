import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.caseIndigo,
      primary: AppColors.caseIndigo,
      secondary: AppColors.purpleSecondary,
      surface: AppColors.creamWash,
      brightness: Brightness.light,
    );
    return _build(base, Brightness.light);
  }

  static ThemeData dark() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.caseIndigo,
      primary: AppColors.caseMist,
      secondary: AppColors.purpleSecondary,
      surface: AppColors.caseDeep,
      brightness: Brightness.dark,
    );
    return _build(base, Brightness.dark);
  }

  static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final ink = brightness == Brightness.dark
        ? AppColors.onDark
        : AppColors.labelInk;
    final muted = AppColors.labelMuted;

    final textTheme = ThemeData(brightness: brightness).textTheme.apply(
          fontFamily: 'Poppins',
          bodyColor: ink,
          displayColor: ink,
        );

    final radius14 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        outline: AppColors.metalEdge,
        error: AppColors.signalRed,
      ),
      fontFamily: 'Poppins',
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      dividerColor: AppColors.metalEdge.withValues(alpha: 0.35),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: ink,
        ),
        iconTheme: IconThemeData(color: ink, size: 24),
        actionsIconTheme: IconThemeData(color: ink, size: 24),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.caseIndigo,
        foregroundColor: AppColors.onDark,
        elevation: 2,
        focusElevation: 3,
        highlightElevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: brightness == Brightness.dark
            ? AppColors.caseIndigo.withValues(alpha: 0.94)
            : AppColors.caseGlassFill,
        surfaceTintColor: Colors.transparent,
        indicatorColor: brightness == Brightness.dark
            ? AppColors.onDark.withValues(alpha: 0.16)
            : AppColors.caseIndigo.withValues(alpha: 0.14),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          final Color color;
          if (brightness == Brightness.dark) {
            color = selected ? AppColors.onDark : AppColors.onDark.withValues(alpha: 0.65);
          } else {
            color = selected ? AppColors.caseIndigo : muted;
          }
          return IconThemeData(size: 24, color: color);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          final Color color;
          if (brightness == Brightness.dark) {
            color = selected ? AppColors.onDark : AppColors.onDark.withValues(alpha: 0.65);
          } else {
            color = selected ? AppColors.caseIndigo : muted;
          }
          return textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: color,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.caseIndigo.withValues(alpha: 0.14),
        backgroundColor: brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.55),
        disabledColor: AppColors.metalEdge.withValues(alpha: 0.2),
        labelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: ink,
        ),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.caseIndigo,
        ),
        side: BorderSide(color: AppColors.metalEdge.withValues(alpha: 0.45)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        showCheckmark: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.caseIndigo,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.onDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF3A2228)
            : const Color(0xFFFFF9F4),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.caseIndigo,
          foregroundColor: AppColors.onDark,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: radius14,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.caseIndigo,
          minimumSize: const Size(48, 48),
          side: BorderSide(color: AppColors.metalEdge.withValues(alpha: 0.7)),
          shape: radius14,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.caseIndigo,
          minimumSize: const Size(48, 40),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.caseIndigo,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.72),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.metalEdge.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.metalEdge.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.caseIndigo,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.signalRed),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: muted.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
