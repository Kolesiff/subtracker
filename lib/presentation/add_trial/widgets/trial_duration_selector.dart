import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Trial duration options
enum TrialDuration { sevenDays, thirtyDays, custom }

/// Widget for selecting trial duration (7 Days, 30 Days, or Custom)
class TrialDurationSelector extends StatelessWidget {
  final TrialDuration selectedDuration;
  final DateTime trialEndDate;
  final ValueChanged<TrialDuration> onDurationChanged;
  final VoidCallback onCustomDateTap;

  const TrialDurationSelector({
    super.key,
    required this.selectedDuration,
    required this.trialEndDate,
    required this.onDurationChanged,
    required this.onCustomDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trial Duration', style: theme.textTheme.labelLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDurationOption(
                context: context,
                duration: TrialDuration.sevenDays,
                label: '7 Days',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDurationOption(
                context: context,
                duration: TrialDuration.thirtyDays,
                label: '30 Days',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDurationOption(
                context: context,
                duration: TrialDuration.custom,
                label: 'Custom',
              ),
            ),
          ],
        ),
        if (selectedDuration == TrialDuration.custom) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: onCustomDateTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(trialEndDate),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          Text(
            'Trial ends: ${DateFormat('MMMM dd, yyyy').format(trialEndDate)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDurationOption({
    required BuildContext context,
    required TrialDuration duration,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedDuration == duration;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onDurationChanged(duration);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
