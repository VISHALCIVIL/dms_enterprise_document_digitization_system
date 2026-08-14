import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';
import '../theme/stitch_typography.dart';

class StitchTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onAccountPressed;

  const StitchTopAppBar({
    super.key,
    this.title = 'ScanDigitize Admin',
    this.onNotificationsPressed,
    this.onAccountPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: StitchColors.surface,
        border: Border(bottom: BorderSide(color: StitchColors.outlineVariant, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: StitchTypography.headlineMd.copyWith(
              fontWeight: FontWeight.w800,
              color: StitchColors.primary,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: StitchColors.onSurfaceVariant),
                onPressed: onNotificationsPressed,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, color: StitchColors.onSurfaceVariant),
                onPressed: onAccountPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
