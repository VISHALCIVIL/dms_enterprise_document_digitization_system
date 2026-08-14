import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';
import '../theme/stitch_typography.dart';

class PipelineProgressBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final double progress; // 0.0 to 1.0

  const PipelineProgressBar({
    super.key,
    required this.label,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress.clamp(0.0, 1.0) * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: StitchColors.onSurface),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: StitchTypography.labelSm.copyWith(
                    color: StitchColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '$percentage%',
              style: StitchTypography.labelSm.copyWith(
                color: StitchColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: StitchColors.surfaceContainerHigh,
            valueColor: const AlwaysStoppedAnimation<Color>(StitchColors.primary),
          ),
        ),
      ],
    );
  }
}
