import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SubscriptionCardWidget extends StatelessWidget {
  final Map<String, dynamic> subscription;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const SubscriptionCardWidget({
    super.key,
    required this.subscription,
    required this.onTap,
    required this.onLongPress,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(subscription["id"]),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Edit ${subscription["name"]}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (context) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reminder set for ${subscription["name"]}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.notifications_active,
            label: 'Remind',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${subscription["name"]} marked as cancelled'),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(label: 'Undo', onPressed: () {}),
                ),
              );
            },
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.cancel,
            label: 'Cancel',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.16),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  color: (subscription["color"] as Color).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: subscription["logo"] as String,
                    width: 14.w,
                    height: 14.w,
                    fit: BoxFit.cover,
                    semanticLabel: subscription["semanticLabel"] as String,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subscription["name"] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (subscription["status"] == "trial")
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'TRIAL',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      subscription["category"] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'calendar_today',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Next: ${_formatDate(subscription["nextBillingDate"] as DateTime)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    subscription["cost"] as String,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subscription["billingCycle"] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
