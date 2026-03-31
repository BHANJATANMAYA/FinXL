import 'package:flutter/material.dart';

class FinxlPageBody extends StatelessWidget {
  const FinxlPageBody({
    required this.child,
    this.maxWidth = 920,
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 120),
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
