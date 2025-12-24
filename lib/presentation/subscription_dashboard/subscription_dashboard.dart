import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/models.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './viewmodel/dashboard_viewmodel.dart';
import './widgets/empty_state_widget.dart';
import './widgets/expiring_soon_card_widget.dart';
import './widgets/spending_summary_widget.dart';
import './widgets/subscription_card_widget.dart';

class SubscriptionDashboard extends StatefulWidget {
  const SubscriptionDashboard({super.key});

  @override
  State<SubscriptionDashboard> createState() => _SubscriptionDashboardState();
}

class _SubscriptionDashboardState extends State<SubscriptionDashboard> {
  Future<void> _handleRefresh(DashboardViewModel viewModel) async {
    HapticFeedback.mediumImpact();
    await viewModel.refreshSubscriptions();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Subscriptions synced successfully'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _handleBottomNavTap(CustomBottomBarItem item) {
    HapticFeedback.lightImpact();

    switch (item) {
      case CustomBottomBarItem.dashboard:
        // Already on dashboard, no action needed
        break;
      case CustomBottomBarItem.trials:
        Navigator.pushNamed(context, '/trial-tracker');
        break;
      case CustomBottomBarItem.account:
        Navigator.pushReplacementNamed(context, '/account-settings');
        break;
      case CustomBottomBarItem.analytics:
        Navigator.pushReplacementNamed(context, '/analytics');
        break;
    }
  }

  void _handleSubscriptionTap(Subscription subscription) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/subscription-detail',
      arguments: {'subscriptionId': subscription.id},
    );
  }

  void _handleSubscriptionLongPress(Subscription subscription) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildContextMenu(subscription),
    );
  }

  /// Convert Subscription to Map for backward compatibility with existing widgets
  Map<String, dynamic> _subscriptionToMap(Subscription sub) {
    return {
      'id': sub.id,
      'name': sub.name,
      'logo': sub.logoUrl,
      'semanticLabel': sub.semanticLabel,
      'cost': sub.formattedCost,
      'billingCycle': sub.billingCycle.displayName,
      'nextBillingDate': sub.nextBillingDate,
      'category': sub.category.displayName,
      'status': sub.status.name,
      'color': sub.brandColor,
    };
  }

  Widget _buildContextMenu(Subscription subscription) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'edit',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            title: Text('Edit Subscription', style: theme.textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/add-subscription',
                arguments: _subscriptionToMap(subscription),
              );
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'notifications_active',
              color: theme.colorScheme.tertiary,
              size: 24,
            ),
            title: Text('Set Alert', style: theme.textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alert set for ${subscription.name}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.secondary,
              size: 24,
            ),
            title: Text('Share', style: theme.textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing functionality coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'archive',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            title: Text('Archive', style: theme.textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${subscription.name} archived'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: viewModel.isSearchActive
              ? CustomAppBar(
                  style: CustomAppBarStyle.search,
                  onSearchChanged: viewModel.setSearchQuery,
                  searchHint: 'Search subscriptions...',
                  automaticallyImplyLeading: true,
                  onBackPressed: viewModel.toggleSearch,
                )
              : CustomAppBar(
                  title: 'Subscriptions',
                  style: CustomAppBarStyle.large,
                  actions: [
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'search',
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                      onPressed: viewModel.toggleSearch,
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: CustomIconWidget(
                            iconName: 'notifications_outlined',
                            color: theme.colorScheme.onSurface,
                            size: 24,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${viewModel.notificationCount} subscriptions expiring soon',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        if (viewModel.notificationCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                viewModel.notificationCount > 9
                                    ? '9+'
                                    : '${viewModel.notificationCount}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
          body: _buildBody(theme, viewModel),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/add-subscription');
            },
            icon: CustomIconWidget(
              iconName: 'add',
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
            label: Text(
              'Add Subscription',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            backgroundColor: theme.colorScheme.primary,
          ),
          bottomNavigationBar: CustomBottomBar(
            currentItem: CustomBottomBarItem.dashboard,
            onItemSelected: _handleBottomNavTap,
          ),
        );
      },
    );
  }

  Widget _buildBody(ThemeData theme, DashboardViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(viewModel.error!, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.loadSubscriptions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!viewModel.hasSubscriptions) {
      return const EmptyStateWidget();
    }

    final filteredSubscriptions = viewModel.filteredSubscriptions;
    final expiringSoon = viewModel.expiringSoonSubscriptions;

    return RefreshIndicator(
      onRefresh: () => _handleRefresh(viewModel),
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SpendingSummaryWidget(
              totalMonthlySpending: viewModel.totalMonthlySpending,
              activeSubscriptions: viewModel.activeSubscriptionCount,
              trialSubscriptions: viewModel.trialSubscriptionCount,
            ),
          ),

          if (expiringSoon.isNotEmpty && viewModel.searchQuery.isEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expiring Soon',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/trial-tracker'),
                      child: Text(
                        'View All',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 20.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: expiringSoon.length,
                  itemBuilder: (context, index) {
                    return ExpiringSoonCardWidget(
                      subscription: _subscriptionToMap(expiringSoon[index]),
                      onTap: () => _handleSubscriptionTap(expiringSoon[index]),
                    );
                  },
                ),
              ),
            ),
          ],

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
              child: Text(
                viewModel.searchQuery.isEmpty
                    ? 'All Subscriptions'
                    : 'Search Results',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final subscription = filteredSubscriptions[index];
                  return SubscriptionCardWidget(
                    subscription: _subscriptionToMap(subscription),
                    onTap: () => _handleSubscriptionTap(subscription),
                    onLongPress: () =>
                        _handleSubscriptionLongPress(subscription),
                  );
                },
                childCount: filteredSubscriptions.length,
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 10.h)),
        ],
      ),
    );
  }
}
