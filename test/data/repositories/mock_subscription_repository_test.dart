import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/data/models/models.dart';
import 'package:subtracker/data/repositories/repositories.dart';

void main() {
  group('MockSubscriptionRepository', () {
    late MockSubscriptionRepository repository;

    setUp(() {
      repository = MockSubscriptionRepository();
    });

    test('getSubscriptions returns initial mock data', () async {
      final subscriptions = await repository.getSubscriptions();

      expect(subscriptions, isNotEmpty);
      expect(subscriptions.length, 6);
      expect(subscriptions.first.name, 'Netflix');
    });

    test('getSubscription returns subscription by id', () async {
      final subscription = await repository.getSubscription('1');

      expect(subscription, isNotNull);
      expect(subscription!.name, 'Netflix');
    });

    test('getSubscription returns null for non-existent id', () async {
      final subscription = await repository.getSubscription('999');

      expect(subscription, isNull);
    });

    test('addSubscription adds new subscription', () async {
      final newSubscription = Subscription(
        id: '7',
        name: 'HBO Max',
        cost: 14.99,
        billingCycle: BillingCycle.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 15)),
        category: SubscriptionCategory.entertainment,
        brandColor: Colors.purple,
      );

      await repository.addSubscription(newSubscription);
      final subscriptions = await repository.getSubscriptions();

      expect(subscriptions.length, 7);
      expect(subscriptions.any((s) => s.name == 'HBO Max'), true);
    });

    test('updateSubscription updates existing subscription', () async {
      final original = await repository.getSubscription('1');
      final updated = original!.copyWith(cost: 19.99);

      await repository.updateSubscription(updated);
      final result = await repository.getSubscription('1');

      expect(result!.cost, 19.99);
    });

    test('deleteSubscription removes subscription', () async {
      await repository.deleteSubscription('1');
      final subscriptions = await repository.getSubscriptions();

      expect(subscriptions.any((s) => s.id == '1'), false);
      expect(subscriptions.length, 5);
    });

    test('getExpiringSoon returns subscriptions expiring within threshold', () async {
      final expiring = await repository.getExpiringSoon(withinDays: 7);

      expect(expiring, isNotEmpty);
      for (final sub in expiring) {
        expect(sub.daysUntilBilling, lessThanOrEqualTo(7));
      }
      // Should be sorted by next billing date
      for (int i = 0; i < expiring.length - 1; i++) {
        expect(
          expiring[i].nextBillingDate.isBefore(expiring[i + 1].nextBillingDate) ||
              expiring[i].nextBillingDate.isAtSameMomentAs(expiring[i + 1].nextBillingDate),
          true,
        );
      }
    });

    test('getByCategory filters by category', () async {
      final entertainment = await repository.getByCategory(SubscriptionCategory.entertainment);

      expect(entertainment, isNotEmpty);
      for (final sub in entertainment) {
        expect(sub.category, SubscriptionCategory.entertainment);
      }
    });

    test('getByStatus filters by status', () async {
      final trials = await repository.getByStatus(SubscriptionStatus.trial);

      expect(trials, isNotEmpty);
      for (final sub in trials) {
        expect(sub.status, SubscriptionStatus.trial);
      }
    });

    test('search finds subscriptions by name', () async {
      final results = await repository.search('Netflix');

      expect(results.length, 1);
      expect(results.first.name, 'Netflix');
    });

    test('search finds subscriptions by category', () async {
      final results = await repository.search('Entertainment');

      expect(results, isNotEmpty);
      for (final sub in results) {
        expect(sub.category, SubscriptionCategory.entertainment);
      }
    });

    test('search is case insensitive', () async {
      final results = await repository.search('netflix');

      expect(results.length, 1);
      expect(results.first.name, 'Netflix');
    });

    test('getBillingHistory returns history for subscription', () async {
      final history = await repository.getBillingHistory('1');

      expect(history, isNotEmpty);
      expect(history.first.subscriptionId, '1');
    });

    test('getBillingHistory returns empty for subscription without history', () async {
      final history = await repository.getBillingHistory('99');

      expect(history, isEmpty);
    });

    test('addBillingRecord adds record to history', () async {
      final record = BillingHistory(
        id: 'new',
        subscriptionId: '2',
        billingDate: DateTime.now(),
        amount: 9.99,
      );

      await repository.addBillingRecord(record);
      final history = await repository.getBillingHistory('2');

      expect(history.any((r) => r.id == 'new'), true);
    });
  });

  group('MockTrialRepository', () {
    late MockTrialRepository repository;

    setUp(() {
      repository = MockTrialRepository();
    });

    test('getTrials returns initial mock data sorted by urgency', () async {
      final trials = await repository.getTrials();

      expect(trials, isNotEmpty);
      expect(trials.length, 5);

      // Should be sorted by trial end date (most urgent first)
      for (int i = 0; i < trials.length - 1; i++) {
        expect(
          trials[i].trialEndDate.isBefore(trials[i + 1].trialEndDate) ||
              trials[i].trialEndDate.isAtSameMomentAs(trials[i + 1].trialEndDate),
          true,
        );
      }
    });

    test('getTrial returns trial by id', () async {
      final trial = await repository.getTrial('1');

      expect(trial, isNotNull);
      expect(trial!.serviceName, 'Netflix Premium');
    });

    test('getTrial returns null for non-existent id', () async {
      final trial = await repository.getTrial('999');

      expect(trial, isNull);
    });

    test('addTrial adds new trial', () async {
      final newTrial = Trial(
        id: '99',
        serviceName: 'New Trial',
        category: SubscriptionCategory.productivity,
        trialEndDate: DateTime.now().add(const Duration(days: 7)),
        conversionCost: 19.99,
      );

      await repository.addTrial(newTrial);
      final trials = await repository.getTrials();

      expect(trials.length, 6);
      expect(trials.any((t) => t.serviceName == 'New Trial'), true);
    });

    test('updateTrial updates existing trial', () async {
      final original = await repository.getTrial('1');
      final updated = original!.copyWith(conversionCost: 25.99);

      await repository.updateTrial(updated);
      final result = await repository.getTrial('1');

      expect(result!.conversionCost, 25.99);
    });

    test('deleteTrial removes trial', () async {
      await repository.deleteTrial('1');
      final trials = await repository.getTrials();

      expect(trials.any((t) => t.id == '1'), false);
      expect(trials.length, 4);
    });

    test('getByUrgency filters by urgency level', () async {
      final warnings = await repository.getByUrgency(UrgencyLevel.warning);

      for (final trial in warnings) {
        expect(trial.urgencyLevel, UrgencyLevel.warning);
      }
    });

    test('getByCategory filters by category', () async {
      final entertainment = await repository.getByCategory(SubscriptionCategory.entertainment);

      expect(entertainment, isNotEmpty);
      for (final trial in entertainment) {
        expect(trial.category, SubscriptionCategory.entertainment);
      }
    });

    test('getCriticalTrials returns only critical trials', () async {
      final critical = await repository.getCriticalTrials();

      for (final trial in critical) {
        expect(trial.isCritical, true);
      }
    });

    test('cancelTrial removes trial', () async {
      await repository.cancelTrial('1');
      final trial = await repository.getTrial('1');

      expect(trial, isNull);
    });
  });
}
