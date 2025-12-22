import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/data/models/models.dart';
import 'package:subtracker/data/repositories/repositories.dart';
import 'package:subtracker/presentation/analytics/viewmodel/analytics_viewmodel.dart';

/// Mock subscription repository for testing
class TestSubscriptionRepository implements SubscriptionRepository {
  List<Subscription> subscriptionsToReturn = [];
  bool shouldThrow = false;

  @override
  Future<List<Subscription>> getSubscriptions() async {
    if (shouldThrow) throw Exception('Test error');
    return subscriptionsToReturn;
  }

  @override
  Future<Subscription?> getSubscription(String id) async => null;

  @override
  Future<void> addSubscription(Subscription subscription) async {}

  @override
  Future<void> updateSubscription(Subscription subscription) async {}

  @override
  Future<void> deleteSubscription(String id) async {}

  @override
  Future<List<Subscription>> getExpiringSoon({int withinDays = 7}) async => [];

  @override
  Future<List<Subscription>> getByCategory(SubscriptionCategory category) async => [];

  @override
  Future<List<Subscription>> getByStatus(SubscriptionStatus status) async => [];

  @override
  Future<List<Subscription>> search(String query) async => [];

  @override
  Future<List<BillingHistory>> getBillingHistory(String subscriptionId) async => [];

  @override
  Future<void> addBillingRecord(BillingHistory record) async {}
}

/// Mock trial repository for testing
class TestTrialRepository implements TrialRepository {
  List<Trial> trialsToReturn = [];
  bool shouldThrow = false;

  @override
  Future<List<Trial>> getTrials() async {
    if (shouldThrow) throw Exception('Test error');
    return trialsToReturn;
  }

  @override
  Future<Trial?> getTrial(int id) async => null;

  @override
  Future<void> addTrial(Trial trial) async {}

  @override
  Future<void> updateTrial(Trial trial) async {}

  @override
  Future<void> deleteTrial(int id) async {}

  @override
  Future<List<Trial>> getByUrgency(UrgencyLevel level) async => [];

  @override
  Future<List<Trial>> getByCategory(SubscriptionCategory category) async => [];

  @override
  Future<List<Trial>> getCriticalTrials() async => [];

  @override
  Future<void> cancelTrial(int id) async {}
}

