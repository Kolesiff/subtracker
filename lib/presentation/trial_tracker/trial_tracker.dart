import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
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
  // Selected filter state
  String _selectedCategory = 'All';
  String _selectedTimeframe = 'All';
  bool _isRefreshing = false;
  final Set<int> _selectedTrials = {};
  bool _isSelectionMode = false;

  // Mock data for active trials
  final List<Map<String, dynamic>> _activeTrials = [
    {
      "id": 1,
      "serviceName": "Netflix Premium",
      "logo": "https://images.unsplash.com/photo-1574375927938-d5a98e8ffe85?w=200&h=200&fit=crop",
      "semanticLabel": "Netflix logo with red N on black background",
      "category": "Entertainment",
      "trialEndDate": DateTime.now().add(const Duration(hours: 18)),
      "conversionCost": "\$15.99/month",
      "cancellationDifficulty": "Easy",
      "cancellationUrl": "https://netflix.com/cancel",
      "urgencyLevel": "critical",
    },
    {
      "id": 2,
      "serviceName": "Adobe Creative Cloud",
      "logo": "https://img.rocket.new/generatedImages/rocket_gen_img_1c8eec6ea-1764647363957.png",
      "semanticLabel": "Adobe Creative Cloud logo with red gradient background",
      "category": "Productivity",
      "trialEndDate": DateTime.now().add(const Duration(days: 3)),
      "conversionCost": "\$54.99/month",
      "cancellationDifficulty": "Medium",
      "cancellationUrl": "https://adobe.com/cancel",
      "urgencyLevel": "warning",
    },
    {
      "id": 3,
      "serviceName": "Spotify Premium",
      "logo": "https://img.rocket.new/generatedImages/rocket_gen_img_1d71ebfa2-1764751041051.png",
      "semanticLabel": "Spotify logo with green circular icon on dark background",
      "category": "Entertainment",
      "trialEndDate": DateTime.now().add(const Duration(days: 5)),
      "conversionCost": "\$9.99/month",
      "cancellationDifficulty": "Easy",
      "cancellationUrl": "https://spotify.com/cancel",
      "urgencyLevel": "warning",
    },
    {
      "id": 4,
      "serviceName": "LinkedIn Premium",
      "logo": "https://img.rocket.new/generatedImages/rocket_gen_img_1e2ba7dbb-1764662219352.png",
      "semanticLabel": "LinkedIn logo with blue background and white text",
      "category": "Professional",
      "trialEndDate": DateTime.now().add(const Duration(days: 12)),
      "conversionCost": "\$29.99/month",
      "cancellationDifficulty": "Medium",
      "cancellationUrl": "https://linkedin.com/cancel",
      "urgencyLevel": "safe",
    },
    {
      "id": 5,
      "serviceName": "Headspace Meditation",
      "logo": "https://img.rocket.new/generatedImages/rocket_gen_img_12e194567-1765458368238.png",
      "semanticLabel": "Meditation app icon with orange circular design on white background",
      "category": "Health",
      "trialEndDate": DateTime.now().add(const Duration(days: 20)),
      "conversionCost": "\$12.99/month",
      "cancellationDifficulty": "Easy",
      "cancellationUrl": "https://headspace.com/cancel",
      "urgencyLevel": "safe",
    },
  ];

  @override
  void initState() {
    super.initState();
    _sortTrialsByUrgency();
  }

  /// Sort trials by expiration proximity
  void _sortTrialsByUrgency() {
    _activeTrials.sort((a, b) {
      final aDate = a["trialEndDate"] as DateTime;
      final bDate = b["trialEndDate"] as DateTime;
      return aDate.compareTo(bDate);
    });
  }

  /// Get filtered trials based on selected filters
  List<Map<String, dynamic>> _getFilteredTrials() {
    return _activeTrials.where((trial) {
      final categoryMatch = _selectedCategory == 'All' || trial["category"] == _selectedCategory;
      
      bool timeframeMatch = true;
      if (_selectedTimeframe != 'All') {
        final daysUntilExpiry = (trial["trialEndDate"] as DateTime).difference(DateTime.now()).inDays;
        timeframeMatch = _selectedTimeframe == 'Expiring Soon' 
            ? daysUntilExpiry <= 7 
            : daysUntilExpiry > 7;
      }
      
      return categoryMatch && timeframeMatch;
    }).toList();
  }

  /// Handle pull to refresh
  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isRefreshing = false);
    
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
        final trialId = trial["id"] as int;
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
      _selectedTrials.add(trial["id"] as int);
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

  /// Cancel trial
  void _cancelTrial(Map<String, dynamic> trial) {
    setState(() {
      _activeTrials.removeWhere((t) => t["id"] == trial["id"]);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${trial["serviceName"]} trial cancelled'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _activeTrials.add(trial);
              _sortTrialsByUrgency();
            });
          },
        ),
      ),
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
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Selected Trials?'),
        content: Text('Are you sure you want to cancel $count trial${count > 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Trials'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _activeTrials.removeWhere((trial) => _selectedTrials.contains(trial["id"]));
                _selectedTrials.clear();
                _isSelectionMode = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$count trial${count > 1 ? 's' : ''} cancelled'),
                ),
              );
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
    Navigator.pushNamed(context, '/add-subscription');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTrials = _getFilteredTrials();
    
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
      body: _activeTrials.isEmpty
          ? const EmptyStateWidget()
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: Column(
                children: [
                  // Urgency summary
                  UrgencySummaryWidget(trials: _activeTrials),
                  
                  // Filter chips
                  FilterChipsWidget(
                    selectedCategory: _selectedCategory,
                    selectedTimeframe: _selectedTimeframe,
                    onCategoryChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    onTimeframeChanged: (value) {
                      setState(() => _selectedTimeframe = value);
                    },
                  ),
                  
                  // Trial list
                  Expanded(
                    child: filteredTrials.isEmpty
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
                            itemCount: filteredTrials.length,
                            separatorBuilder: (context, index) => SizedBox(height: 2.h),
                            itemBuilder: (context, index) {
                              final trial = filteredTrials[index];
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
            case CustomBottomBarItem.add:
              Navigator.pushNamed(context, '/add-subscription');
              break;
            case CustomBottomBarItem.analytics:
              Navigator.pushReplacementNamed(context, '/analytics');
              break;
          }
        },
      ),
    );
  }
}