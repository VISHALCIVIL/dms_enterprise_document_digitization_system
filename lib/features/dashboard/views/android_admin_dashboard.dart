import 'package:flutter/material.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stat_widget.dart';
import '../../../core/widgets/status_badge.dart';

class AndroidAdminDashboard extends StatelessWidget {
  final VoidCallback onNewBatchPressed;

  const AndroidAdminDashboard({super.key, required this.onNewBatchPressed});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DAILY SCANNING', style: StitchTypography.labelSm.copyWith(letterSpacing: 1.2)),
                  const SizedBox(height: 2),
                  Text('14 August 2026', style: StitchTypography.headlineLgMobile),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onNewBatchPressed,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Batch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StitchColors.primary,
                  foregroundColor: StitchColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2x2 Grid Stats for Mobile
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: const [
              StatWidget(label: 'Files Scanned', value: '299'),
              StatWidget(label: 'Total Pages', value: '45,520'),
              StatWidget(label: 'Uploaded', value: '44,980'),
              StatWidget(label: 'Pending Sync', value: '540', isError: true),
            ],
          ),
          const SizedBox(height: 20),

          // Active Operators Card
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: StitchColors.outlineVariant, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active Operators', style: StitchTypography.headlineMd),
                      const StatusBadge(text: '4 Online', type: BadgeType.primary),
                    ],
                  ),
                ),
                _buildOperatorRow('JD', 'John Doe', 'Station 1', 'Scanning', isScanning: true),
                const Divider(),
                _buildOperatorRow('SA', 'Sarah Allen', 'Station 3', 'Scanning', isScanning: true),
                const Divider(),
                _buildOperatorRow('MK', 'Mike Kim', 'Station 2', 'Idle', isScanning: false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Urgent Alerts Card
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: StitchColors.error),
                    const SizedBox(width: 8),
                    Text('Recent Alerts', style: StitchTypography.headlineMd),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: StitchColors.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(left: BorderSide(color: StitchColors.error, width: 4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Upload Failed', style: StitchTypography.labelMd),
                      const SizedBox(height: 4),
                      Text('Batch #402 encountered a sync error at 10:42 AM.', style: StitchTypography.bodySm),
                      const SizedBox(height: 6),
                      Text('Retry Upload', style: StitchTypography.labelSm.copyWith(color: StitchColors.error, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorRow(String initials, String name, String station, String status, {required bool isScanning}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isScanning ? StitchColors.secondaryContainer : StitchColors.surfaceVariant,
                child: Text(initials, style: StitchTypography.labelSm.copyWith(color: StitchColors.onSecondaryContainer, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: StitchTypography.labelMd),
                  Text(station, style: StitchTypography.bodySm),
                ],
              ),
            ],
          ),
          StatusBadge(
            text: status,
            type: isScanning ? BadgeType.primary : BadgeType.neutral,
          ),
        ],
      ),
    );
  }
}
