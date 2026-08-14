import 'package:flutter/material.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/laser_scan_overlay.dart';
import '../../../core/widgets/progress_bar_animated.dart';
import '../../../core/services/scanner_service.dart';

class LiveScanningScreen extends StatefulWidget {
  const LiveScanningScreen({super.key});

  @override
  State<LiveScanningScreen> createState() => _LiveScanningScreenState();
}

class _LiveScanningScreenState extends State<LiveScanningScreen> {
  final MockScannerService _scannerService = MockScannerService();
  late ScannerState _scannerState;

  @override
  void initState() {
    super.initState();
    _scannerState = _scannerService.currentState;
    _scannerService.stateStream.listen((state) {
      if (mounted) {
        setState(() => _scannerState = state);
      }
    });
  }

  void _toggleScan() {
    if (_scannerState.state == ScannerStatusState.scanning) {
      _scannerService.pauseScan();
    } else {
      _scannerService.startScan(batchId: 'BATCH-AUG-042');
    }
  }

  void _stopScan() {
    _scannerService.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    final bool isScanning = _scannerState.state == ScannerStatusState.scanning;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;

        return Padding(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel: Document Preview Canvas
              Expanded(
                flex: isDesktop ? 2 : 0,
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: StitchColors.surfaceContainerLowest,
                          border: Border(bottom: BorderSide(color: StitchColors.outlineVariant, width: 1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.document_scanner, color: StitchColors.primary),
                                const SizedBox(width: 8),
                                Text('Live Preview', style: StitchTypography.headlineMd),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(icon: const Icon(Icons.zoom_out, size: 18), onPressed: () {}),
                                Text('100%', style: StitchTypography.labelMd),
                                IconButton(icon: const Icon(Icons.zoom_in, size: 18), onPressed: () {}),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: isDesktop ? 520 : 320,
                        color: StitchColors.surfaceContainerLow,
                        alignment: Alignment.center,
                        child: LaserScanOverlay(
                          child: Container(
                            width: isDesktop ? 360 : 220,
                            height: isDesktop ? 480 : 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                              ],
                              border: Border.all(color: StitchColors.outlineVariant),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(height: 24, width: 140, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Container(height: 12, width: double.infinity, color: Colors.grey[200]),
                                  const SizedBox(height: 6),
                                  Container(height: 12, width: double.infinity, color: Colors.grey[200]),
                                  const SizedBox(height: 6),
                                  Container(height: 12, width: 200, color: Colors.grey[200]),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(height: 40, width: 100, color: Colors.grey[300]),
                                      Container(height: 40, width: 40, color: Colors.grey[400]),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 16),

              // Right Panel: System Controls & Pipeline Progress
              SizedBox(
                width: isDesktop ? 380 : double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Status Card
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SYSTEM STATUS', style: StitchTypography.labelSm.copyWith(letterSpacing: 1)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: StitchColors.emerald,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_scannerState.deviceName, style: StitchTypography.labelMd),
                                ],
                              ),
                              const StatusBadge(text: 'CONNECTED', type: BadgeType.success),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.2,
                            children: [
                              _buildMetricBox('Current Batch', 'BATCH-AUG-042', isPrimary: true),
                              _buildMetricBox('Speed', '${_scannerState.speedPpm} PPM'),
                              _buildMetricBox('File', '${_scannerState.currentFileIndex} / ${_scannerState.currentBatchTotalFiles}'),
                              _buildMetricBox('Total Pages', '${_scannerState.currentFilePages} / 18,450'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scanner Action Buttons
                    AppCard(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _toggleScan,
                              icon: Icon(isScanning ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 24),
                              label: Text(
                                isScanning ? 'PAUSE SCAN' : 'START SCAN',
                                style: StitchTypography.headlineMd.copyWith(color: Colors.white, fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: StitchColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: isScanning ? _toggleScan : null,
                                  icon: const Icon(Icons.pause_circle_outline, size: 18),
                                  label: const Text('Pause'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _stopScan,
                                  icon: const Icon(Icons.stop_circle_outlined, size: 18, color: StitchColors.error),
                                  label: Text('Stop', style: TextStyle(color: StitchColors.error)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(color: StitchColors.errorContainer),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Multi-Stage Pipeline Progress
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PIPELINE PROGRESS', style: StitchTypography.labelSm.copyWith(letterSpacing: 1)),
                          const SizedBox(height: 16),
                          PipelineProgressBar(
                            label: 'Scanning',
                            icon: Icons.document_scanner_outlined,
                            progress: _scannerState.scanningProgress,
                          ),
                          const SizedBox(height: 14),
                          const PipelineProgressBar(
                            label: 'OCR Processing',
                            icon: Icons.translate_outlined,
                            progress: 0.65,
                          ),
                          const SizedBox(height: 14),
                          const PipelineProgressBar(
                            label: 'PDF Generation',
                            icon: Icons.picture_as_pdf_outlined,
                            progress: 0.90,
                          ),
                          const SizedBox(height: 14),
                          const PipelineProgressBar(
                            label: 'Drive Upload',
                            icon: Icons.cloud_upload_outlined,
                            progress: 0.72,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricBox(String label, String val, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: StitchColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: StitchTypography.labelSm),
          Text(
            val,
            style: StitchTypography.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              color: isPrimary ? StitchColors.primary : StitchColors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
