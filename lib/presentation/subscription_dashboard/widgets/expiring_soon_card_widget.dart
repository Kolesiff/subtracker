import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExpiringSoonCardWidget extends StatelessWidget {
  final Map<String, dynamic> subscription;
  final VoidCallback onTap;

  const ExpiringSoonCardWidget({
    super.key,
    required this.subscription,
    required this.onTap,
  });

  String _getDaysRemaining() {
    final nextBilling = subscription["nextBillingDate"] as DateTime;
    final daysRemaining = nextBilling.difference(DateTime.now()).inDays;

    if (daysRemaining == 0) return 'Today';
    if (daysRemaining == 1) return 'Tomorrow';
    return '$daysRemaining days';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysRemaining = (subscription["nextBillingDate"] as DateTime)
        .difference(DateTime.now())
        .inDays;
    final isUrgent = daysRemaining <= 2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 3.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent
                ? theme.colorScheme.error.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.16),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
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
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.cover,
                      semanticLabel: subscription["semanticLabel"] as String,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription["name"] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subscription["category"] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isUrgent
                    ? theme.colorScheme.error.withValues(alpha: 0.1)
                    : theme.colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: isUrgent
                        ? theme.colorScheme.error
                        : theme.colorScheme.tertiary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Expires in ${_getDaysRemaining()}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isUrgent
                          ? theme.colorScheme.error
                          : theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subscription["cost"] as String,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subscription["status"] == "trial")
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
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
          ],
        ),
      ),
    );
  }
}
