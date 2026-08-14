import 'package:flutter/material.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../services/report_exporter_service.dart';

class AreaReportsScreen extends StatefulWidget {
  const AreaReportsScreen({super.key});

  @override
  State<AreaReportsScreen> createState() => _AreaReportsScreenState();
}

class _AreaReportsScreenState extends State<AreaReportsScreen> {
  final ReportExporterService _exporter = ReportExporterService();
  bool _isExporting = false;

  static const List<AreaReportData> sampleAreas = [
    AreaReportData(areaName: 'Umred', zone: 'Zone Alpha', filesProcessed: 125, totalPages: 18450, syncPercentage: 1.0),
    AreaReportData(areaName: 'Wani', zone: 'Zone Beta', filesProcessed: 98, totalPages: 15220, syncPercentage: 0.85),
    AreaReportData(areaName: 'Majri', zone: 'Zone Gamma', filesProcessed: 76, totalPages: 11850, syncPercentage: 1.0),
  ];

  void _exportPdf() async {
    setState(() => _isExporting = true);
    final file = await _exporter.generatePdfReport(dateStr: '14 August 2026', areas: sampleAreas);
    if (mounted) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Report generated: ${file.path}')),
      );
    }
  }

  void _exportExcel() async {
    setState(() => _isExporting = true);
    final file = await _exporter.generateExcelReport(dateStr: '14 August 2026', areas: sampleAreas);
    if (mounted) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel Report generated: ${file.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
                  Text('Area-wise Report', style: StitchTypography.headlineLg),
                  const SizedBox(height: 4),
                  Text('Real-time synchronization status across operational zones.', style: StitchTypography.bodyMd),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _isExporting ? null : _exportExcel,
                    icon: const Icon(Icons.table_chart_outlined, size: 18),
                    label: const Text('Export Excel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportPdf,
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Export PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchColors.primary,
                      foregroundColor: StitchColors.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bento Grid for Operational Areas
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 1.3 : 1.6,
                ),
                itemCount: sampleAreas.length,
                itemBuilder: (context, index) {
                  final area = sampleAreas[index];
                  return _buildAreaBentoCard(area);
                },
              );
            },
          ),
          const SizedBox(height: 32),

          // Aggregate Total Bar
          AppCard(
            backgroundColor: StitchColors.primary.withValues(alpha: 0.04),
            border: Border.all(color: StitchColors.primary.withValues(alpha: 0.2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL OPERATIONAL SUMMARY', style: StitchTypography.labelMd.copyWith(letterSpacing: 1, color: StitchColors.primary)),
                Row(
                  children: [
                    Text('299 Files Processed', style: StitchTypography.headlineMd.copyWith(fontSize: 16)),
                    const SizedBox(width: 24),
                    Text('45,520 Pages Total', style: StitchTypography.headlineMd.copyWith(color: StitchColors.primary, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaBentoCard(AreaReportData area) {
    final syncInt = (area.syncPercentage * 100).toInt();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(area.areaName, style: StitchTypography.headlineMd),
                  Text(area.zone, style: StitchTypography.labelSm.copyWith(letterSpacing: 1)),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: StitchColors.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_city, color: StitchColors.primary),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: StitchColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: StitchColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Files Processed', style: StitchTypography.labelSm),
                      Text(area.filesProcessed.toString(), style: StitchTypography.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: StitchColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: StitchColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Pages', style: StitchTypography.labelSm),
                      Text(area.totalPages.toString(), style: StitchTypography.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Synced', style: StitchTypography.labelSm),
                  Text('$syncInt%', style: StitchTypography.labelMd.copyWith(color: StitchColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: area.syncPercentage,
                  minHeight: 6,
                  backgroundColor: StitchColors.surfaceContainerHigh,
                  valueColor: const AlwaysStoppedAnimation<Color>(StitchColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
