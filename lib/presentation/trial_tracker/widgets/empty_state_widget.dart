import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty state widget for when no trials exist
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'timer_off',
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              'No Active Trials',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 1.h),

            // Description
            Text(
              'Start tracking your free trials to avoid unwanted charges and manage subscriptions effectively.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Add trial button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-subscription');
              },
              icon: CustomIconWidget(
                iconName: 'add',
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
              label: const Text('Add Your First Trial'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              ),
            ),

            SizedBox(height: 3.h),

            // Educational content
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb',
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Trial Management Tips',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  _buildTip(
                    context,
                    'Set reminders 2-3 days before trial ends',
                  ),
                  _buildTip(
                    context,
                    'Cancel immediately after signing up if unsure',
                  ),
                  _buildTip(context, 'Use virtual cards for easy cancellation'),
                  _buildTip(
                    context,
                    'Check cancellation difficulty before starting',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual tip item
  Widget _buildTip(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 0.5.h),
            child: CustomIconWidget(
              iconName: 'check_circle',
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
