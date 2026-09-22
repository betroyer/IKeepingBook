import 'package:flutter/material.dart';

/// Shared-axis style: the case pane yields horizontally to the form.
Route<T> casePaneRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondary) => page,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final incoming = Tween<Offset>(
        begin: const Offset(0.18, 0),
        end: Offset.zero,
      ).animate(curved);
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
      // Secondary (outgoing case) slides left slightly — pane yield.
      final outgoing = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.08, 0),
      ).animate(CurvedAnimation(
        parent: secondary,
        curve: Curves.easeOutCubic,
      ));

      return SlideTransition(
        position: outgoing,
        child: FadeTransition(
          opacity: fade,
          child: SlideTransition(position: incoming, child: child),
        ),
      );
    },
  );
}
