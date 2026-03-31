import 'package:finxl/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FinxlProgressBar extends StatelessWidget {
  const FinxlProgressBar({
    required this.value,
    this.height = 12,
    this.color,
    this.gradient,
    super.key,
  });

  final double value;
  final double height;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0, 1),
          child: Container(
            decoration: BoxDecoration(
              color: gradient == null ? color ?? AppTheme.primary : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}
