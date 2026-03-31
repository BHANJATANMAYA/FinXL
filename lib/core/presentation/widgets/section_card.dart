import 'package:finxl/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color,
    this.border,
    this.boxShadow,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: AppTheme.cardDecoration(
        color: color,
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
