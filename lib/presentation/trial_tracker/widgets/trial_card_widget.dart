import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Individual trial card widget with swipe actions
class TrialCardWidget extends StatelessWidget {
  final Map<String, dynamic> trial;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onCancel;
  final VoidCallback onRemind;

  const TrialCardWidget({
    super.key,
    required this.trial,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onCancel,
    required this.onRemind,
  });

  /// Get urgency color based on trial end date
  Color _getUrgencyColor(BuildContext context, String urgencyLevel) {
    final theme = Theme.of(context);
    switch (urgencyLevel) {
      case 'critical':
        return theme.colorScheme.error;
      case 'warning':
        return const Color(0xFFF39C12);
      case 'safe':
      default:
        return const Color(0xFF2ECC71);
    }
  }

  /// Calculate countdown text
  String _getCountdownText() {
    final endDate = trial["trialEndDate"] as DateTime;
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Expired';
    }
  }

  /// Format end date
  String _formatEndDate() {
    final endDate = trial["trialEndDate"] as DateTime;
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.inDays == 0) {
      return 'Ends today';
    } else if (difference.inDays == 1) {
      return 'Ends tomorrow';
    } else {
      return 'Ends ${endDate.month}/${endDate.day}/${endDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgencyColor = _getUrgencyColor(
      context,
      trial["urgencyLevel"] as String,
    );

    return Slidable(
      key: ValueKey(trial["id"]),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onCancel(),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.cancel_rounded,
            label: 'Cancel',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (context) => onRemind(),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.notifications_rounded,
            label: 'Remind',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.16),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                // Selection checkbox
                if (isSelected)
                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: CustomIconWidget(
                      iconName: 'check_circle',
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                // Service logo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: trial["logo"] as String,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      semanticLabel: trial["semanticLabel"] as String,
                    ),
                  ),
                ),

                SizedBox(width: 3.w),

                // Trial information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service name
                      Text(
                        trial["serviceName"] as String,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 0.5.h),

                      // End date
                      Text(
                        _formatEndDate(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      // Conversion cost
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'attach_money',
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            trial["conversionCost"] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Countdown timer with urgency indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: urgencyColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'timer',
                        size: 20,
                        color: urgencyColor,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _getCountdownText(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: urgencyColor,
                          fontWeight: FontWeight.w700,
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
}
