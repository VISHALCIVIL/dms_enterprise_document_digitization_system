import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';
import '../theme/stitch_typography.dart';
import '../services/google_drive_service.dart';

class StitchTopAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onAccountPressed;

  const StitchTopAppBar({
    super.key,
    this.title = 'ScanDigitize Enterprise',
    this.onNotificationsPressed,
    this.onAccountPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<StitchTopAppBar> createState() => _StitchTopAppBarState();
}

class _StitchTopAppBarState extends State<StitchTopAppBar> {
  final GoogleDriveService _driveService = GoogleDriveService.instance;
  bool _isSigningIn = false;

  void _handleDriveSignIn() async {
    setState(() => _isSigningIn = true);
    final success = await _driveService.signInWithGoogle();
    if (mounted) {
      setState(() => _isSigningIn = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: success ? StitchColors.emeraldText : StitchColors.error,
          content: Text(
            success
                ? 'Google Drive Authenticated as ${_driveService.authenticatedUserEmail}!'
                : 'Google Drive Sign-In was cancelled or failed.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAuth = _driveService.isAuthenticated;
    final String? userEmail = _driveService.authenticatedUserEmail;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: StitchColors.surface,
        border: Border(bottom: BorderSide(color: StitchColors.outlineVariant, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: StitchTypography.headlineMd.copyWith(
              fontWeight: FontWeight.w800,
              color: StitchColors.primary,
            ),
          ),
          Row(
            children: [
              // Google Drive Sign-In Quick Action Button / Status Badge
              if (isAuth)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: StitchColors.emeraldContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: StitchColors.emerald),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_done, color: StitchColors.emeraldText, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        userEmail != null ? 'Drive: $userEmail' : 'Drive Connected',
                        style: StitchTypography.labelSm.copyWith(color: StitchColors.emeraldText, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _isSigningIn ? null : _handleDriveSignIn,
                  icon: _isSigningIn
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_queue, size: 16),
                  label: const Text('Sign In to Google Drive'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StitchColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    textStyle: StitchTypography.labelSm,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              const SizedBox(width: 16),

              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: StitchColors.onSurfaceVariant),
                onPressed: widget.onNotificationsPressed,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, color: StitchColors.onSurfaceVariant),
                onPressed: widget.onAccountPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
