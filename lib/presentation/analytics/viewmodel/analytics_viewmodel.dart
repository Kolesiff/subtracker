import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// ViewModel for Analytics dashboard
/// Provides spending insights and subscription analytics with real-time updates
class AnalyticsViewModel extends ChangeNotifier {
  final SubscriptionRepository _subscriptionRepository;
  final TrialRepository _trialRepository;

  StreamSubscription<List<Subscription>>? _subscriptionStream;
  StreamSubscription<List<Trial>>? _trialStream;

  List<Subscription> _subscriptions = [];
  List<Trial> _trials = [];
  bool _isLoading = true;
  String? _error;

  AnalyticsViewModel({
    required SubscriptionRepository subscriptionRepository,
    required TrialRepository trialRepository,
  })  : _subscriptionRepository = subscriptionRepository,
        _trialRepository = trialRepository {
    _initRealTimeUpdates();
  }

  /// Initialize real-time stream subscriptions
  void _initRealTimeUpdates() {
    _subscriptionStream = _subscriptionRepository.subscriptionsStream.listen(
      (subscriptions) {
        _subscriptions = subscriptions;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('AnalyticsViewModel: Subscription stream error: $error');
        _error = 'Failed to load subscriptions';
        notifyListeners();
      },
    );

    _trialStream = _trialRepository.trialsStream.listen(
      (trials) {
        _trials = trials;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('AnalyticsViewModel: Trial stream error: $error');
        _error = 'Failed to load trials';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscriptionStream?.cancel();
    _trialStream?.cancel();
    super.dispose();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Subscription> get subscriptions => _subscriptions;
  List<Trial> get trials => _trials;

  /// Total monthly spending across all active subscriptions
  double get totalMonthlySpending {
    return _subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .fold(0.0, (sum, sub) => sum + sub.monthlyCost);
  }

  /// Total yearly spending (monthly * 12)
  double get totalYearlySpending => totalMonthlySpending * 12;

  /// Number of active subscriptions
  int get activeSubscriptionCount {
    return _subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .length;
  }

  /// Number of active trials
  int get activeTrialCount => _trials.where((t) => !t.isExpired).length;

  /// Spending breakdown by category
  Map<SubscriptionCategory, double> get spendingByCategory {
    final Map<SubscriptionCategory, double> result = {};
    for (final sub in _subscriptions) {
      if (sub.status == SubscriptionStatus.active) {
        result[sub.category] = (result[sub.category] ?? 0) + sub.monthlyCost;
      }
    }
    return result;
  }

  /// Category with highest spending
  SubscriptionCategory? get topSpendingCategory {
    if (spendingByCategory.isEmpty) return null;
    return spendingByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Average cost per subscription
  double get averageSubscriptionCost {
    if (activeSubscriptionCount == 0) return 0;
    return totalMonthlySpending / activeSubscriptionCount;
  }

  /// Formatted total monthly spending
  String get formattedTotalMonthlySpending =>
      '\$${totalMonthlySpending.toStringAsFixed(2)}';

  /// Formatted total yearly spending
  String get formattedTotalYearlySpending =>
      '\$${totalYearlySpending.toStringAsFixed(0)}';

  /// Formatted average subscription cost
  String get formattedAverageSubscriptionCost =>
      '\$${averageSubscriptionCost.toStringAsFixed(2)}';

  /// Load analytics data from repositories
  Future<void> loadAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscriptions = await _subscriptionRepository.getSubscriptions();
      _trials = await _trialRepository.getTrials();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load analytics data';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh analytics data
  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }
}
