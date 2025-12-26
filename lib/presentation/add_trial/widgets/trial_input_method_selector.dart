import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Input method for adding trials
enum TrialInputMethod { manual, popular }

/// Widget for selecting trial input method (Manual or Popular)
class TrialInputMethodSelector extends StatelessWidget {
  final TrialInputMethod selectedMethod;
  final ValueChanged<TrialInputMethod> onMethodChanged;

  const TrialInputMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How would you like to add?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMethodButton(
                  context: context,
                  method: TrialInputMethod.manual,
                  icon: 'edit',
                  label: 'Manual',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildMethodButton(
                  context: context,
                  method: TrialInputMethod.popular,
                  icon: 'apps',
                  label: 'Popular',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton({
    required BuildContext context,
    required TrialInputMethod method,
    required String icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedMethod == method;

    return InkWell(
      onTap: () => onMethodChanged(method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 28,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
