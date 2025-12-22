import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SettingsTabWidget extends StatelessWidget {
  final Map<String, dynamic> subscriptionData;
  final ValueChanged<bool> onNotificationToggle;
  final ValueChanged<int> onReminderDaysChanged;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const SettingsTabWidget({
    super.key,
    required this.subscriptionData,
    required this.onNotificationToggle,
    required this.onReminderDaysChanged,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifications =
        subscriptionData["notifications"] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNotificationSection(theme, notifications),
          SizedBox(height: 3.h),
          _buildCategorySection(theme),
          SizedBox(height: 3.h),
          _buildDangerZone(theme, context),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(
    ThemeData theme,
    Map<String, dynamic> notifications,
  ) {
    final enabled = notifications["enabled"] as bool;
    final reminderDays = notifications["reminderDays"] as int;
    final emailNotifications = notifications["emailNotifications"] as bool;
    final pushNotifications = notifications["pushNotifications"] as bool;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSwitchRow(
            theme,
            'Enable Notifications',
            enabled,
            (value) => onNotificationToggle(value),
          ),
          SizedBox(height: 2.h),
          Text(
            'Reminder Timing',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          _buildReminderDaysSelector(theme, reminderDays),
          SizedBox(height: 2.h),
          _buildSwitchRow(
            theme,
            'Email Notifications',
            emailNotifications,
            (value) {},
          ),
          SizedBox(height: 1.5.h),
          _buildSwitchRow(
            theme,
            'Push Notifications',
            pushNotifications,
            (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    ThemeData theme,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildReminderDaysSelector(ThemeData theme, int selectedDays) {
    final days = [1, 3, 5, 7];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: days.map((day) {
        final isSelected = day == selectedDays;
        return InkWell(
          onTap: () => onReminderDaysChanged(day),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              '$day ${day == 1 ? 'day' : 'days'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    final category = subscriptionData["category"] as String;
    final categories = [
      'Entertainment',
      'Productivity',
      'Health',
      'Education',
      'Other',
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: categories.map((cat) {
              final isSelected = cat == category;
              return InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(ThemeData theme, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
            ),
          ),
          SizedBox(height: 2.h),
          _buildDangerButton(
            theme,
            'Archive Subscription',
            'archive',
            () => _showArchiveDialog(context),
          ),
          SizedBox(height: 1.5.h),
          _buildDangerButton(
            theme,
            'Delete Subscription',
            'delete',
            () => _showDeleteDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton(
    ThemeData theme,
    String label,
    String iconName,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: theme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.error,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showArchiveDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Archive Subscription',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to archive this subscription? You can restore it later.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onArchive();
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Subscription',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.error,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this subscription? This action cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
