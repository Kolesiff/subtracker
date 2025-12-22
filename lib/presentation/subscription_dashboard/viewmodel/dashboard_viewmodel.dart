import 'package:flutter/foundation.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// ViewModel for the Subscription Dashboard screen
/// Manages subscription data, filtering, and computed statistics
class DashboardViewModel extends ChangeNotifier {
  final SubscriptionRepository _repository;

  DashboardViewModel({required SubscriptionRepository repository})
      : _repository = repository;

  // State
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String _searchQuery = '';
  bool _isSearchActive = false;

  // Getters for state
  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get isSearchActive => _isSearchActive;
  bool get hasSubscriptions => _subscriptions.isNotEmpty;

  /// Filtered subscriptions based on search query
  List<Subscription> get filteredSubscriptions {
    if (_searchQuery.isEmpty) return _subscriptions;
    final lowerQuery = _searchQuery.toLowerCase();
    return _subscriptions.where((sub) {
      return sub.name.toLowerCase().contains(lowerQuery) ||
          sub.category.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Subscriptions expiring within 7 days, sorted by urgency
  List<Subscription> get expiringSoonSubscriptions {
    return _subscriptions
        .where((sub) => sub.isExpiringSoon && sub.isActive)
        .toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
  }

  /// Total monthly spending across all subscriptions
  double get totalMonthlySpending {
    return _subscriptions.fold(0.0, (sum, sub) => sum + sub.monthlyCost);
  }

  /// Total yearly spending
  double get totalYearlySpending => totalMonthlySpending * 12;

  /// Count of active subscriptions (including trials)
  int get activeSubscriptionCount {
    return _subscriptions.where((s) => s.isActive).length;
  }

  /// Count of trial subscriptions
  int get trialSubscriptionCount {
    return _subscriptions.where((s) => s.isTrial).length;
  }

  /// Number of subscriptions expiring soon (for notification badge)
  int get notificationCount => expiringSoonSubscriptions.length;

  /// Formatted total monthly spending
  String get formattedTotalMonthlySpending =>
      '\$${totalMonthlySpending.toStringAsFixed(2)}';

  /// Load subscriptions from repository
  Future<void> loadSubscriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscriptions = await _repository.getSubscriptions();
      _error = null;
    } catch (e) {
      _error = 'Failed to load subscriptions: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh subscriptions (pull-to-refresh)
  Future<void> refreshSubscriptions() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      _subscriptions = await _repository.getSubscriptions();
      _error = null;
    } catch (e) {
      _error = 'Failed to refresh: ${e.toString()}';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Add a new subscription
  Future<void> addSubscription(Subscription subscription) async {
    try {
      await _repository.addSubscription(subscription);
      _subscriptions = await _repository.getSubscriptions();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add subscription: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update an existing subscription
  Future<void> updateSubscription(Subscription subscription) async {
    try {
      await _repository.updateSubscription(subscription);
      _subscriptions = await _repository.getSubscriptions();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update subscription: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Delete a subscription
  Future<void> deleteSubscription(String id) async {
    try {
      await _repository.deleteSubscription(id);
      _subscriptions = await _repository.getSubscriptions();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete subscription: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Toggle search mode
  void toggleSearch() {
    _isSearchActive = !_isSearchActive;
    if (!_isSearchActive) {
      _searchQuery = '';
    }
    notifyListeners();
  }

  /// Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _isSearchActive = false;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get subscription by ID
  Subscription? getSubscriptionById(String id) {
    try {
      return _subscriptions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