void main() {
  late TestSubscriptionRepository subscriptionRepo;
  late TestTrialRepository trialRepo;
  late AnalyticsViewModel viewModel;

  setUp(() {
    subscriptionRepo = TestSubscriptionRepository();
    trialRepo = TestTrialRepository();
    viewModel = AnalyticsViewModel(
      subscriptionRepository: subscriptionRepo,
      trialRepository: trialRepo,
    );
  });

  group('AnalyticsViewModel - Initial State', () {
    test('initializes with empty data', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNull);
      expect(viewModel.subscriptions, isEmpty);
      expect(viewModel.trials, isEmpty);
    });

    test('totalMonthlySpending is 0 when no subscriptions', () {
      expect(viewModel.totalMonthlySpending, 0.0);
    });

    test('totalYearlySpending is 0 when no subscriptions', () {
      expect(viewModel.totalYearlySpending, 0.0);
    });

    test('activeSubscriptionCount is 0 when no subscriptions', () {
      expect(viewModel.activeSubscriptionCount, 0);
    });

    test('activeTrialCount is 0 when no trials', () {
      expect(viewModel.activeTrialCount, 0);
    });

    test('averageSubscriptionCost handles zero division', () {
      expect(viewModel.averageSubscriptionCost, 0.0);
    });
  });

  group('AnalyticsViewModel - Loading Data', () {
    test('loadAnalytics sets loading state', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 10.0),
      ];
      trialRepo.trialsToReturn = [];

      final future = viewModel.loadAnalytics();
      expect(viewModel.isLoading, true);

      await future;
      expect(viewModel.isLoading, false);
    });

    test('loadAnalytics loads subscriptions and trials', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 10.0),
        _createSubscription(id: '2', cost: 20.0),
      ];
      trialRepo.trialsToReturn = [
        _createTrial(id: 1, daysFromNow: 5),
      ];

      await viewModel.loadAnalytics();

      expect(viewModel.subscriptions.length, 2);
      expect(viewModel.trials.length, 1);
      expect(viewModel.error, isNull);
    });

    test('loadAnalytics sets error on failure', () async {
      subscriptionRepo.shouldThrow = true;

      await viewModel.loadAnalytics();

      expect(viewModel.isLoading, false);
      expect(viewModel.error, 'Failed to load analytics data');
    });

    test('refreshAnalytics calls loadAnalytics', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 15.0),
      ];
      trialRepo.trialsToReturn = [];

      await viewModel.refreshAnalytics();

      expect(viewModel.subscriptions.length, 1);
    });
  });

  group('AnalyticsViewModel - Spending Calculations', () {
    test('totalMonthlySpending sums active subscriptions', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 10.0, status: SubscriptionStatus.active),
        _createSubscription(id: '2', cost: 20.0, status: SubscriptionStatus.active),
        _createSubscription(id: '3', cost: 30.0, status: SubscriptionStatus.cancelled),
      ];
      trialRepo.trialsToReturn = [];

      await viewModel.loadAnalytics();

      expect(viewModel.totalMonthlySpending, 30.0);
    });

    test('totalYearlySpending equals monthly * 12', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 10.0),
      ];
      trialRepo.trialsToReturn = [];

      await viewModel.loadAnalytics();

      expect(viewModel.totalYearlySpending, 120.0);
    });

    test('averageSubscriptionCost calculates correctly', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 10.0),
        _createSubscription(id: '2', cost: 20.0),
        _createSubscription(id: '3', cost: 30.0),
      ];
      trialRepo.trialsToReturn = [];

      await viewModel.loadAnalytics();

      expect(viewModel.averageSubscriptionCost, 20.0);
    });
  });

  group('AnalyticsViewModel - Counts', () {
    test('activeSubscriptionCount filters by active status', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', status: SubscriptionStatus.active),
        _createSubscription(id: '2', status: SubscriptionStatus.active),
        _createSubscription(id: '3', status: SubscriptionStatus.cancelled),
        _createSubscription(id: '4', status: SubscriptionStatus.paused),
      ];
      trialRepo.trialsToReturn = [];

      await viewModel.loadAnalytics();

      expect(viewModel.activeSubscriptionCount, 2);
    });

    test('activeTrialCount filters non-expired trials', () async {
      subscriptionRepo.subscriptionsToReturn = [];
      trialRepo.trialsToReturn = [
        _createTrial(id: 1, daysFromNow: 5),
        _createTrial(id: 2, daysFromNow: 10),
        _createTrial(id: 3, daysFromNow: -1), // Expired
      ];

      await viewModel.loadAnalytics();

      expect(viewModel.activeTrialCount, 2);
    });
  });

  group('AnalyticsViewModel - Category Breakdown', () {
    test('spendingByCategory groups correctly', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 10.0, category: SubscriptionCategory.entertainment),
        _createSubscription(id: '2', cost: 20.0, category: SubscriptionCategory.entertainment),
        _createSubscription(id: '3', cost: 15.0, category: SubscriptionCategory.productivity),
      ];
      trialRepo.trialsToReturn = [];

      await viewModel.loadAnalytics();

      final breakdown = viewModel.spendingByCategory;
      expect(breakdown[SubscriptionCategory.entertainment], 30.0);
      expect(breakdown[SubscriptionCategory.productivity], 15.0);
    });

    test('spendingByCategory ignores cancelled subscriptions', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 10.0, category: SubscriptionCategory.entertainment),
        _createSubscription(id: '2', cost: 20.0, category: SubscriptionCategory.entertainment, status: SubscriptionStatus.cancelled),
      ];
      trialRepo.trialsToReturn = [];

      await viewModel.loadAnalytics();

      expect(viewModel.spendingByCategory[SubscriptionCategory.entertainment], 10.0);
    });

    test('topSpendingCategory returns highest category', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 10.0, category: SubscriptionCategory.entertainment),
        _createSubscription(id: '2', cost: 50.0, category: SubscriptionCategory.productivity),
      ];
      trialRepo.trialsToReturn = [];

      await viewModel.loadAnalytics();

      expect(viewModel.topSpendingCategory, SubscriptionCategory.productivity);
    });

    test('topSpendingCategory returns null when empty', () {
      expect(viewModel.topSpendingCategory, isNull);
    });
  });

  group('AnalyticsViewModel - Formatted Strings', () {
    test('formattedTotalMonthlySpending formats correctly', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 15.99),
      ];
      trialRepo.trialsToReturn = [];

      await viewModel.loadAnalytics();

      expect(viewModel.formattedTotalMonthlySpending, '\$15.99');
    });

    test('formattedTotalYearlySpending formats correctly', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 10.0),
      ];
      trialRepo.trialsToReturn = [];

      await viewModel.loadAnalytics();

      expect(viewModel.formattedTotalYearlySpending, '\$120');
    });

    test('formattedAverageSubscriptionCost formats correctly', () async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription(id: '1', cost: 15.50),
        _createSubscription(id: '2', cost: 24.50),
      ];
      trialRepo.trialsToReturn = [];

      await viewModel.loadAnalytics();

      expect(viewModel.formattedAverageSubscriptionCost, '\$20.00');
    });
  });
}

/// Helper to create a test subscription
Subscription _createSubscription({
  required String id,
  double cost = 10.0,
  SubscriptionStatus status = SubscriptionStatus.active,
  SubscriptionCategory category = SubscriptionCategory.entertainment,
}) {
  return Subscription(
    id: id,
    name: 'Test Subscription $id',
    logoUrl: 'https://example.com/logo.png',
    semanticLabel: 'Test logo',
    cost: cost,
    billingCycle: BillingCycle.monthly,
    nextBillingDate: DateTime.now().add(const Duration(days: 10)),
    category: category,
    status: status,
    brandColor: const Color(0xFF1B365D),
  );
}

/// Helper to create a test trial
Trial _createTrial({
  required int id,
  required int daysFromNow,
}) {
  return Trial(
    id: id,
    serviceName: 'Test Trial $id',
    logoUrl: 'https://example.com/logo.png',
    semanticLabel: 'Test logo',
    category: SubscriptionCategory.entertainment,
    trialEndDate: DateTime.now().add(Duration(days: daysFromNow)),
    conversionCost: 9.99,
    cancellationDifficulty: CancellationDifficulty.easy,
    cancellationUrl: 'https://example.com/cancel',
  );
}
