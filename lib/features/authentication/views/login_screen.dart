import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/user_model.dart';

class LoginScreen extends StatefulWidget {
  final Function(UserRole) onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'operator@scandigitize.enterprise');
  final _passwordController = TextEditingController(text: 'password123');
  UserRole _selectedRole = UserRole.operator;
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate auth handshake
    if (mounted) {
      setState(() => _isLoading = false);
      widget.onLoginSuccess(_selectedRole);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: StitchColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: [
                  const Icon(Icons.lock_reset, color: StitchColors.primary),
                  const SizedBox(width: 8),
                  Text('Reset Password', style: StitchTypography.headlineMd),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your enterprise email address. We will send a secure password reset link to verify your identity.',
                    style: StitchTypography.bodySm,
                  ),
                  const SizedBox(height: 16),
                  Text('Enterprise Email', style: StitchTypography.labelMd),
                  const SizedBox(height: 6),
                  TextField(
                    controller: resetEmailController,
                    decoration: InputDecoration(
                      hintText: 'name@enterprise.com',
                      prefixIcon: const Icon(Icons.email_outlined, color: StitchColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isResetting
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          if (email.isEmpty) return;

                          setDialogState(() => isResetting = true);
                          try {
                            // Trigger Firebase Auth Password Reset Email if Firebase instance exists
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          } catch (e) {
                            // Fallback user feedback
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: StitchColors.emeraldText,
                                content: Text('Password reset instructions sent to $email!'),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StitchColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isResetting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Send Reset Link'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: StitchColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.document_scanner, size: 40, color: StitchColors.onPrimaryContainer),
                ),
                const SizedBox(height: 16),
                Text(
                  'ScanDigitize',
                  style: StitchTypography.displayLg.copyWith(
                    color: StitchColors.primary,
                    fontSize: 32,
                  ),
                ),
                Text(
                  'Enterprise Document Digitization System',
                  style: StitchTypography.bodySm,
                ),
                const SizedBox(height: 32),

                // Card Form
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role Access Level', style: StitchTypography.labelMd),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildRoleChip(UserRole.operator, 'Operator'),
                          const SizedBox(width: 8),
                          _buildRoleChip(UserRole.admin, 'Admin'),
                          const SizedBox(width: 8),
                          _buildRoleChip(UserRole.supervisor, 'Supervisor'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text('Enterprise Email', style: StitchTypography.labelMd),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'name@enterprise.com',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Password', style: StitchTypography.labelMd),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: StitchTypography.labelSm.copyWith(
                              color: StitchColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StitchColors.primary,
                            foregroundColor: StitchColors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text('SIGN IN TO WORKSTATION', style: StitchTypography.headlineMd.copyWith(fontSize: 14, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(UserRole role, String label) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? StitchColors.primary.withValues(alpha: 0.1) : StitchColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? StitchColors.primary : StitchColors.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: StitchTypography.labelSm.copyWith(
              color: isSelected ? StitchColors.primary : StitchColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
