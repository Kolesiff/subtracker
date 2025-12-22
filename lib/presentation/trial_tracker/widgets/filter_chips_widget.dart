import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Filter chips widget for trial filtering
class FilterChipsWidget extends StatelessWidget {
  final String selectedCategory;
  final String selectedTimeframe;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onTimeframeChanged;

  const FilterChipsWidget({
    super.key,
    required this.selectedCategory,
    required this.selectedTimeframe,
    required this.onCategoryChanged,
    required this.onTimeframeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Category filters
          _buildFilterChip(
            context,
            'All',
            selectedCategory == 'All',
            () => onCategoryChanged('All'),
          ),
          SizedBox(width: 2.w),
          _buildFilterChip(
            context,
            'Entertainment',
            selectedCategory == 'Entertainment',
            () => onCategoryChanged('Entertainment'),
          ),
          SizedBox(width: 2.w),
          _buildFilterChip(
            context,
            'Productivity',
            selectedCategory == 'Productivity',
            () => onCategoryChanged('Productivity'),
          ),
          SizedBox(width: 2.w),
          _buildFilterChip(
            context,
            'Professional',
            selectedCategory == 'Professional',
            () => onCategoryChanged('Professional'),
          ),
          SizedBox(width: 2.w),
          _buildFilterChip(
            context,
            'Health',
            selectedCategory == 'Health',
            () => onCategoryChanged('Health'),
          ),

          SizedBox(width: 4.w),

          // Divider
          Container(
            width: 1,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            color: theme.colorScheme.outline.withValues(alpha: 0.16),
          ),

          SizedBox(width: 4.w),

          // Timeframe filters
          _buildFilterChip(
            context,
            'All',
            selectedTimeframe == 'All',
            () => onTimeframeChanged('All'),
          ),
          SizedBox(width: 2.w),
          _buildFilterChip(
            context,
            'Expiring Soon',
            selectedTimeframe == 'Expiring Soon',
            () => onTimeframeChanged('Expiring Soon'),
          ),
          SizedBox(width: 2.w),
          _buildFilterChip(
            context,
            'Later',
            selectedTimeframe == 'Later',
            () => onTimeframeChanged('Later'),
          ),
        ],
      ),
    );
  }

  /// Build individual filter chip
  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.16),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
