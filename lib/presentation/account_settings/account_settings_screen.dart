import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_bar.dart';
import 'viewmodel/account_settings_viewmodel.dart';
import 'widgets/account_actions_widget.dart';
import 'widgets/app_preferences_widget.dart';
import 'widgets/notification_toggle_widget.dart';
import 'widgets/profile_header_widget.dart';

/// Account Settings Screen
/// Displays user profile, settings, and account actions
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure settings are loaded when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<AccountSettingsViewModel>();
      if (viewModel.settings == null) {
        viewModel.loadSettings();
      }
    });
  }

  void _handleBottomNavTap(BuildContext context, CustomBottomBarItem item) {
    switch (item) {
      case CustomBottomBarItem.dashboard:
        Navigator.pushReplacementNamed(context, '/subscription-dashboard');
        break;
      case CustomBottomBarItem.trials:
        Navigator.pushReplacementNamed(context, '/trial-tracker');
        break;
      case CustomBottomBarItem.account:
        // Already on account settings
        break;
      case CustomBottomBarItem.analytics:
        Navigator.pushReplacementNamed(context, '/analytics');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountSettingsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Account Settings'),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: _buildBody(viewModel),
          bottomNavigationBar: CustomBottomBar(
            currentItem: CustomBottomBarItem.account,
            onItemSelected: (item) => _handleBottomNavTap(context, item),
          ),
        );
      },
    );
  }

  Widget _buildBody(AccountSettingsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.status == AccountSettingsStatus.error) {
      return _buildErrorState(viewModel);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header Section
          const ProfileHeaderWidget(),

          const SizedBox(height: AppTheme.spacingMedium),

          // Notification Preferences Section
          const NotificationToggleWidget(),

          const SizedBox(height: AppTheme.spacingMedium),

          // App Preferences Section (Theme, Currency)
          const AppPreferencesWidget(),

          const SizedBox(height: AppTheme.spacingMedium),

          // Account Management Section (Logout)
          const AccountActionsWidget(),

          const SizedBox(height: AppTheme.spacingXLarge),
        ],
      ),
    );
  }

  Widget _buildErrorState(AccountSettingsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Failed to load settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              viewModel.errorMessage ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            ElevatedButton.icon(
              onPressed: () => viewModel.loadSettings(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
