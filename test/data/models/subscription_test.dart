import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/data/models/subscription.dart';

void main() {
  group('BillingCycle', () {
    test('displayName returns correct values', () {
      expect(BillingCycle.weekly.displayName, 'Weekly');
      expect(BillingCycle.monthly.displayName, 'Monthly');
      expect(BillingCycle.quarterly.displayName, 'Quarterly');
      expect(BillingCycle.yearly.displayName, 'Yearly');
    });

    test('fromString parses correctly', () {
      expect(BillingCycle.fromString('weekly'), BillingCycle.weekly);
      expect(BillingCycle.fromString('Monthly'), BillingCycle.monthly);
      expect(BillingCycle.fromString('quarterly'), BillingCycle.quarterly);
      expect(BillingCycle.fromString('yearly'), BillingCycle.yearly);
      expect(BillingCycle.fromString('annual'), BillingCycle.yearly);
      expect(BillingCycle.fromString('unknown'), BillingCycle.monthly);
    });
  });

  group('SubscriptionStatus', () {
    test('displayName returns correct values', () {
      expect(SubscriptionStatus.active.displayName, 'Active');
      expect(SubscriptionStatus.trial.displayName, 'Trial');
      expect(SubscriptionStatus.paused.displayName, 'Paused');
      expect(SubscriptionStatus.cancelled.displayName, 'Cancelled');
      expect(SubscriptionStatus.expired.displayName, 'Expired');
    });

    test('fromString parses correctly', () {
      expect(SubscriptionStatus.fromString('active'), SubscriptionStatus.active);
      expect(SubscriptionStatus.fromString('Trial'), SubscriptionStatus.trial);
      expect(SubscriptionStatus.fromString('unknown'), SubscriptionStatus.active);
    });
  });

  group('SubscriptionCategory', () {
    test('displayName returns correct values', () {
      expect(SubscriptionCategory.entertainment.displayName, 'Entertainment');
      expect(SubscriptionCategory.music.displayName, 'Music');
      expect(SubscriptionCategory.productivity.displayName, 'Productivity');
    });

    test('fromString parses correctly', () {
      expect(SubscriptionCategory.fromString('entertainment'),
          SubscriptionCategory.entertainment);
      expect(SubscriptionCategory.fromString('Music'), SubscriptionCategory.music);
      expect(SubscriptionCategory.fromString('unknown'), SubscriptionCategory.other);
    });
  });

  group('Subscription', () {
    late Subscription subscription;

    setUp(() {
      subscription = Subscription(
        id: '1',
        name: 'Netflix',
        logoUrl: 'https://example.com/logo.png',
        semanticLabel: 'Netflix logo',
        cost: 15.99,
        billingCycle: BillingCycle.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 5)),
        category: SubscriptionCategory.entertainment,
        status: SubscriptionStatus.active,
        brandColor: const Color(0xFFE50914),
      );
    });

    test('monthlyCost calculates correctly for different billing cycles', () {
      expect(subscription.monthlyCost, 15.99);

      final yearlySubscription = subscription.copyWith(
        cost: 120.00,
        billingCycle: BillingCycle.yearly,
      );
      expect(yearlySubscription.monthlyCost, 10.00);

      final quarterlySubscription = subscription.copyWith(
        cost: 30.00,
        billingCycle: BillingCycle.quarterly,
      );
      expect(quarterlySubscription.monthlyCost, 10.00);

      final weeklySubscription = subscription.copyWith(
        cost: 4.00,
        billingCycle: BillingCycle.weekly,
      );
      expect(weeklySubscription.monthlyCost, closeTo(17.32, 0.01));
    });

    test('daysUntilBilling calculates correctly', () {
      final sub = Subscription(
        id: '1',
        name: 'Test',
        cost: 10.00,
        billingCycle: BillingCycle.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 5)),
        category: SubscriptionCategory.other,
        brandColor: Colors.blue,
      );
      expect(sub.daysUntilBilling, 5);
    });

    test('isExpiringSoon returns true when within threshold', () {
      final expiringSoon = subscription.copyWith(
        nextBillingDate: DateTime.now().add(const Duration(days: 3)),
      );
      expect(expiringSoon.isExpiringSoon, true);

      final notExpiring = subscription.copyWith(
        nextBillingDate: DateTime.now().add(const Duration(days: 10)),
      );
      expect(notExpiring.isExpiringSoon, false);
    });

    test('isTrial returns correct value based on status', () {
      expect(subscription.isTrial, false);

      final trialSub = subscription.copyWith(status: SubscriptionStatus.trial);
      expect(trialSub.isTrial, true);
    });

    test('isActive returns true for active and trial statuses', () {
      expect(subscription.isActive, true);

      final trialSub = subscription.copyWith(status: SubscriptionStatus.trial);
      expect(trialSub.isActive, true);

      final pausedSub = subscription.copyWith(status: SubscriptionStatus.paused);
      expect(pausedSub.isActive, false);
    });

    test('formattedCost returns correctly formatted string', () {
      expect(subscription.formattedCost, '\$15.99');

      final wholeDollarSub = subscription.copyWith(cost: 10.00);
      expect(wholeDollarSub.formattedCost, '\$10.00');
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = subscription.copyWith(
        name: 'Netflix Premium',
        cost: 19.99,
      );

      expect(updated.name, 'Netflix Premium');
      expect(updated.cost, 19.99);
      expect(updated.id, subscription.id);
      expect(updated.category, subscription.category);
    });

    test('toMap serializes correctly', () {
      final map = subscription.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Netflix');
      expect(map['cost'], 15.99);
      expect(map['billingCycle'], 'monthly');
      expect(map['category'], 'entertainment');
      expect(map['status'], 'active');
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': '2',
        'name': 'Spotify',
        'logoUrl': 'https://example.com/spotify.png',
        'cost': 9.99,
        'billingCycle': 'monthly',
        'nextBillingDate': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'category': 'music',
        'status': 'active',
        'brandColor': 0xFF1DB954,
      };

      final sub = Subscription.fromMap(map);

      expect(sub.id, '2');
      expect(sub.name, 'Spotify');
      expect(sub.cost, 9.99);
      expect(sub.billingCycle, BillingCycle.monthly);
      expect(sub.category, SubscriptionCategory.music);
      expect(sub.status, SubscriptionStatus.active);
    });

    test('equality is based on id', () {
      final sub1 = Subscription(
        id: '1',
        name: 'Netflix',
        cost: 15.99,
        billingCycle: BillingCycle.monthly,
        nextBillingDate: DateTime.now(),
        category: SubscriptionCategory.entertainment,
        brandColor: Colors.red,
      );

      final sub2 = Subscription(
        id: '1',
        name: 'Different Name',
        cost: 99.99,
        billingCycle: BillingCycle.yearly,
        nextBillingDate: DateTime.now().add(const Duration(days: 30)),
        category: SubscriptionCategory.productivity,
        brandColor: Colors.blue,
      );

      expect(sub1, equals(sub2));
      expect(sub1.hashCode, sub2.hashCode);
    });
  });
}
