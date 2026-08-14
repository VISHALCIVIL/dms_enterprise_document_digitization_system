import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';
import '../theme/stitch_typography.dart';

class SideNavItem {
  final String title;
  final IconData icon;
  final String routeName;

  const SideNavItem({
    required this.title,
    required this.icon,
    required this.routeName,
  });
}

class StitchSideNavBar extends StatelessWidget {
  final String currentRoute;
  final Function(String) onItemSelected;

  const StitchSideNavBar({
    super.key,
    required this.currentRoute,
    required this.onItemSelected,
  });

  static const List<SideNavItem> navItems = [
    SideNavItem(title: 'Dashboard', icon: Icons.dashboard, routeName: '/dashboard'),
    SideNavItem(title: 'Projects', icon: Icons.folder_shared_outlined, routeName: '/projects'),
    SideNavItem(title: 'Live Scanning', icon: Icons.document_scanner_outlined, routeName: '/live_scanning'),
    SideNavItem(title: 'Upload Queue', icon: Icons.cloud_upload_outlined, routeName: '/upload_queue'),
    SideNavItem(title: 'Archive', icon: Icons.inventory_2_outlined, routeName: '/archive'),
    SideNavItem(title: 'Statistics & Reports', icon: Icons.leaderboard_outlined, routeName: '/reports'),
    SideNavItem(title: 'Analytics', icon: Icons.analytics_outlined, routeName: '/analytics'),
    SideNavItem(title: 'Settings', icon: Icons.settings_outlined, routeName: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      decoration: const BoxDecoration(
        color: StitchColors.surface,
        border: Border(right: BorderSide(color: StitchColors.outlineVariant, width: 1)),
      ),
      child: Column(
        children: [
          // Branding Header
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ScanDigitize',
                  style: StitchTypography.headlineMd.copyWith(
                    color: StitchColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enterprise Node 04',
                  style: StitchTypography.bodySm,
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Menu List
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = currentRoute == item.routeName;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: () => onItemSelected(item.routeName),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? StitchColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? const Border(left: BorderSide(color: StitchColors.primary, width: 4))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: isSelected ? StitchColors.primary : StitchColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item.title,
                            style: StitchTypography.bodyMd.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? StitchColors.primary : StitchColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Operator Profile Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: StitchColors.outlineVariant, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: StitchColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'OP',
                      style: StitchTypography.labelMd.copyWith(
                        color: StitchColors.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operator Profile',
                      style: StitchTypography.labelMd,
                    ),
                    Text(
                      'Station 1 • Active',
                      style: StitchTypography.bodySm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
