import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/subscription.dart';
import '../../widgets/custom_app_bar.dart';
import '../subscription_dashboard/viewmodel/dashboard_viewmodel.dart';
import './widgets/cancel_subscription_sheet.dart';
import './widgets/edit_subscription_sheet.dart';
import './widgets/history_tab_widget.dart';
import './widgets/overview_tab_widget.dart';
import './widgets/settings_tab_widget.dart';

class SubscriptionDetail extends StatefulWidget {
  final String subscriptionId;

  const SubscriptionDetail({super.key, required this.subscriptionId});

  @override
  State<SubscriptionDetail> createState() => _SubscriptionDetailState();
}

class _SubscriptionDetailState extends State<SubscriptionDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditMode = false;

  // Get subscription from ViewModel
  Subscription? get _subscription {
    final viewModel = context.read<DashboardViewModel>();
    return viewModel.getSubscriptionById(widget.subscriptionId);
  }

  // Convert subscription to legacy map format for existing widgets
  Map<String, dynamic> get _subscriptionData {
    final sub = _subscription;
    if (sub == null) {
      return {"serviceName": "Unknown", "cost": 0.0};
    }
    return {
      "id": sub.id,
      "serviceName": sub.name,
      "serviceLogo": sub.logoUrl ?? "",
      "semanticLabel": sub.semanticLabel ?? "${sub.name} logo",
      "cost": sub.cost,
      "currency": "\$",
      "billingCycle": sub.billingCycle.displayName,
      "nextChargeDate": sub.nextBillingDate,
      "category": sub.category.displayName,
      "status": sub.status.displayName,
      "autoRenew": sub.status == SubscriptionStatus.active,
      "paymentMethod": "Card on file",
      "startDate": sub.createdAt ?? DateTime.now(),
      "description": sub.notes ?? "",
      "billingHistory": <Map<String, dynamic>>[],
      "costTrend": <Map<String, dynamic>>[],
      "notifications": {
        "enabled": true,
        "reminderDays": 3,
        "emailNotifications": true,
        "pushNotifications": true,
      },
    };
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isEditMode = !_isEditMode;
    });

    if (_isEditMode) {
      _showEditSheet();
    }
  }

  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditSubscriptionSheet(
        subscriptionData: _subscriptionData,
        onSave: (updatedData) {
          setState(() {
            _subscriptionData.addAll(updatedData);
            _isEditMode = false;
          });
          Navigator.pop(context);
          _showSuccessSnackBar('Subscription updated successfully');
        },
      ),
    );
  }

  void _showCancelSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CancelSubscriptionSheet(
        serviceName: _subscriptionData["serviceName"] as String,
        onConfirm: (reason) {
          Navigator.pop(context);
          _handleCancellation(reason);
        },
      ),
    );
  }

  Future<void> _handleCancellation(String reason) async {
    final sub = _subscription;
    if (sub == null) return;

    try {
      final viewModel = context.read<DashboardViewModel>();
      final cancelledSubscription = sub.copyWith(
        status: SubscriptionStatus.cancelled,
      );
      await viewModel.updateSubscription(cancelledSubscription);

      if (mounted) {
        _showSuccessSnackBar('Subscription cancelled successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSuccessSnackBar('Failed to cancel subscription');
      }
    }
  }

  void _shareSubscription() {
    HapticFeedback.lightImpact();
    final serviceName = _subscriptionData["serviceName"] as String;
    final cost = _subscriptionData["cost"] as double;
    final currency = _subscriptionData["currency"] as String;
    final billingCycle = _subscriptionData["billingCycle"] as String;

    Share.share(
      'I\'m subscribed to $serviceName for $currency${cost.toStringAsFixed(2)}/$billingCycle',
      subject: 'My Subscription Details',
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getDaysUntilCharge() {
    final nextCharge = _subscriptionData["nextChargeDate"] as DateTime;
    final daysUntil = nextCharge.difference(DateTime.now()).inDays;
    return daysUntil.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Subscription Details',
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: _isEditMode ? 'check' : 'edit',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            onPressed: _toggleEditMode,
            tooltip: _isEditMode ? 'Save' : 'Edit',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            onPressed: _shareSubscription,
            tooltip: 'Share',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeroSection(theme),
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OverviewTabWidget(
                  subscriptionData: _subscriptionData,
                  onSetReminder: () => _showSuccessSnackBar('Reminder set'),
                  onEditDetails: _showEditSheet,
                  onCancelSubscription: _showCancelSheet,
                ),
                HistoryTabWidget(
                  billingHistory: (_subscriptionData["billingHistory"] as List)
                      .cast<Map<String, dynamic>>(),
                ),
                SettingsTabWidget(
                  subscriptionData: _subscriptionData,
                  onNotificationToggle: (value) {
                    setState(() {
                      (_subscriptionData["notifications"]
                              as Map<String, dynamic>)["enabled"] =
                          value;
                    });
                  },
                  onReminderDaysChanged: (days) {
                    setState(() {
                      (_subscriptionData["notifications"]
                              as Map<String, dynamic>)["reminderDays"] =
                          days;
                    });
                  },
                  onArchive: () {
                    _showSuccessSnackBar('Subscription archived');
                    Navigator.pop(context);
                  },
                  onDelete: () async {
                    try {
                      final viewModel = context.read<DashboardViewModel>();
                      await viewModel.deleteSubscription(widget.subscriptionId);
                      if (mounted) {
                        _showSuccessSnackBar('Subscription deleted');
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        _showSuccessSnackBar('Failed to delete subscription');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    final serviceName = _subscriptionData["serviceName"] as String;
    final serviceLogo = _subscriptionData["serviceLogo"] as String;
    final semanticLabel = _subscriptionData["semanticLabel"] as String;
    final cost = _subscriptionData["cost"] as double;
    final currency = _subscriptionData["currency"] as String;
    final billingCycle = _subscriptionData["billingCycle"] as String;
    final daysUntilCharge = _getDaysUntilCharge();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomImageWidget(
                imageUrl: serviceLogo,
                width: 20.w,
                height: 20.w,
                fit: BoxFit.cover,
                semanticLabel: semanticLabel,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            serviceName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currency,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                cost.toStringAsFixed(2),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                '/$billingCycle',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Next charge in ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$daysUntilCharge days',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.16),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'History'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }
}
