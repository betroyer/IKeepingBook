import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum SignalStatus { green, amber, red }

/// Status as a gallery signal lamp — never decorative accent.
class SignalLamp extends StatelessWidget {
  const SignalLamp({
    super.key,
    required this.status,
    this.size = 10,
  });

  final SignalStatus status;
  final double size;

  Color get _color => switch (status) {
        SignalStatus.green => AppColors.signalGreen,
        SignalStatus.amber => AppColors.signalAmber,
        SignalStatus.red => AppColors.signalRed,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color,
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
    );
  }
}
