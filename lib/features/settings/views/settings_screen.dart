import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stat_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/services/local_folder_sync_service.dart';
import '../../../core/services/google_drive_service.dart';
import '../../../core/services/github_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalFolderSyncService _folderSyncService = LocalFolderSyncService();
  final GoogleDriveService _driveService = GoogleDriveService.instance;
  final GitHubService _gitHubService = GitHubService();

  final TextEditingController _folderPathController = TextEditingController();
  final TextEditingController _gitHubTokenController = TextEditingController();
  final TextEditingController _serviceAccountController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();

  FolderScanMetrics? _metrics;
  GitHubReleaseInfo? _releaseInfo;

  bool _isLoading = false;
  bool _isSigningInDrive = false;

  String? _statusMessage;
  String? _gitHubStatus;
  String? _driveAuthMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialFolder();
    _loadGitHubIntegration();
    _loadGoogleClientId();
  }

  void _loadGoogleClientId() async {
    final clientId = await _driveService.getClientId();
    _clientIdController.text = clientId;
  }

  void _loadInitialFolder() async {
    setState(() => _isLoading = true);
    final savedPath = await _folderSyncService.getSavedMainFolderPath();
    if (savedPath != null && savedPath.isNotEmpty) {
      _folderPathController.text = savedPath;
      final metrics = await _folderSyncService.scanAndIndexMainFolder();
      if (mounted) {
        setState(() {
          _metrics = metrics;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadGitHubIntegration() async {
    final token = await _gitHubService.getSavedToken();
    if (token != null) {
      _gitHubTokenController.text = token;
    }
    final release = await _gitHubService.getLatestRelease();
    if (mounted) {
      setState(() => _releaseInfo = release);
    }
  }

  void _signInGoogleDrive() async {
    final clientId = _clientIdController.text.trim();
    if (clientId.isNotEmpty) {
      await _driveService.setClientId(clientId);
    }

    setState(() {
      _isSigningInDrive = true;
      _driveAuthMessage = null;
    });

    final success = await _driveService.signInWithGoogle(customClientId: clientId);

    if (mounted) {
      setState(() {
        _isSigningInDrive = false;
        if (success) {
          _driveAuthMessage = 'Google Drive API authenticated as: ${_driveService.authenticatedUserEmail}';
        } else {
          _driveAuthMessage = 'Google Drive Sign-In was cancelled or failed. Verify your Client ID.';
        }
      });
    }
  }

  void _signInServiceAccount() async {
    final jsonStr = _serviceAccountController.text.trim();
    if (jsonStr.isEmpty) return;

    setState(() => _isSigningInDrive = true);
    final success = await _driveService.signInWithServiceAccount(jsonStr);

    if (mounted) {
      setState(() {
        _isSigningInDrive = false;
        if (success) {
          _driveAuthMessage = 'Google Drive Service Account authenticated cleanly!';
        } else {
          _driveAuthMessage = 'Invalid Service Account JSON key string. Please verify key format.';
        }
      });
    }
  }

  void _selectFolder() async {
    try {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        _folderPathController.text = selectedDirectory;
        await _saveAndScanFolder(selectedDirectory);
      }
    } catch (e) {
      setState(() => _statusMessage = 'Folder selection error: $e');
    }
  }

  Future<void> _saveAndScanFolder(String path) async {
    if (path.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _statusMessage = 'Saving folder path & scanning all nested subfolders...';
    });

    await _folderSyncService.setMainFolderPath(path.trim());
    final metrics = await _folderSyncService.scanAndIndexMainFolder();

    if (mounted) {
      setState(() {
        _metrics = metrics;
        _isLoading = false;
        _statusMessage = 'Main folder set successfully! Indexed ${metrics.totalLocalFiles} files across ${metrics.totalSubfolders} subfolders.';
      });
    }
  }

  void _saveGitHubToken() async {
    final token = _gitHubTokenController.text.trim();
    if (token.isEmpty) return;
    await _gitHubService.saveToken(token);
    final release = await _gitHubService.getLatestRelease();
    if (mounted) {
      setState(() {
        _releaseInfo = release;
        _gitHubStatus = 'GitHub Token saved & API handshake verified!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDriveAuth = _driveService.isAuthenticated;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Settings & API Authorization', style: StitchTypography.headlineLg),
          const SizedBox(height: 4),
          Text('Authenticate Google Drive API for live document uploads and configure local sync folders.', style: StitchTypography.bodyMd),
          const SizedBox(height: 24),

          // Google Drive API Authentication Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_sync, color: StitchColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Text('Google Drive API Integration', style: StitchTypography.headlineMd),
                      ],
                    ),
                    StatusBadge(
                      text: isDriveAuth ? 'AUTHENTICATED' : 'NOT AUTHENTICATED',
                      type: isDriveAuth ? BadgeType.success : BadgeType.error,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Authorize your Google Drive account so that scanned documents, OCR text, and searchable PDFs are uploaded automatically to Google Drive in structured folders (Project/Area/Department/Year/Batch).',
                  style: StitchTypography.bodySm,
                ),
                const SizedBox(height: 20),

                Text('Google OAuth Client ID', style: StitchTypography.labelMd),
                const SizedBox(height: 6),
                TextField(
                  controller: _clientIdController,
                  decoration: InputDecoration(
                    hintText: '448747097814-sa70k470t60lfh2lhok2b1h90p9jbljl.apps.googleusercontent.com',
                    prefixIcon: const Icon(Icons.badge_outlined, color: StitchColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isSigningInDrive ? null : _signInGoogleDrive,
                      icon: _isSigningInDrive
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: Text(isDriveAuth ? 'RE-AUTHENTICATE GOOGLE ACCOUNT' : 'SIGN IN WITH GOOGLE DRIVE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StitchColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    if (isDriveAuth && _driveService.authenticatedUserEmail != null) ...[
                      const SizedBox(width: 16),
                      Text(
                        'Account: ${_driveService.authenticatedUserEmail}',
                        style: StitchTypography.labelMd.copyWith(color: StitchColors.emeraldText),
                      ),
                    ],
                  ],
                ),

                if (_driveAuthMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDriveAuth ? StitchColors.emeraldContainer : StitchColors.errorContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDriveAuth ? StitchColors.emerald : StitchColors.error),
                    ),
                    child: Row(
                      children: [
                        Icon(isDriveAuth ? Icons.check_circle : Icons.error, color: isDriveAuth ? StitchColors.emeraldText : StitchColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _driveAuthMessage!,
                            style: StitchTypography.labelMd.copyWith(color: isDriveAuth ? StitchColors.emeraldText : StitchColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                Text('Option 2: Service Account JSON Key (Server-to-Server Silent Sync)', style: StitchTypography.labelMd),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _serviceAccountController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Paste {"type": "service_account", "project_id": ...}',
                          prefixIcon: const Icon(Icons.key_outlined, color: StitchColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _signInServiceAccount,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Text('Apply Key'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Sync Folder Configuration Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_special, color: StitchColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Text('Main Local Sync Folder Location', style: StitchTypography.headlineMd),
                      ],
                    ),
                    const StatusBadge(text: 'LOCAL ARCHIVE', type: BadgeType.primary),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Set the root directory on this machine where scanned files are saved. ScanDigitize recursively monitors all subfolders (Project/Area/Department/Year/Batch).',
                  style: StitchTypography.bodySm,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _folderPathController,
                        decoration: InputDecoration(
                          hintText: 'e.g. C:\\ScanDigitize\\Archive  or  /Users/Documents/Archive',
                          prefixIcon: const Icon(Icons.folder_open, color: StitchColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _selectFolder,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Browse Folder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StitchColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _saveAndScanFolder(_folderPathController.text),
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Save & Scan All Subfolders'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StitchColors.primaryContainer,
                        foregroundColor: StitchColors.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),

                if (_statusMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: StitchColors.emeraldContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: StitchColors.emerald),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: StitchColors.emeraldText, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            style: StitchTypography.labelMd.copyWith(color: StitchColors.emeraldText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // GitHub Integration & CI Build Monitor Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.code, color: StitchColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Text('GitHub API & CI/CD Integration', style: StitchTypography.headlineMd),
                      ],
                    ),
                    const StatusBadge(text: 'VISHALCIVIL Repository', type: BadgeType.success),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Connected to repository: VISHALCIVIL/dms_enterprise_document_digitization_system.',
                  style: StitchTypography.bodySm,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _gitHubTokenController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                          prefixIcon: const Icon(Icons.key, color: StitchColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _saveGitHubToken,
                      icon: const Icon(Icons.cloud_done, size: 18),
                      label: const Text('Save Token'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StitchColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),

                if (_gitHubStatus != null) ...[
                  const SizedBox(height: 14),
                  Text(_gitHubStatus!, style: StitchTypography.labelMd.copyWith(color: StitchColors.emeraldText)),
                ],

                if (_releaseInfo != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StitchColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: StitchColors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Latest Release: ${_releaseInfo!.tagName}', style: StitchTypography.labelMd),
                            Text(_releaseInfo!.releaseName, style: StitchTypography.bodySm),
                          ],
                        ),
                        const StatusBadge(text: 'AUTOMATED CI BUILD', type: BadgeType.primary),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Folder Metrics Card Grid
          if (_metrics != null) ...[
            Text('Main Folder Scan & Sync Summary', style: StitchTypography.headlineMd),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                StatWidget(label: 'Total Subfolders', value: _metrics!.totalSubfolders.toString()),
                StatWidget(label: 'Total Files Count', value: _metrics!.totalLocalFiles.toString()),
                StatWidget(label: 'Total Pages Count', value: _metrics!.totalPagesCount.toString()),
                StatWidget(label: 'Synced Files', value: _metrics!.syncedCount.toString()),
                StatWidget(label: 'Pending Google Drive Sync', value: _metrics!.pendingSyncCount.toString(), isError: _metrics!.pendingSyncCount > 0),
                StatWidget(label: 'Root Path Configured', value: _metrics!.mainFolderPath.isNotEmpty ? 'Active' : 'Not Set'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
