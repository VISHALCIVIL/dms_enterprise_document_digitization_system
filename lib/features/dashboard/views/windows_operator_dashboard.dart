import 'package:flutter/material.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stat_widget.dart';
import '../../../core/widgets/enterprise_table.dart';
import '../../../core/widgets/status_badge.dart';

class WindowsOperatorDashboard extends StatelessWidget {
  final VoidCallback onNewBatchPressed;

  const WindowsOperatorDashboard({super.key, required this.onNewBatchPressed});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
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
                  Text('DAILY SCANNING WORKSTATION', style: StitchTypography.labelSm.copyWith(letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text('14 August 2026', style: StitchTypography.headlineLg),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onNewBatchPressed,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Batch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StitchColors.primary,
                  foregroundColor: StitchColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Compact Stats Grid
          Row(
            children: const [
              Expanded(child: StatWidget(label: 'Files Scanned', value: '299')),
              SizedBox(width: 16),
              Expanded(child: StatWidget(label: 'Total Pages', value: '45,520')),
              SizedBox(width: 16),
              Expanded(child: StatWidget(label: 'Uploaded', value: '44,980')),
              SizedBox(width: 16),
              Expanded(child: StatWidget(label: 'Pending Sync', value: '540', isError: true)),
            ],
          ),
          const SizedBox(height: 24),

          // Grid Layout: Active Operators & Alerts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Operators Card
              Expanded(
                flex: 2,
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      _buildOperatorItem('JD', 'John Doe', 'Station 1', 'Scanning', isScanning: true),
                      const Divider(),
                      _buildOperatorItem('SA', 'Sarah Allen', 'Station 3', 'Scanning', isScanning: true),
                      const Divider(),
                      _buildOperatorItem('MK', 'Mike Kim', 'Station 2', 'Idle', isScanning: false),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Recent Alerts Card
              Expanded(
                flex: 1,
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: StitchColors.outlineVariant, width: 1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: StitchColors.error),
                            const SizedBox(width: 8),
                            Text('Recent Alerts', style: StitchTypography.headlineMd),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  const SizedBox(height: 8),
                                  Text('Retry Upload', style: StitchTypography.labelSm.copyWith(color: StitchColors.error, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: StitchColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: StitchColors.outlineVariant),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Storage Warning', style: StitchTypography.labelMd),
                                  const SizedBox(height: 4),
                                  Text('Local cache for Node 04 is nearing 90% capacity.', style: StitchTypography.bodySm),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Batches Table Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Batches', style: StitchTypography.headlineMd),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 12),
          const EnterpriseDataTable(
            rows: [
              BatchRowData(batchId: '#B-403', operatorName: 'Sarah Allen', pages: 1250, status: 'PROCESSING'),
              BatchRowData(batchId: '#B-402', operatorName: 'John Doe', pages: 840, status: 'FAILED'),
              BatchRowData(batchId: '#B-401', operatorName: 'Mike Kim', pages: 3100, status: 'COMPLETED'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorItem(String initials, String name, String station, String statusText, {required bool isScanning}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isScanning ? StitchColors.secondaryContainer : StitchColors.surfaceVariant,
                child: Text(initials, style: StitchTypography.labelMd.copyWith(color: StitchColors.onSecondaryContainer)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: StitchTypography.labelMd),
                  Text(station, style: StitchTypography.bodySm),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isScanning ? StitchColors.primary : StitchColors.outline,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusText.toUpperCase(),
                style: StitchTypography.labelSm.copyWith(
                  color: isScanning ? StitchColors.primary : StitchColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
