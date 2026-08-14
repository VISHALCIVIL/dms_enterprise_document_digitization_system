import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';
import '../theme/stitch_typography.dart';
import 'status_badge.dart';

class BatchRowData {
  final String batchId;
  final String operatorName;
  final int pages;
  final String status; // PROCESSING, FAILED, COMPLETED

  const BatchRowData({
    required this.batchId,
    required this.operatorName,
    required this.pages,
    required this.status,
  });
}

class EnterpriseDataTable extends StatelessWidget {
  final List<BatchRowData> rows;

  const EnterpriseDataTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StitchColors.outlineVariant, width: 1),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: StitchColors.surfaceContainerLow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: StitchColors.outlineVariant, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Batch ID', style: StitchTypography.labelMd.copyWith(color: StitchColors.onSurfaceVariant))),
                Expanded(flex: 3, child: Text('Operator', style: StitchTypography.labelMd.copyWith(color: StitchColors.onSurfaceVariant))),
                Expanded(flex: 2, child: Text('Pages', style: StitchTypography.labelMd.copyWith(color: StitchColors.onSurfaceVariant))),
                Expanded(flex: 2, child: Text('Status', style: StitchTypography.labelMd.copyWith(color: StitchColors.onSurfaceVariant))),
              ],
            ),
          ),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final row = rows[index];
              BadgeType bType;
              if (row.status == 'PROCESSING') {
                bType = BadgeType.primary;
              } else if (row.status == 'FAILED') {
                bType = BadgeType.error;
              } else {
                bType = BadgeType.neutral;
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.batchId,
                        style: StitchTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.operatorName,
                        style: StitchTypography.bodyMd.copyWith(color: StitchColors.onSurfaceVariant),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.pages.toString(),
                        style: StitchTypography.bodyMd,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: StatusBadge(text: row.status, type: bType),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
