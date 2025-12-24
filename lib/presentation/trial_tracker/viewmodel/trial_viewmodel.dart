import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// ViewModel for the Trial Tracker screen
/// Manages trial data with real-time stream updates
class TrialViewModel extends ChangeNotifier {
  final TrialRepository _repository;
  StreamSubscription<List<Trial>>? _trialsSubscription;

  TrialViewModel({required TrialRepository repository})
      : _repository = repository {
    _initRealTimeUpdates();
  }

  /// Initialize real-time stream subscription
  void _initRealTimeUpdates() {
    _trialsSubscription = _repository.trialsStream.listen(
      (trials) {
        _trials = trials;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('TrialViewModel: Stream error: $error');
        _error = 'Failed to load trials';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _trialsSubscription?.cancel();
    super.dispose();
  }

  // State
  List<Trial> _trials = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  String _selectedCategory = 'All';
  String _selectedTimeframe = 'All';

  // Getters for state
  List<Trial> get trials => _trials;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get selectedTimeframe => _selectedTimeframe;
  bool get hasTrials => _trials.isNotEmpty;

  /// Active (non-expired) trials
  List<Trial> get activeTrials => _trials.where((t) => !t.isExpired).toList();

  /// Filtered trials based on selected filters
  List<Trial> get filteredTrials {
    return activeTrials.where((trial) {
      final categoryMatch = _selectedCategory == 'All' ||
          trial.category.displayName == _selectedCategory;

      bool timeframeMatch = true;
      if (_selectedTimeframe != 'All') {
        final daysUntilExpiry = trial.daysRemaining;
        timeframeMatch = _selectedTimeframe == 'Expiring Soon'
            ? daysUntilExpiry <= 7
            : daysUntilExpiry > 7;
      }

      return categoryMatch && timeframeMatch;
    }).toList()
      ..sort((a, b) => a.trialEndDate.compareTo(b.trialEndDate));
  }

  /// Trials sorted by urgency (closest to expiry first)
  List<Trial> get sortedByUrgency {
    return List<Trial>.from(activeTrials)
      ..sort((a, b) => a.trialEndDate.compareTo(b.trialEndDate));
  }

  /// Count by urgency level
  int get criticalCount =>
      activeTrials.where((t) => t.urgencyLevel == UrgencyLevel.critical).length;

  int get warningCount =>
      activeTrials.where((t) => t.urgencyLevel == UrgencyLevel.warning).length;

  int get safeCount =>
      activeTrials.where((t) => t.urgencyLevel == UrgencyLevel.safe).length;

  /// Total potential cost if all trials convert
  double get totalPotentialMonthlyCost {
    return activeTrials.fold(0.0, (sum, trial) => sum + trial.conversionCost);
  }

  /// Formatted total potential cost
  String get formattedTotalPotentialCost =>
      '\$${totalPotentialMonthlyCost.toStringAsFixed(2)}';

  /// Load trials from repository (manual refresh)
  Future<void> loadTrials() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trials = await _repository.getTrials();
      _error = null;
    } catch (e) {
      _error = 'Failed to load trials: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh trials (pull-to-refresh)
  Future<void> refreshTrials() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      _trials = await _repository.getTrials();
      _error = null;
    } catch (e) {
      _error = 'Failed to refresh: ${e.toString()}';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Add a new trial
  Future<void> addTrial(Trial trial) async {
    try {
      await _repository.addTrial(trial);
      // Real-time stream will update the list
    } catch (e) {
      _error = 'Failed to add trial: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing trial
  Future<void> updateTrial(Trial trial) async {
    try {
      await _repository.updateTrial(trial);
      // Real-time stream will update the list
    } catch (e) {
      _error = 'Failed to update trial: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Cancel/delete a trial
  Future<void> cancelTrial(String id) async {
    try {
      await _repository.cancelTrial(id);
      // Real-time stream will update the list
    } catch (e) {
      _error = 'Failed to cancel trial: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a trial
  Future<void> deleteTrial(String id) async {
    try {
      await _repository.deleteTrial(id);
      // Real-time stream will update the list
    } catch (e) {
      _error = 'Failed to delete trial: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Set timeframe filter
  void setTimeframe(String timeframe) {
    _selectedTimeframe = timeframe;
    notifyListeners();
  }

  /// Get trial by ID
  Trial? getTrialById(String id) {
    try {
      return _trials.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
