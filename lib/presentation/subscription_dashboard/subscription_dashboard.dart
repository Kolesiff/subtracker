import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
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
  int _currentBottomNavIndex = 0;
  bool _isRefreshing = false;
  String _searchQuery = '';
  bool _isSearchActive = false;

  // Mock data for subscriptions
  final List<Map<String, dynamic>> _allSubscriptions = [
    {
      "id": "1",
      "name": "Netflix",
      "logo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a52c1897-1764720017896.png",
      "semanticLabel": "Netflix logo - red N on black background",
      "cost": "\$15.99",
      "billingCycle": "Monthly",
      "nextBillingDate": DateTime.now().add(const Duration(days: 12)),
      "category": "Entertainment",
      "status": "active",
      "color": Color(0xFFE50914),
    },
    {
      "id": "2",
      "name": "Spotify Premium",
      "logo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1d71ebfa2-1764751041051.png",
      "semanticLabel": "Spotify logo - green circular icon with sound waves",
      "cost": "\$9.99",
      "billingCycle": "Monthly",
      "nextBillingDate": DateTime.now().add(const Duration(days: 5)),
      "category": "Music",
      "status": "active",
      "color": Color(0xFF1DB954),
    },
    {
      "id": "3",
      "name": "Adobe Creative Cloud",
      "logo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1c8eec6ea-1764647363957.png",
      "semanticLabel":
          "Adobe Creative Cloud logo - red gradient square with white cloud icon",
      "cost": "\$52.99",
      "billingCycle": "Monthly",
      "nextBillingDate": DateTime.now().add(const Duration(days: 3)),
      "category": "Productivity",
      "status": "trial",
      "color": Color(0xFFFF0000),
    },
    {
      "id": "4",
      "name": "Amazon Prime",
      "logo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_15314eb28-1765518477718.png",
      "semanticLabel":
          "Amazon Prime logo - blue background with white arrow smile",
      "cost": "\$14.99",
      "billingCycle": "Monthly",
      "nextBillingDate": DateTime.now().add(const Duration(days: 20)),
      "category": "Shopping",
      "status": "active",
      "color": Color(0xFF00A8E1),
    },
    {
      "id": "5",
      "name": "Disney+",
      "logo":
          "https://images.unsplash.com/photo-1588609888898-10663cf0ba99",
      "semanticLabel":
          "Disney Plus logo - blue background with white Disney+ text",
      "cost": "\$7.99",
      "billingCycle": "Monthly",
      "nextBillingDate": DateTime.now().add(const Duration(days: 2)),
      "category": "Entertainment",
      "status": "trial",
      "color": Color(0xFF113CCF),
    },
    {
      "id": "6",
      "name": "GitHub Pro",
      "logo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_10b9cbdab-1765178035130.png",
      "semanticLabel":
          "GitHub logo - black octocat silhouette on white background",
      "cost": "\$4.00",
      "billingCycle": "Monthly",
      "nextBillingDate": DateTime.now().add(const Duration(days: 15)),
      "category": "Development",
      "status": "active",
      "color": Color(0xFF181717),
    },
  ];

  List<Map<String, dynamic>> get _expiringSoonSubscriptions {
    return _allSubscriptions.where((sub) {
      final daysUntilBilling = (sub["nextBillingDate"] as DateTime)
          .difference(DateTime.now())
          .inDays;
      return daysUntilBilling <= 7;
    }).toList()..sort(
      (a, b) => (a["nextBillingDate"] as DateTime).compareTo(
        b["nextBillingDate"] as DateTime,
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredSubscriptions {
    if (_searchQuery.isEmpty) return _allSubscriptions;
    return _allSubscriptions.where((sub) {
      return (sub["name"] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (sub["category"] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  double get _totalMonthlySpending {
    return _allSubscriptions.fold(0.0, (sum, sub) {
      final costString = (sub["cost"] as String).replaceAll('\$', '');
      return sum + double.parse(costString);
    });
  }

  int get _notificationCount {
    return _expiringSoonSubscriptions.length;
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() => _isRefreshing = false);

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
        setState(() => _currentBottomNavIndex = 0);
        break;
      case CustomBottomBarItem.trials:
        Navigator.pushNamed(context, '/trial-tracker');
        break;
      case CustomBottomBarItem.add:
        Navigator.pushNamed(context, '/add-subscription');
        break;
      case CustomBottomBarItem.analytics:
        Navigator.pushNamed(context, '/subscription-detail');
        break;
    }
  }

  void _handleSubscriptionTap(Map<String, dynamic> subscription) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/subscription-detail',
      arguments: subscription,
    );
  }

  void _handleSubscriptionLongPress(Map<String, dynamic> subscription) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildContextMenu(subscription),
    );
  }

  Widget _buildContextMenu(Map<String, dynamic> subscription) {
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
                arguments: subscription,
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
                  content: Text('Alert set for ${subscription["name"]}'),
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
                  content: Text('${subscription["name"]} archived'),
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

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _isSearchActive
          ? CustomAppBar(
              style: CustomAppBarStyle.search,
              onSearchChanged: (query) => setState(() => _searchQuery = query),
              searchHint: 'Search subscriptions...',
              automaticallyImplyLeading: true,
              onBackPressed: _toggleSearch,
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
                  onPressed: _toggleSearch,
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
                              '$_notificationCount subscriptions expiring soon',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    if (_notificationCount > 0)
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
                            _notificationCount > 9
                                ? '9+'
                                : '$_notificationCount',
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
      body: _allSubscriptions.isEmpty
          ? const EmptyStateWidget()
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              color: theme.colorScheme.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SpendingSummaryWidget(
                      totalMonthlySpending: _totalMonthlySpending,
                      activeSubscriptions: _allSubscriptions.length,
                      trialSubscriptions: _allSubscriptions
                          .where((s) => s["status"] == "trial")
                          .length,
                    ),
                  ),

                  if (_expiringSoonSubscriptions.isNotEmpty &&
                      _searchQuery.isEmpty) ...[
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
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/trial-tracker',
                              ),
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
                          itemCount: _expiringSoonSubscriptions.length,
                          itemBuilder: (context, index) {
                            return ExpiringSoonCardWidget(
                              subscription: _expiringSoonSubscriptions[index],
                              onTap: () => _handleSubscriptionTap(
                                _expiringSoonSubscriptions[index],
                              ),
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
                        _searchQuery.isEmpty
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
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return SubscriptionCardWidget(
                          subscription: _filteredSubscriptions[index],
                          onTap: () => _handleSubscriptionTap(
                            _filteredSubscriptions[index],
                          ),
                          onLongPress: () => _handleSubscriptionLongPress(
                            _filteredSubscriptions[index],
                          ),
                        );
                      }, childCount: _filteredSubscriptions.length),
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                ],
              ),
            ),
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
  }
}
