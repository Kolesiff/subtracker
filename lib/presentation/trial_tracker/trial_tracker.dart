import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/trial.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './viewmodel/trial_viewmodel.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/quick_actions_bar_widget.dart';
import './widgets/trial_card_widget.dart';
import './widgets/urgency_summary_widget.dart';

/// Trial Tracker screen for managing free trial periods
/// Prevents unwanted charges through dedicated mobile interface
class TrialTracker extends StatefulWidget {
  const TrialTracker({super.key});

  @override
  State<TrialTracker> createState() => _TrialTrackerState();
}

class _TrialTrackerState extends State<TrialTracker> with SingleTickerProviderStateMixin {
  // Selection state (filter state is now in ViewModel)
  final Set<String> _selectedTrials = {};
  bool _isSelectionMode = false;

  /// Handle pull to refresh
  Future<void> _handleRefresh() async {
    await context.read<TrialViewModel>().refreshTrials();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trial status updated'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle trial card tap
  void _handleTrialTap(Map<String, dynamic> trial) {
    if (_isSelectionMode) {
      setState(() {
        final trialId = trial["id"] as String;
        _selectedTrials.contains(trialId)
            ? _selectedTrials.remove(trialId)
            : _selectedTrials.add(trialId);

        if (_selectedTrials.isEmpty) {
          _isSelectionMode = false;
        }
      });
    } else {
      _showTrialDetail(trial);
    }
  }

  /// Handle trial card long press
  void _handleTrialLongPress(Map<String, dynamic> trial) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelectionMode = true;
      _selectedTrials.add(trial["id"] as String);
    });
  }

  /// Show trial detail bottom sheet
  void _showTrialDetail(Map<String, dynamic> trial) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service logo and name
                    Row(
                      children: [
                        CustomImageWidget(
                          imageUrl: trial["logo"] as String,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          semanticLabel: trial["semanticLabel"] as String,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trial["serviceName"] as String,
                                style: theme.textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                trial["category"] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Trial information
                    _buildDetailRow(
                      'Trial Ends',
                      _formatDate(trial["trialEndDate"] as DateTime),
                      theme,
                    ),
                    _buildDetailRow(
                      'Conversion Cost',
                      trial["conversionCost"] as String,
                      theme,
                    ),
                    _buildDetailRow(
                      'Cancellation',
                      trial["cancellationDifficulty"] as String,
                      theme,
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Cancellation instructions
                    Text(
                      'Cancellation Instructions',
                      style: theme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '1. Visit your account settings\n2. Navigate to subscription management\n3. Select "Cancel Subscription"\n4. Confirm cancellation',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showCancelConfirmation(trial);
                            },
                            icon: CustomIconWidget(
                              iconName: 'cancel',
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                            label: const Text('Cancel Trial'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              side: BorderSide(color: theme.colorScheme.error),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _setReminder(trial);
                            },
                            icon: CustomIconWidget(
                              iconName: 'notifications',
                              size: 20,
                              color: theme.colorScheme.onPrimary,
                            ),
                            label: const Text('Set Reminder'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build detail row widget
  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  /// Show cancel confirmation dialog
  void _showCancelConfirmation(Map<String, dynamic> trial) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Trial?'),
        content: Text(
          'Are you sure you want to cancel ${trial["serviceName"]}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Trial'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelTrial(trial);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Cancel Trial'),
          ),
        ],
      ),
    );
  }

  /// Cancel trial via ViewModel
  void _cancelTrial(Map<String, dynamic> trial) {
    _cancelTrialFromViewModel(
      trial["id"] as String,
      trial["serviceName"] as String,
    );
  }

  /// Set reminder for trial
  void _setReminder(Map<String, dynamic> trial) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for ${trial["serviceName"]}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handle batch cancel
  void _handleBatchCancel() {
    if (_selectedTrials.isEmpty) return;

    final theme = Theme.of(context);
    final count = _selectedTrials.length;
    final viewModel = context.read<TrialViewModel>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Selected Trials?'),
        content: Text('Are you sure you want to cancel $count trial${count > 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep Trials'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Cancel each selected trial via ViewModel
              for (final trialId in _selectedTrials) {
                await viewModel.cancelTrial(trialId);
              }
              setState(() {
                _selectedTrials.clear();
                _isSelectionMode = false;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$count trial${count > 1 ? 's' : ''} cancelled'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Cancel Trials'),
          ),
        ],
      ),
    );
  }

  /// Handle batch remind
  void _handleBatchRemind() {
    if (_selectedTrials.isEmpty) return;
    
    final count = _selectedTrials.length;
    setState(() {
      _selectedTrials.clear();
      _isSelectionMode = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminders set for $count trial${count > 1 ? 's' : ''}'),
      ),
    );
  }

  /// Navigate to add trial screen
  void _navigateToAddTrial() {
    Navigator.pushNamed(context, '/add-trial');
  }

  /// Convert Trial model to Map for compatibility with existing widgets
  Map<String, dynamic> _trialToMap(Trial trial) {
    return {
      "id": trial.id,
      "serviceName": trial.serviceName,
      "logo": trial.logoUrl ?? "https://via.placeholder.com/200",
      "semanticLabel": trial.semanticLabel ?? "${trial.serviceName} logo",
      "category": trial.category.displayName,
      "trialEndDate": trial.trialEndDate,
      "conversionCost": trial.formattedConversionCost,
      "cancellationDifficulty": trial.cancellationDifficulty.displayName,
      "cancellationUrl": trial.cancellationUrl ?? "",
      "urgencyLevel": trial.urgencyLevel.name,
    };
  }

  /// Cancel trial via ViewModel
  Future<void> _cancelTrialFromViewModel(String trialId, String serviceName) async {
    try {
      await context.read<TrialViewModel>().cancelTrial(trialId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$serviceName trial cancelled'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel trial: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<TrialViewModel>(
      builder: (context, viewModel, child) {
        // Convert Trial models to Maps for widget compatibility
        final activeTrialMaps = viewModel.activeTrials.map(_trialToMap).toList();
        final filteredTrialMaps = viewModel.filteredTrials.map(_trialToMap).toList();

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Trial Tracker',
            style: CustomAppBarStyle.standard,
            automaticallyImplyLeading: false,
            actions: [
              if (_isSelectionMode)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTrials.clear();
                      _isSelectionMode = false;
                    });
                  },
                  child: const Text('Cancel'),
                )
              else
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'search',
                    size: 24,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    // Search functionality
                  },
                ),
            ],
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : !viewModel.hasTrials
                  ? const EmptyStateWidget()
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: Column(
                        children: [
                          // Urgency summary
                          UrgencySummaryWidget(trials: activeTrialMaps),

                          // Filter chips
                          FilterChipsWidget(
                            selectedCategory: viewModel.selectedCategory,
                            selectedTimeframe: viewModel.selectedTimeframe,
                            onCategoryChanged: (value) {
                              viewModel.setCategory(value);
                            },
                            onTimeframeChanged: (value) {
                              viewModel.setTimeframe(value);
                            },
                          ),

                          // Trial list
                          Expanded(
                            child: filteredTrialMaps.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'filter_list_off',
                                          size: 64,
                                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'No trials match your filters',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                    itemCount: filteredTrialMaps.length,
                                    separatorBuilder: (context, index) => SizedBox(height: 2.h),
                                    itemBuilder: (context, index) {
                                      final trial = filteredTrialMaps[index];
                                      final isSelected = _selectedTrials.contains(trial["id"]);

                                      return TrialCardWidget(
                                        trial: trial,
                                        isSelected: isSelected,
                                        onTap: () => _handleTrialTap(trial),
                                        onLongPress: () => _handleTrialLongPress(trial),
                                        onCancel: () => _showCancelConfirmation(trial),
                                        onRemind: () => _setReminder(trial),
                                      );
                                    },
                                  ),
                          ),

                          // Quick actions bar (shown when trials selected)
                          if (_isSelectionMode)
                            QuickActionsBarWidget(
                              selectedCount: _selectedTrials.length,
                              onCancelAll: _handleBatchCancel,
                              onRemindAll: _handleBatchRemind,
                            ),
                        ],
                      ),
                    ),
          floatingActionButton: _isSelectionMode
              ? null
              : FloatingActionButton.extended(
                  onPressed: _navigateToAddTrial,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    size: 24,
                    color: theme.colorScheme.onTertiary,
                  ),
                  label: const Text('Add Trial'),
                ),
          bottomNavigationBar: CustomBottomBar(
            currentItem: CustomBottomBarItem.trials,
            onItemSelected: (item) {
              switch (item) {
                case CustomBottomBarItem.dashboard:
                  Navigator.pushReplacementNamed(context, '/subscription-dashboard');
                  break;
                case CustomBottomBarItem.trials:
                  // Already on trials, no action needed
                  break;
                case CustomBottomBarItem.account:
                  Navigator.pushReplacementNamed(context, '/account-settings');
                  break;
                case CustomBottomBarItem.analytics:
                  Navigator.pushReplacementNamed(context, '/analytics');
                  break;
              }
            },
          ),
        );
      },
    );
  }
}