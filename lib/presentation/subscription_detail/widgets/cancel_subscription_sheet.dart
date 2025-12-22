import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CancelSubscriptionSheet extends StatefulWidget {
  final String serviceName;
  final Function(String) onConfirm;

  const CancelSubscriptionSheet({
    super.key,
    required this.serviceName,
    required this.onConfirm,
  });

  @override
  State<CancelSubscriptionSheet> createState() =>
      _CancelSubscriptionSheetState();
}

class _CancelSubscriptionSheetState extends State<CancelSubscriptionSheet> {
  String? _selectedReason;
  final TextEditingController _feedbackController = TextEditingController();
  int _currentStep = 0;

  final List<String> _cancellationReasons = [
    'Too expensive',
    'Not using it enough',
    'Found a better alternative',
    'Service quality issues',
    'Other',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentStep == 0 && _selectedReason != null) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      HapticFeedback.mediumImpact();
      widget.onConfirm(_selectedReason ?? 'No reason provided');
    }
  }

  void _handleBack() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 4.w,
            right: 4.w,
            top: 2.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 2.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cancel Subscription',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              _buildStepIndicator(theme),
              SizedBox(height: 3.h),
              _currentStep == 0
                  ? _buildReasonStep(theme)
                  : _buildConfirmationStep(theme),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleBack,
                      child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedReason != null ? _handleNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                      ),
                      child: Text(_currentStep == 0 ? 'Next' : 'Confirm'),
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

  Widget _buildStepIndicator(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep == 1
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why are you cancelling ${widget.serviceName}?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        ..._cancellationReasons.map((reason) {
          final isSelected = reason == _selectedReason;
          return Padding(
            padding: EdgeInsets.only(bottom: 1.5.h),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedReason = reason);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.error.withValues(alpha: 0.1)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.error
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.5,
                                ),
                          width: 2,
                        ),
                        color: isSelected
                            ? theme.colorScheme.error
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Center(
                              child: CustomIconWidget(
                                iconName: 'check',
                                color: theme.colorScheme.onError,
                                size: 16,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        reason,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildConfirmationStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: theme.colorScheme.error,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Your subscription will be cancelled immediately',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          'Additional Feedback (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _feedbackController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tell us more about your experience...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
