import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import 'settings_section_widget.dart';

/// Widget for account actions (logout)
/// Displays a logout button with confirmation dialog
class AccountActionsWidget extends StatelessWidget {
  const AccountActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return SettingsSectionWidget(
          title: 'Account',
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authViewModel.isLoading
                      ? null
                      : () => _showLogoutDialog(context, authViewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: authViewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: AppTheme.spacingSmall),
                            Text('Logout'),
                          ],
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await authViewModel.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login-screen');
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
