import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                'Enable all push notifications',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: viewModel.isNotificationsEnabled,
              onChanged: viewModel.isSaving
                  ? null
                  : (value) => viewModel.updateNotificationsEnabled(value),
              activeTrackColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        );
      },
    );
  }
}
