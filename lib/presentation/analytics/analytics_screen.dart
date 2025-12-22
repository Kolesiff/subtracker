import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../data/models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './viewmodel/analytics_viewmodel.dart';

/// Analytics dashboard screen showing spending insights
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Load analytics data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsViewModel>().loadAnalytics();
    });
  }

  void _handleBottomNavTap(CustomBottomBarItem item) {
    HapticFeedback.lightImpact();
    switch (item) {
      case CustomBottomBarItem.dashboard:
        Navigator.pushReplacementNamed(context, '/subscription-dashboard');
        break;
      case CustomBottomBarItem.trials:
        Navigator.pushReplacementNamed(context, '/trial-tracker');
        break;
      case CustomBottomBarItem.add:
        Navigator.pushNamed(context, '/add-subscription');
        break;
      case CustomBottomBarItem.analytics:
        // Already on analytics
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AnalyticsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: const CustomAppBar(
            title: 'Analytics',
            style: CustomAppBarStyle.standard,
            automaticallyImplyLeading: false,
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.error != null
                  ? _buildErrorState(theme, viewModel)
                  : _buildContent(theme, viewModel),
          bottomNavigationBar: CustomBottomBar(
            currentItem: CustomBottomBarItem.analytics,
            onItemSelected: _handleBottomNavTap,
          ),
        );
      },
    );
  }

  Widget _buildErrorState(ThemeData theme, AnalyticsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.error!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.loadAnalytics,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AnalyticsViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refreshAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spending Overview Card
            _buildSpendingOverviewCard(theme, viewModel),
            SizedBox(height: AppTheme.spacingLarge),

            // Quick Stats
            Text(
              'Quick Stats',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.spacingMedium),
            _buildQuickStats(theme, viewModel),
            SizedBox(height: AppTheme.spacingLarge),

            // Category Breakdown
            Text(
              'Spending by Category',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.spacingMedium),
            _buildCategoryBreakdown(theme, viewModel),
            SizedBox(height: AppTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingOverviewCard(
      ThemeData theme, AnalyticsViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Monthly Spending',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.formattedTotalMonthlySpending,
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              _buildMiniStat(
                theme,
                'Yearly',
                viewModel.formattedTotalYearlySpending,
              ),
              SizedBox(width: 6.w),
              _buildMiniStat(
                theme,
                'Avg/Sub',
                viewModel.formattedAverageSubscriptionCost,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(ThemeData theme, AnalyticsViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Active',
            '${viewModel.activeSubscriptionCount}',
            Icons.subscriptions_rounded,
            theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: _buildStatCard(
            theme,
            'Trials',
            '${viewModel.activeTrialCount}',
            Icons.timer_rounded,
            theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Semantics(
      label: '$value $label',
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: AppTheme.spacingSmall),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
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

  Widget _buildCategoryBreakdown(
      ThemeData theme, AnalyticsViewModel viewModel) {
    final categories = viewModel.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (categories.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: Center(
          child: Text(
            'No subscription data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: categories.map((entry) {
        final percentage = viewModel.totalMonthlySpending > 0
            ? (entry.value / viewModel.totalMonthlySpending * 100)
            : 0.0;
        return _buildCategoryRow(theme, entry.key, entry.value, percentage);
      }).toList(),
    );
  }

  Widget _buildCategoryRow(
    ThemeData theme,
    SubscriptionCategory category,
    double amount,
    double percentage,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacingSmall),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.displayName,
                style: theme.textTheme.titleSmall,
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}/mo',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
