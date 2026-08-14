import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';
import '../theme/stitch_typography.dart';
import 'app_card.dart';

class StatWidget extends StatelessWidget {
  final String label;
  final String value;
  final bool isError;
  final Color? customTextColor;

  const StatWidget({
    super.key,
    required this.label,
    required this.value,
    this.isError = false,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isError ? StitchColors.errorContainer : StitchColors.outlineVariant;
    final bgColor = isError ? StitchColors.errorContainer.withOpacity(0.1) : StitchColors.surface;
    final labelColor = isError ? StitchColors.error : StitchColors.onSurfaceVariant;
    final valueColor = customTextColor ?? (isError ? StitchColors.error : StitchColors.primary);

    return AppCard(
      backgroundColor: bgColor,
      border: Border.all(color: borderColor, width: 1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: StitchTypography.labelMd.copyWith(color: labelColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: StitchTypography.displayLg.copyWith(
              color: valueColor,
              fontSize: 28,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
