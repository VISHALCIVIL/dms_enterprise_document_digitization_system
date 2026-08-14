import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stat_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/database/sqlite_database_service.dart';
import '../../../core/services/google_drive_service.dart';
import '../../../core/services/sync_manager.dart';

class UploadQueueScreen extends StatefulWidget {
  const UploadQueueScreen({super.key});

  @override
  State<UploadQueueScreen> createState() => _UploadQueueScreenState();
}

class _UploadQueueScreenState extends State<UploadQueueScreen> {
  final SqliteDatabaseService _sqlite = SqliteDatabaseService.instance;
  late final SyncManager _syncManager;

  List<Map<String, dynamic>> _pendingFiles = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;
  bool _isDriveUnconfigured = false;

  @override
  void initState() {
    super.initState();
    _syncManager = SyncManager(driveService: GoogleDriveService());
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

  void _triggerGoogleSync() async {
    setState(() {
      _isSyncing = true;
      _errorMessage = null;
      _isDriveUnconfigured = false;
    });

    final syncResult = await _syncManager.syncPendingQueue(force: true);
    final updatedFiles = await _sqlite.getAllFiles();

    if (mounted) {
      setState(() {
        _pendingFiles = updatedFiles;
        _isSyncing = false;
        if (syncResult.isUnconfigured) {
          _isDriveUnconfigured = true;
          _errorMessage = syncResult.errorMessage ?? 'Google Drive API Integration is not configured or authenticated. No data was uploaded to Google Drive.';
          _showErrorPromptDialog(_errorMessage!);
        } else if (syncResult.failedCount > 0) {
          _errorMessage = syncResult.errorMessage ?? 'Google Drive synchronization failed for ${syncResult.failedCount} file(s).';
          _showErrorPromptDialog(_errorMessage!);
        }
      });
    }
  }

  void _showErrorPromptDialog(String errorMsg) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: StitchColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: StitchColors.error, size: 28),
              const SizedBox(width: 10),
              Text('Google Drive Sync Error', style: StitchTypography.headlineMd.copyWith(color: StitchColors.error)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: StitchColors.errorContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: StitchColors.errorContainer),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off, color: StitchColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'NO DATA WAS UPLOADED TO GOOGLE DRIVE!',
                        style: StitchTypography.labelMd.copyWith(color: StitchColors.error, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                errorMsg,
                style: StitchTypography.bodySm,
              ),
              const SizedBox(height: 12),
              Text(
                'Please configure your Google OAuth Client ID & Secret in Settings or complete authorization to enable Google Drive file uploads.',
                style: StitchTypography.bodySm.copyWith(color: StitchColors.outline),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.go('/settings');
              },
              icon: const Icon(Icons.settings),
              label: const Text('Configure Google Drive API'),
              style: ElevatedButton.styleFrom(
                backgroundColor: StitchColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalCount = _pendingFiles.length;
    int pendingCount = _pendingFiles.where((f) => f['sync_status'] != 'FULLY_SYNCED').length;
    int syncedCount = _pendingFiles.where((f) => f['sync_status'] == 'FULLY_SYNCED').length;

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
                  Text('Upload Queue & Google Drive Sync Manager', style: StitchTypography.headlineLg),
                  const SizedBox(height: 4),
                  Text('Local SQLite offline queue status and real-time Google Drive synchronization engine.', style: StitchTypography.bodyMd),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _loadQueue,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh Queue'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _triggerGoogleSync,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload, size: 18),
                    label: Text(_isSyncing ? 'Syncing Drive...' : 'SYNC TO GOOGLE DRIVE NOW'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchColors.primary,
                      foregroundColor: StitchColors.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary Stats Cards
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              StatWidget(label: 'Total Queue Documents', value: totalCount.toString()),
              StatWidget(label: 'Pending Google Drive Sync', value: pendingCount.toString(), isError: pendingCount > 0),
              StatWidget(label: 'Fully Synced Documents', value: syncedCount.toString()),
            ],
          ),
          const SizedBox(height: 20),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: StitchColors.errorContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: StitchColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: StitchColors.error, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GOOGLE DRIVE API INTEGRATION ERROR:', style: StitchTypography.labelMd.copyWith(color: StitchColors.error, fontWeight: FontWeight.bold)),
                        Text(_errorMessage!, style: StitchTypography.bodySm.copyWith(color: StitchColors.error)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.go('/settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Configure API'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_pendingFiles.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.cloud_done, size: 48, color: StitchColors.emerald),
                    const SizedBox(height: 12),
                    Text('No Scanned Files in Queue', style: StitchTypography.headlineMd),
                    const SizedBox(height: 4),
                    Text('Start live scanning or select your Main Local Sync Folder in Settings to populate files.', style: StitchTypography.bodySm),
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
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final row = _pendingFiles[index];
                  final syncStatus = row['sync_status'] ?? 'LOCAL_ONLY';
                  final driveFileId = row['google_drive_file_id'] ?? '';

                  BadgeType bType;
                  String badgeText;

                  if (syncStatus == 'FULLY_SYNCED') {
                    bType = BadgeType.success;
                    badgeText = 'GOOGLE DRIVE SYNCED';
                  } else if (syncStatus == 'NOT_CONFIGURED') {
                    bType = BadgeType.error;
                    badgeText = 'API NOT CONFIGURD';
                  } else if (syncStatus == 'SYNC_ERROR') {
                    bType = BadgeType.error;
                    badgeText = 'SYNC FAILED';
                  } else {
                    bType = BadgeType.warning;
                    badgeText = 'PENDING SYNC';
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: syncStatus == 'FULLY_SYNCED'
                            ? StitchColors.emeraldContainer
                            : (syncStatus == 'NOT_CONFIGURED' || syncStatus == 'SYNC_ERROR'
                                ? StitchColors.errorContainer.withValues(alpha: 0.3)
                                : StitchColors.surfaceContainerLow),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        syncStatus == 'FULLY_SYNCED'
                            ? Icons.cloud_done
                            : (syncStatus == 'NOT_CONFIGURED' || syncStatus == 'SYNC_ERROR'
                                ? Icons.cloud_off
                                : Icons.picture_as_pdf),
                        color: syncStatus == 'FULLY_SYNCED'
                            ? StitchColors.emeraldText
                            : (syncStatus == 'NOT_CONFIGURED' || syncStatus == 'SYNC_ERROR'
                                ? StitchColors.error
                                : StitchColors.primary),
                      ),
                    ),
                    title: Text(row['file_name'] ?? 'Document.pdf', style: StitchTypography.labelMd),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          'Batch: ${row['batch_id']} • Project: ${row['project_id']} • Pages: ${row['page_count']}',
                          style: StitchTypography.bodySm,
                        ),
                        Text(
                          'Local Path: ${row['local_path']}',
                          style: StitchTypography.bodySm.copyWith(color: StitchColors.outline),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (driveFileId.isNotEmpty)
                          Text(
                            'Google Drive File ID: $driveFileId',
                            style: StitchTypography.labelSm.copyWith(color: StitchColors.emeraldText),
                          ),
                      ],
                    ),
                    trailing: StatusBadge(text: badgeText, type: bType),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
