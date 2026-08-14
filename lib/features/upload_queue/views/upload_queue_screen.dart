import 'package:flutter/material.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/database/sqlite_database_service.dart';

class UploadQueueScreen extends StatefulWidget {
  const UploadQueueScreen({super.key});

  @override
  State<UploadQueueScreen> createState() => _UploadQueueScreenState();
}

class _UploadQueueScreenState extends State<UploadQueueScreen> {
  final SqliteDatabaseService _sqlite = SqliteDatabaseService.instance;
  List<Map<String, dynamic>> _pendingFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  void _loadQueue() async {
    setState(() => _isLoading = true);
    final files = await _sqlite.getAllFiles();
    if (mounted) {
      setState(() {
        _pendingFiles = files;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upload Queue & Sync Manager', style: StitchTypography.headlineLg),
                  const SizedBox(height: 4),
                  Text('SQLite offline queue status and background synchronization monitor.', style: StitchTypography.bodyMd),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _loadQueue,
                icon: const Icon(Icons.sync, size: 18),
                label: const Text('Refresh Queue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StitchColors.primary,
                  foregroundColor: StitchColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_pendingFiles.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 48, color: StitchColors.emerald),
                    const SizedBox(height: 12),
                    Text('All Scanned Documents Fully Synced!', style: StitchTypography.headlineMd),
                    const SizedBox(height: 4),
                    Text('There are no pending documents in local SQLite storage.', style: StitchTypography.bodySm),
                  ],
                ),
              ),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pendingFiles.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final row = _pendingFiles[index];
                  final status = row['upload_status'] ?? 'PENDING';
                  BadgeType bType;
                  if (status == 'COMPLETED') {
                    bType = BadgeType.success;
                  } else if (status == 'FAILED') {
                    bType = BadgeType.error;
                  } else {
                    bType = BadgeType.warning;
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: StitchColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: StitchColors.primary),
                    ),
                    title: Text(row['file_name'] ?? 'Document.pdf', style: StitchTypography.labelMd),
                    subtitle: Text(
                      'Batch: ${row['batch_id']} • Pages: ${row['page_count']} • Local: ${row['local_path']}',
                      style: StitchTypography.bodySm,
                    ),
                    trailing: StatusBadge(text: status, type: bType),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
