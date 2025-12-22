import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/urgency_colors.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Urgency summary widget showing trial statistics
class UrgencySummaryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> trials;

  const UrgencySummaryWidget({super.key, required this.trials});

  /// Calculate urgency statistics
  Map<String, int> _calculateUrgencyStats() {
    int critical = 0;
    int warning = 0;
    int safe = 0;

    for (final trial in trials) {
      final urgency = trial["urgencyLevel"] as String;
      if (urgency == 'critical') {
        critical++;
      } else if (urgency == 'warning') {
        warning++;
      } else {
        safe++;
      }
    }

    return {'critical': critical, 'warning': warning, 'safe': safe};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _calculateUrgencyStats();
    final totalTrials = trials.length;

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Trials',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '$totalTrials trial${totalTrials != 1 ? 's' : ''} to manage',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalTrials',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Urgency breakdown
          Row(
            children: [
              Expanded(
                child: _buildUrgencyCard(
                  context,
                  'Critical',
                  stats['critical']!,
                  theme.colorScheme.error,
                  Icons.warning_rounded,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildUrgencyCard(
                  context,
                  'Warning',
                  stats['warning']!,
                  UrgencyColors.warning(context),
                  Icons.access_time_rounded,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildUrgencyCard(
                  context,
                  'Safe',
                  stats['safe']!,
                  UrgencyColors.safe(context),
                  Icons.check_circle_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual urgency card
  Widget _buildUrgencyCard(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$count $label trial${count != 1 ? 's' : ''}',
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon
                  .toString()
                  .split('.')
                  .last
                  .replaceAll('IconData(U+', '')
                  .replaceAll(')', ''),
              size: 24,
              color: color,
            ),
            SizedBox(height: 0.5.h),
            Text(
              '$count',
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
