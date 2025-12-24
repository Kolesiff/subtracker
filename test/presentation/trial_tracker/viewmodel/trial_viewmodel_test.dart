import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/data/models/models.dart';
import 'package:subtracker/data/repositories/repositories.dart';
import 'package:subtracker/presentation/trial_tracker/viewmodel/trial_viewmodel.dart';

/// Mock TrialRepository for testing
class MockTrialRepository implements TrialRepository {
  List<Trial> _trials = [];
  final StreamController<List<Trial>> _streamController =
      StreamController<List<Trial>>.broadcast();
  bool shouldThrow = false;
  String? errorMessage;

  void setTrials(List<Trial> trials) {
    _trials = trials;
    _streamController.add(trials);
  }

  void emitError(String message) {
    _streamController.addError(message);
  }

  @override
  Stream<List<Trial>> get trialsStream => _streamController.stream;

  @override
  Future<List<Trial>> getTrials() async {
    if (shouldThrow) throw Exception(errorMessage ?? 'Test error');
    return _trials;
  }

  @override
  Future<Trial?> getTrial(String id) async {
    if (shouldThrow) throw Exception(errorMessage ?? 'Test error');
    try {
      return _trials.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addTrial(Trial trial) async {
    if (shouldThrow) throw Exception(errorMessage ?? 'Test error');
    _trials = [..._trials, trial];
    _streamController.add(_trials);
  }

  @override
  Future<void> updateTrial(Trial trial) async {
    if (shouldThrow) throw Exception(errorMessage ?? 'Test error');
    _trials = _trials.map((t) => t.id == trial.id ? trial : t).toList();
    _streamController.add(_trials);
  }

  @override
  Future<void> deleteTrial(String id) async {
    if (shouldThrow) throw Exception(errorMessage ?? 'Test error');
    _trials = _trials.where((t) => t.id != id).toList();
    _streamController.add(_trials);
  }

  @override
  Future<void> cancelTrial(String id) async {
    await deleteTrial(id);
  }

  @override
  Future<List<Trial>> getByUrgency(UrgencyLevel level) async {
    return _trials.where((t) => t.urgencyLevel == level).toList();
  }

  @override
  Future<List<Trial>> getByCategory(SubscriptionCategory category) async {
    return _trials.where((t) => t.category == category).toList();
  }

  @override
  Future<List<Trial>> getCriticalTrials() async {
    return _trials.where((t) => t.isCritical).toList();
  }

  void dispose() {
    _streamController.close();
  }
}

void main() {
  late MockTrialRepository mockRepository;
  late TrialViewModel viewModel;

  // Test data
  final testTrials = [
    Trial(
      id: '1',
      serviceName: 'Netflix',
      category: SubscriptionCategory.entertainment,
      trialEndDate: DateTime.now().add(const Duration(days: 2)),
      conversionCost: 15.99,
      cancellationDifficulty: CancellationDifficulty.easy,
    ),
    Trial(
      id: '2',
      serviceName: 'Spotify',
      category: SubscriptionCategory.music,
      trialEndDate: DateTime.now().add(const Duration(days: 10)),
      conversionCost: 9.99,
      cancellationDifficulty: CancellationDifficulty.medium,
    ),
    Trial(
      id: '3',
      serviceName: 'Adobe',
      category: SubscriptionCategory.productivity,
      trialEndDate: DateTime.now().add(const Duration(hours: 12)),
      conversionCost: 54.99,
      cancellationDifficulty: CancellationDifficulty.hard,
    ),
    Trial(
      id: '4',
      serviceName: 'Expired Service',
      category: SubscriptionCategory.other,
      trialEndDate: DateTime.now().subtract(const Duration(days: 1)),
      conversionCost: 19.99,
    ),
  ];

  setUp(() {
    mockRepository = MockTrialRepository();
    viewModel = TrialViewModel(repository: mockRepository);
  });

  tearDown(() {
    viewModel.dispose();
    mockRepository.dispose();
  });

  group('TrialViewModel initialization', () {
    test('starts with loading state', () {
      expect(viewModel.isLoading, isTrue);
    });

    test('starts with empty trials list', () {
      expect(viewModel.trials, isEmpty);
    });

    test('starts with no error', () {
      expect(viewModel.error, isNull);
    });

    test('starts with default filter values', () {
      expect(viewModel.selectedCategory, equals('All'));
      expect(viewModel.selectedTimeframe, equals('All'));
    });
  });

  group('Real-time stream updates', () {
    test('updates trials when stream emits data', () async {
      mockRepository.setTrials(testTrials);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.trials, equals(testTrials));
      expect(viewModel.isLoading, isFalse);
    });

    test('clears error when stream emits data', () async {
      viewModel.clearError();
      mockRepository.setTrials(testTrials);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.error, isNull);
    });

    test('sets error when stream emits error', () async {
      mockRepository.emitError('Stream error');

      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.error, isNotNull);
    });
  });

  group('Trial counts', () {
    test('calculates correct critical count', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      // Adobe (12 hours) is critical
      expect(viewModel.criticalCount, equals(1));
    });

    test('calculates correct warning count', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      // Netflix (2 days) is warning
      expect(viewModel.warningCount, equals(1));
    });

    test('calculates correct safe count', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      // Spotify (10 days) is safe
      expect(viewModel.safeCount, equals(1));
    });
  });

  group('Active trials', () {
    test('excludes expired trials from activeTrials', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      final activeTrials = viewModel.activeTrials;
      expect(activeTrials.length, equals(3));
      expect(activeTrials.any((t) => t.id == '4'), isFalse);
    });

    test('hasTrials returns true when trials exist', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.hasTrials, isTrue);
    });

    test('hasTrials returns false when no trials', () {
      expect(viewModel.hasTrials, isFalse);
    });
  });

  group('Filtering', () {
    test('filters by category', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      viewModel.setCategory('Entertainment');

      expect(
        viewModel.filteredTrials.every(
          (t) => t.category.displayName == 'Entertainment',
        ),
        isTrue,
      );
    });

    test('filters by timeframe - Expiring Soon', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      viewModel.setTimeframe('Expiring Soon');

      expect(
        viewModel.filteredTrials.every((t) => t.daysRemaining <= 7),
        isTrue,
      );
    });

    test('shows all when category is All', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      viewModel.setCategory('All');

      expect(viewModel.filteredTrials.length, equals(3)); // Excludes expired
    });

    test('sorts filtered trials by end date', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      final filtered = viewModel.filteredTrials;

      for (int i = 0; i < filtered.length - 1; i++) {
        expect(
          filtered[i].trialEndDate.isBefore(filtered[i + 1].trialEndDate) ||
              filtered[i].trialEndDate.isAtSameMomentAs(
                filtered[i + 1].trialEndDate,
              ),
          isTrue,
        );
      }
    });
  });

  group('Total potential cost', () {
    test('calculates correct total for active trials', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      // Netflix (15.99) + Spotify (9.99) + Adobe (54.99) = 80.97
      expect(viewModel.totalPotentialMonthlyCost, closeTo(80.97, 0.01));
    });

    test('formats total cost correctly', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.formattedTotalPotentialCost, equals('\$80.97'));
    });

    test('returns zero when no trials', () {
      expect(viewModel.totalPotentialMonthlyCost, equals(0.0));
    });
  });

  group('CRUD operations', () {
    test('addTrial adds to repository', () async {
      final newTrial = Trial(
        id: '5',
        serviceName: 'New Service',
        category: SubscriptionCategory.other,
        trialEndDate: DateTime.now().add(const Duration(days: 5)),
        conversionCost: 10.00,
      );

      await viewModel.addTrial(newTrial);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.trials.any((t) => t.id == '5'), isTrue);
    });

    test('addTrial sets error on failure', () async {
      mockRepository.shouldThrow = true;

      final newTrial = Trial(
        id: '5',
        serviceName: 'New Service',
        category: SubscriptionCategory.other,
        trialEndDate: DateTime.now().add(const Duration(days: 5)),
        conversionCost: 10.00,
      );

      await expectLater(
        () => viewModel.addTrial(newTrial),
        throwsException,
      );
      expect(viewModel.error, isNotNull);
    });

    test('updateTrial updates in repository', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      final updatedTrial = testTrials[0].copyWith(serviceName: 'Updated Netflix');
      await viewModel.updateTrial(updatedTrial);
      await Future.delayed(const Duration(milliseconds: 50));

      final found = viewModel.getTrialById('1');
      expect(found?.serviceName, equals('Updated Netflix'));
    });

    test('cancelTrial removes from repository', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      await viewModel.cancelTrial('1');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.trials.any((t) => t.id == '1'), isFalse);
    });

    test('deleteTrial removes from repository', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      await viewModel.deleteTrial('2');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.trials.any((t) => t.id == '2'), isFalse);
    });
  });

  group('getTrialById', () {
    test('returns trial when found', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      final trial = viewModel.getTrialById('1');
      expect(trial, isNotNull);
      expect(trial?.serviceName, equals('Netflix'));
    });

    test('returns null when not found', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      final trial = viewModel.getTrialById('nonexistent');
      expect(trial, isNull);
    });
  });

  group('loadTrials', () {
    test('sets loading state', () async {
      final future = viewModel.loadTrials();

      expect(viewModel.isLoading, isTrue);
      await future;
    });

    test('loads trials from repository', () async {
      mockRepository.setTrials(testTrials);
      await viewModel.loadTrials();

      expect(viewModel.trials, equals(testTrials));
    });

    test('clears loading state after load', () async {
      await viewModel.loadTrials();

      expect(viewModel.isLoading, isFalse);
    });

    test('sets error on failure', () async {
      mockRepository.shouldThrow = true;
      await viewModel.loadTrials();

      expect(viewModel.error, isNotNull);
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('refreshTrials', () {
    test('sets refreshing state', () async {
      final future = viewModel.refreshTrials();

      expect(viewModel.isRefreshing, isTrue);
      await future;
    });

    test('clears refreshing state after refresh', () async {
      await viewModel.refreshTrials();

      expect(viewModel.isRefreshing, isFalse);
    });

    test('refreshes trials from repository', () async {
      mockRepository.setTrials(testTrials);
      await viewModel.refreshTrials();

      expect(viewModel.trials, equals(testTrials));
    });
  });

  group('clearError', () {
    test('clears error state', () async {
      mockRepository.shouldThrow = true;
      await viewModel.loadTrials();
      expect(viewModel.error, isNotNull);

      viewModel.clearError();
      expect(viewModel.error, isNull);
    });
  });

  group('sortedByUrgency', () {
    test('returns trials sorted by end date', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      final sorted = viewModel.sortedByUrgency;

      for (int i = 0; i < sorted.length - 1; i++) {
        expect(
          sorted[i].trialEndDate.isBefore(sorted[i + 1].trialEndDate) ||
              sorted[i].trialEndDate.isAtSameMomentAs(sorted[i + 1].trialEndDate),
          isTrue,
        );
      }
    });

    test('excludes expired trials', () async {
      mockRepository.setTrials(testTrials);
      await Future.delayed(const Duration(milliseconds: 50));

      final sorted = viewModel.sortedByUrgency;

      expect(sorted.any((t) => t.isExpired), isFalse);
    });
  });
}
