import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';
import '../theme/stitch_typography.dart';

enum BadgeType { primary, success, warning, error, neutral }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = BadgeType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (type) {
      case BadgeType.primary:
        bgColor = StitchColors.primary.withValues(alpha: 0.12);
        textColor = StitchColors.primary;
        break;
      case BadgeType.success:
        bgColor = StitchColors.emeraldContainer;
        textColor = StitchColors.emeraldText;
        break;
      case BadgeType.warning:
        bgColor = StitchColors.amberContainer;
        textColor = StitchColors.amberText;
        break;
      case BadgeType.error:
        bgColor = StitchColors.errorContainer;
        textColor = StitchColors.onErrorContainer;
        break;
      case BadgeType.neutral:
        bgColor = StitchColors.surfaceContainerHighest;
        textColor = StitchColors.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: StitchTypography.labelSm.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
