import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Quick actions bar for batch operations
class QuickActionsBarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancelAll;
  final VoidCallback onRemindAll;

  const QuickActionsBarWidget({
    super.key,
    required this.selectedCount,
    required this.onCancelAll,
    required this.onRemindAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Selected count
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$selectedCount selected',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Spacer(),

            // Remind all button
            OutlinedButton.icon(
              onPressed: onRemindAll,
              icon: CustomIconWidget(
                iconName: 'notifications',
                size: 18,
                color: theme.colorScheme.primary,
              ),
              label: const Text('Remind'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),

            SizedBox(width: 2.w),

            // Cancel all button
            ElevatedButton.icon(
              onPressed: onCancelAll,
              icon: CustomIconWidget(
                iconName: 'cancel',
                size: 18,
                color: theme.colorScheme.onError,
              ),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
