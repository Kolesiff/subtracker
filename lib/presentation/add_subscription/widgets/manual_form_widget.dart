import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../add_subscription.dart';

/// Widget for manual subscription entry form
class ManualFormWidget extends StatelessWidget {
  final TextEditingController serviceNameController;
  final TextEditingController costController;
  final TextEditingController notesController;
  final String selectedCurrency;
  final BillingCycle selectedBillingCycle;
  final DateTime nextBillingDate;
  final String selectedCategory;
  final int customAlertDays;
  final DateTime? trialEndDate;
  final bool isTrialSubscription;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<BillingCycle> onBillingCycleChanged;
  final VoidCallback onCategoryTap;
  final ValueChanged<bool> onDateSelect;
  final ValueChanged<int> onAlertDaysChanged;
  final ValueChanged<bool> onTrialToggle;

  const ManualFormWidget({
    super.key,
    required this.serviceNameController,
    required this.costController,
    required this.notesController,
    required this.selectedCurrency,
    required this.selectedBillingCycle,
    required this.nextBillingDate,
    required this.selectedCategory,
    required this.customAlertDays,
    required this.trialEndDate,
    required this.isTrialSubscription,
    required this.onCurrencyChanged,
    required this.onBillingCycleChanged,
    required this.onCategoryTap,
    required this.onDateSelect,
    required this.onAlertDaysChanged,
    required this.onTrialToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service name field
          Text(
            'Service Name',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: serviceNameController,
            decoration: InputDecoration(
              hintText: 'e.g., Netflix, Spotify',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'subscriptions',
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),

          SizedBox(height: 3.h),

          // Cost and currency
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cost',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextField(
                      controller: costController,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomIconWidget(
                            iconName: 'attach_money',
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currency',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.16,
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCurrency,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: BorderRadius.circular(12),
                          items: ['\$', '€', '£', '¥'].map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(
                                currency,
                                style: theme.textTheme.bodyLarge,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              onCurrencyChanged(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Billing cycle
          Text(
            'Billing Cycle',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildCycleButton(
                  context: context,
                  cycle: BillingCycle.monthly,
                  label: 'Monthly',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildCycleButton(
                  context: context,
                  cycle: BillingCycle.yearly,
                  label: 'Yearly',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildCycleButton(
                  context: context,
                  cycle: BillingCycle.custom,
                  label: 'Custom',
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Next billing date
          Text(
            'Next Billing Date',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          InkWell(
            onTap: () => onDateSelect(false),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('MMM dd, yyyy').format(nextBillingDate),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  CustomIconWidget(
                    iconName: 'arrow_drop_down',
                    size: 24,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Category
          Text(
            'Category',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          InkWell(
            onTap: onCategoryTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'category',
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(selectedCategory, style: theme.textTheme.bodyLarge),
                  const Spacer(),
                  CustomIconWidget(
                    iconName: 'arrow_drop_down',
                    size: 24,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Trial subscription toggle
          Row(
            children: [
              Expanded(
                child: Text(
                  'This is a free trial',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(value: isTrialSubscription, onChanged: onTrialToggle),
            ],
          ),

          if (isTrialSubscription) ...[
            SizedBox(height: 2.h),
            Text(
              'Trial End Date',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            InkWell(
              onTap: () => onDateSelect(true),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'event',
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      trialEndDate != null
                          ? DateFormat('MMM dd, yyyy').format(trialEndDate!)
                          : 'Select date',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: trialEndDate != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    CustomIconWidget(
                      iconName: 'arrow_drop_down',
                      size: 24,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 3.h),

          // Alert timing
          Text(
            'Remind me before',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildAlertButton(
                  context: context,
                  days: 1,
                  label: '1 day',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildAlertButton(
                  context: context,
                  days: 3,
                  label: '3 days',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildAlertButton(
                  context: context,
                  days: 7,
                  label: '7 days',
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Notes (optional)
          Text(
            'Notes (Optional)',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: notesController,
            decoration: InputDecoration(
              hintText: 'Add any additional notes...',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'notes',
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildCycleButton({
    required BuildContext context,
    required BillingCycle cycle,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedBillingCycle == cycle;

    return InkWell(
      onTap: () => onBillingCycleChanged(cycle),
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
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAlertButton({
    required BuildContext context,
    required int days,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = customAlertDays == days;

    return InkWell(
      onTap: () => onAlertDaysChanged(days),
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
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
