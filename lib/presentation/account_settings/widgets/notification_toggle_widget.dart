import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/notification_repository.dart';
import '../../../data/services/notification_service.dart';
import '../../subscription_dashboard/viewmodel/dashboard_viewmodel.dart';
import '../../trial_tracker/viewmodel/trial_viewmodel.dart';
import '../viewmodel/account_settings_viewmodel.dart';
import 'settings_section_widget.dart';

/// Widget for toggling push notifications on/off
/// Displays a single switch to enable/disable all notifications
class NotificationToggleWidget extends StatelessWidget {
  const NotificationToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountSettingsViewModel>(
      builder: (context, viewModel, child) {
        return SettingsSectionWidget(
          title: 'Notifications',
          children: [
            SwitchListTile(
              secondary: Icon(
                Icons.notifications_active_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Push Notifications',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Text(
                'Reminders for trials and subscriptions',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: viewModel.isNotificationsEnabled,
              onChanged: viewModel.isSaving
                  ? null
                  : (value) => _handleNotificationToggle(context, viewModel, value),
              activeTrackColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        );
      },
    );
  }

  /// Handle notification toggle with permission request and scheduling
  Future<void> _handleNotificationToggle(
    BuildContext context,
    AccountSettingsViewModel viewModel,
    bool enabled,
  ) async {
    // Update the setting in Supabase first
    await viewModel.updateNotificationsEnabled(enabled);

    final notificationRepo = context.read<NotificationRepository>();

    if (enabled) {
      // Request notification permissions
      final service = NotificationService();
      final granted = await service.requestPermissions();

      if (granted) {
        // Reschedule all notifications with current data
        final trialViewModel = context.read<TrialViewModel>();
        final dashboardViewModel = context.read<DashboardViewModel>();

        await notificationRepo.rescheduleAllNotifications(
          trials: trialViewModel.activeTrials,
          subscriptions: dashboardViewModel.filteredSubscriptions,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications enabled'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Permission denied - revert the toggle
        await viewModel.updateNotificationsEnabled(false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable notifications in system settings'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      // Cancel all notifications
      await notificationRepo.cancelAllNotifications();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications disabled'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
