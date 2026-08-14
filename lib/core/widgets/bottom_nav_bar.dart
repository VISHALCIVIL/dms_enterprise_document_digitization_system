import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';
import '../theme/stitch_typography.dart';

class StitchBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const StitchBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StitchColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.analytics, 'Dashboard'),
              _buildNavItem(1, Icons.file_open_outlined, 'Reports'),
              _buildNavItem(2, Icons.notifications_outlined, 'Alerts', hasBadge: true),
              _buildNavItem(3, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool hasBadge = false}) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? StitchColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: isSelected ? StitchColors.onPrimaryContainer : StitchColors.onSurfaceVariant,
                ),
                if (hasBadge)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: StitchColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: StitchTypography.labelSm.copyWith(
                color: isSelected ? StitchColors.onPrimaryContainer : StitchColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
