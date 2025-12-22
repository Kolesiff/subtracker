import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EditSubscriptionSheet extends StatefulWidget {
  final Map<String, dynamic> subscriptionData;
  final Function(Map<String, dynamic>) onSave;

  const EditSubscriptionSheet({
    super.key,
    required this.subscriptionData,
    required this.onSave,
  });

  @override
  State<EditSubscriptionSheet> createState() => _EditSubscriptionSheetState();
}

class _EditSubscriptionSheetState extends State<EditSubscriptionSheet> {
  late TextEditingController _nameController;
  late TextEditingController _costController;
  String _selectedBillingCycle = 'Monthly';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.subscriptionData["serviceName"] as String,
    );
    _costController = TextEditingController(
      text: (widget.subscriptionData["cost"] as double).toStringAsFixed(2),
    );
    _selectedBillingCycle = widget.subscriptionData["billingCycle"] as String;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      widget.onSave({
        "serviceName": _nameController.text,
        "cost": double.tryParse(_costController.text) ?? 0.0,
        "billingCycle": _selectedBillingCycle,
      });
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Subscription',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
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
                SizedBox(height: 3.h),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Service Name',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'business',
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter service name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Cost',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'attach_money',
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cost';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                Text(
                  'Billing Cycle',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: ['Monthly', 'Yearly', 'Weekly'].map((cycle) {
                    final isSelected = cycle == _selectedBillingCycle;
                    return InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedBillingCycle = cycle);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(
                                    alpha: 0.3,
                                  ),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          cycle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    child: const Text('Save Changes'),
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
