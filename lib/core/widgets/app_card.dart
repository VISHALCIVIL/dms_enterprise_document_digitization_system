import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';

/// Reusable Google Stitch Card Container (#FFFFFF surface with 1px outline).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Border? border;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? StitchColors.surfaceContainerLowest,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border ?? Border.all(color: StitchColors.outlineVariant, width: 1),
      ),
      child: child,
    );
  }
}
