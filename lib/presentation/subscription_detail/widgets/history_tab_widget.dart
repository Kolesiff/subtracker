import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HistoryTabWidget extends StatefulWidget {
  final List<Map<String, dynamic>> billingHistory;

  const HistoryTabWidget({super.key, required this.billingHistory});

  @override
  State<HistoryTabWidget> createState() => _HistoryTabWidgetState();
}

class _HistoryTabWidgetState extends State<HistoryTabWidget> {
  String? _selectedItemId;

  void _showContextMenu(
    BuildContext context,
    Map<String, dynamic> billing,
    Offset position,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'note_add',
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              const Text('Add Note'),
            ],
          ),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 100),
              () => _showAddNoteDialog(context, billing),
            );
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'report_problem',
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              SizedBox(width: 2.w),
              const Text('Dispute Charge'),
            ],
          ),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 100),
              () => _showDisputeDialog(context, billing),
            );
          },
        ),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context, Map<String, dynamic> billing) {
    final theme = Theme.of(context);
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Note',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your note...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note added successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDisputeDialog(BuildContext context, Map<String, dynamic> billing) {
    final theme = Theme.of(context);
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Dispute Charge',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: \$${(billing["amount"] as double).toStringAsFixed(2)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for dispute...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dispute submitted successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return widget.billingHistory.isEmpty
        ? _buildEmptyState(theme)
        : ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            itemCount: widget.billingHistory.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
            itemBuilder: (context, index) {
              final billing = widget.billingHistory[index];
              return _buildHistoryCard(theme, billing);
            },
          );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'history',
            color: theme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No billing history',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your payment history will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ThemeData theme, Map<String, dynamic> billing) {
    final date = billing["date"] as DateTime;
    final amount = billing["amount"] as double;
    final status = billing["status"] as String;
    final paymentMethod = billing["paymentMethod"] as String;
    final itemId = '${date.millisecondsSinceEpoch}';

    return GestureDetector(
      onLongPressStart: (details) {
        setState(() => _selectedItemId = itemId);
        _showContextMenu(context, billing, details.globalPosition);
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: _selectedItemId == itemId
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedItemId == itemId
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.16),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        paymentMethod,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'Paid'
                            ? AppTheme.successLight.withValues(alpha: 0.15)
                            : theme.colorScheme.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: status == 'Paid'
                              ? AppTheme.successLight
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: status == 'Paid' ? 'check_circle' : 'error',
                  color: status == 'Paid'
                      ? AppTheme.successLight
                      : theme.colorScheme.error,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  status == 'Paid' ? 'Payment successful' : 'Payment failed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
