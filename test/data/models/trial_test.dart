import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/data/models/trial.dart';
import 'package:subtracker/data/models/subscription.dart';

void main() {
  group('UrgencyLevel', () {
    test('displayName returns correct values', () {
      expect(UrgencyLevel.critical.displayName, 'Critical');
      expect(UrgencyLevel.warning.displayName, 'Warning');
      expect(UrgencyLevel.safe.displayName, 'Safe');
    });

    test('color returns correct colors', () {
      expect(UrgencyLevel.critical.color, const Color(0xFFE74C3C));
      expect(UrgencyLevel.warning.color, const Color(0xFFF39C12));
      expect(UrgencyLevel.safe.color, const Color(0xFF2ECC71));
    });

    test('fromDaysRemaining calculates correctly', () {
      expect(UrgencyLevel.fromDaysRemaining(0), UrgencyLevel.critical);
      expect(UrgencyLevel.fromDaysRemaining(1), UrgencyLevel.warning);
      expect(UrgencyLevel.fromDaysRemaining(7), UrgencyLevel.warning);
      expect(UrgencyLevel.fromDaysRemaining(8), UrgencyLevel.safe);
    });

    test('fromHoursRemaining calculates correctly', () {
      expect(UrgencyLevel.fromHoursRemaining(12), UrgencyLevel.critical);
      expect(UrgencyLevel.fromHoursRemaining(24), UrgencyLevel.warning);
      expect(UrgencyLevel.fromHoursRemaining(168), UrgencyLevel.warning);
      expect(UrgencyLevel.fromHoursRemaining(169), UrgencyLevel.safe);
    });
  });

  group('CancellationDifficulty', () {
    test('displayName returns correct values', () {
      expect(CancellationDifficulty.easy.displayName, 'Easy');
      expect(CancellationDifficulty.medium.displayName, 'Medium');
      expect(CancellationDifficulty.hard.displayName, 'Hard');
    });

    test('color returns correct colors', () {
      expect(CancellationDifficulty.easy.color, const Color(0xFF2ECC71));
      expect(CancellationDifficulty.medium.color, const Color(0xFFF39C12));
      expect(CancellationDifficulty.hard.color, const Color(0xFFE74C3C));
    });

    test('fromString parses correctly', () {
      expect(CancellationDifficulty.fromString('easy'), CancellationDifficulty.easy);
      expect(CancellationDifficulty.fromString('Hard'), CancellationDifficulty.hard);
      expect(CancellationDifficulty.fromString('unknown'), CancellationDifficulty.medium);
    });
  });

  group('Trial', () {
    late Trial trial;

    setUp(() {
      trial = Trial(
        id: 1,
        serviceName: 'Netflix Premium',
        logoUrl: 'https://example.com/netflix.png',
        semanticLabel: 'Netflix logo',
        category: SubscriptionCategory.entertainment,
        trialEndDate: DateTime.now().add(const Duration(days: 5)),
        conversionCost: 15.99,
        cancellationDifficulty: CancellationDifficulty.easy,
        cancellationUrl: 'https://netflix.com/cancel',
      );
    });

    test('urgencyLevel calculates correctly based on time remaining', () {
      // 5 days = warning
      expect(trial.urgencyLevel, UrgencyLevel.warning);

      // Critical (< 24 hours)
      final criticalTrial = trial.copyWith(
        trialEndDate: DateTime.now().add(const Duration(hours: 12)),
      );
      expect(criticalTrial.urgencyLevel, UrgencyLevel.critical);

      // Safe (> 7 days)
      final safeTrial = trial.copyWith(
        trialEndDate: DateTime.now().add(const Duration(days: 10)),
      );
      expect(safeTrial.urgencyLevel, UrgencyLevel.safe);
    });

    test('daysRemaining calculates correctly', () {
      // Due to timing, this could be 4 or 5 days
      expect(trial.daysRemaining, inInclusiveRange(4, 5));
    });

    test('hoursRemaining calculates correctly', () {
      expect(trial.hoursRemaining, closeTo(5 * 24, 1));
    });

    test('isExpired returns correct value', () {
      expect(trial.isExpired, false);

      final expiredTrial = trial.copyWith(
        trialEndDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(expiredTrial.isExpired, true);
    });

    test('isCritical returns true for trials expiring within 24 hours', () {
      expect(trial.isCritical, false);

      final criticalTrial = trial.copyWith(
        trialEndDate: DateTime.now().add(const Duration(hours: 12)),
      );
      expect(criticalTrial.isCritical, true);
    });

    test('needsAttention returns true for trials within 7 days', () {
      expect(trial.needsAttention, true);

      final safeTrial = trial.copyWith(
        trialEndDate: DateTime.now().add(const Duration(days: 10)),
      );
      expect(safeTrial.needsAttention, false);
    });

    test('formattedConversionCost returns correctly formatted string', () {
      expect(trial.formattedConversionCost, '\$15.99/month');
    });

    test('timeRemainingText returns human-readable text', () {
      // Days remaining
      expect(trial.timeRemainingText, '5 days left');

      // 1 day
      final oneDayTrial = trial.copyWith(
        trialEndDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
      );
      expect(oneDayTrial.timeRemainingText, '1 day left');

      // Hours remaining
      final hoursTrial = trial.copyWith(
        trialEndDate: DateTime.now().add(const Duration(hours: 12)),
      );
      expect(hoursTrial.timeRemainingText, '12 hours left');

      // Expired
      final expiredTrial = trial.copyWith(
        trialEndDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(expiredTrial.timeRemainingText, 'Expired');
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = trial.copyWith(
        serviceName: 'Netflix Basic',
        conversionCost: 9.99,
      );

      expect(updated.serviceName, 'Netflix Basic');
      expect(updated.conversionCost, 9.99);
      expect(updated.id, trial.id);
      expect(updated.category, trial.category);
    });

    test('toMap serializes correctly', () {
      final map = trial.toMap();

      expect(map['id'], 1);
      expect(map['serviceName'], 'Netflix Premium');
      expect(map['conversionCost'], 15.99);
      expect(map['cancellationDifficulty'], 'easy');
      expect(map['category'], 'entertainment');
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 2,
        'serviceName': 'Spotify',
        'logoUrl': 'https://example.com/spotify.png',
        'category': 'music',
        'trialEndDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'conversionCost': 9.99,
        'cancellationDifficulty': 'easy',
      };

      final t = Trial.fromMap(map);

      expect(t.id, 2);
      expect(t.serviceName, 'Spotify');
      expect(t.conversionCost, 9.99);
      expect(t.cancellationDifficulty, CancellationDifficulty.easy);
      expect(t.category, SubscriptionCategory.music);
    });

    test('equality is based on id', () {
      final trial1 = Trial(
        id: 1,
        serviceName: 'Netflix',
        category: SubscriptionCategory.entertainment,
        trialEndDate: DateTime.now(),
        conversionCost: 15.99,
      );

      final trial2 = Trial(
        id: 1,
        serviceName: 'Different Name',
        category: SubscriptionCategory.productivity,
        trialEndDate: DateTime.now().add(const Duration(days: 30)),
        conversionCost: 99.99,
      );

      expect(trial1, equals(trial2));
      expect(trial1.hashCode, trial2.hashCode);
    });
  });
}
