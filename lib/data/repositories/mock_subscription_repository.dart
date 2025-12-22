import 'package:flutter/material.dart';
import '../models/models.dart';
import 'subscription_repository.dart';

/// Mock implementation of SubscriptionRepository for development and testing
class MockSubscriptionRepository implements SubscriptionRepository {
  // In-memory storage for subscriptions
  final List<Subscription> _subscriptions = [
    Subscription(
      id: '1',
      name: 'Netflix',
      logoUrl:
          'https://img.rocket.new/generatedImages/rocket_gen_img_1a52c1897-1764720017896.png',
      semanticLabel: 'Netflix logo - red N on black background',
      cost: 15.99,
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime.now().add(const Duration(days: 12)),
      category: SubscriptionCategory.entertainment,
      status: SubscriptionStatus.active,
      brandColor: const Color(0xFFE50914),
    ),
    Subscription(
      id: '2',
      name: 'Spotify Premium',
      logoUrl:
          'https://img.rocket.new/generatedImages/rocket_gen_img_1d71ebfa2-1764751041051.png',
      semanticLabel: 'Spotify logo - green circular icon with sound waves',
      cost: 9.99,
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime.now().add(const Duration(days: 5)),
      category: SubscriptionCategory.music,
      status: SubscriptionStatus.active,
      brandColor: const Color(0xFF1DB954),
    ),
    Subscription(
      id: '3',
      name: 'Adobe Creative Cloud',
      logoUrl:
          'https://img.rocket.new/generatedImages/rocket_gen_img_1c8eec6ea-1764647363957.png',
      semanticLabel:
          'Adobe Creative Cloud logo - red gradient square with white cloud icon',
      cost: 52.99,
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime.now().add(const Duration(days: 3)),
      category: SubscriptionCategory.productivity,
      status: SubscriptionStatus.trial,
      brandColor: const Color(0xFFFF0000),
    ),
    Subscription(
      id: '4',
      name: 'Amazon Prime',
      logoUrl:
          'https://img.rocket.new/generatedImages/rocket_gen_img_15314eb28-1765518477718.png',
      semanticLabel:
          'Amazon Prime logo - blue background with white arrow smile',
      cost: 14.99,
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime.now().add(const Duration(days: 20)),
      category: SubscriptionCategory.shopping,
      status: SubscriptionStatus.active,
      brandColor: const Color(0xFF00A8E1),
    ),
    Subscription(
      id: '5',
      name: 'Disney+',
      logoUrl: 'https://images.unsplash.com/photo-1588609888898-10663cf0ba99',
      semanticLabel:
          'Disney Plus logo - blue background with white Disney+ text',
      cost: 7.99,
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime.now().add(const Duration(days: 2)),
      category: SubscriptionCategory.entertainment,
      status: SubscriptionStatus.trial,
      brandColor: const Color(0xFF113CCF),
    ),
    Subscription(
      id: '6',
      name: 'GitHub Pro',
      logoUrl:
          'https://img.rocket.new/generatedImages/rocket_gen_img_10b9cbdab-1765178035130.png',
      semanticLabel:
          'GitHub logo - black octocat silhouette on white background',
      cost: 4.00,
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime.now().add(const Duration(days: 15)),
      category: SubscriptionCategory.development,
      status: SubscriptionStatus.active,
      brandColor: const Color(0xFF181717),
    ),
  ];

  // In-memory storage for billing history
  final Map<String, List<BillingHistory>> _billingHistory = {
    '1': [
      BillingHistory(
        id: 'bh1',
        subscriptionId: '1',
        billingDate: DateTime.now().subtract(const Duration(days: 30)),
        amount: 15.99,
        status: PaymentStatus.completed,
        paymentMethod: 'Visa •••• 4242',
      ),
      BillingHistory(
        id: 'bh2',
        subscriptionId: '1',
        billingDate: DateTime.now().subtract(const Duration(days: 60)),
        amount: 15.99,
        status: PaymentStatus.completed,
        paymentMethod: 'Visa •••• 4242',
      ),
    ],
  };

  @override
  Future<List<Subscription>> getSubscriptions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_subscriptions);
  }

  @override
  Future<Subscription?> getSubscription(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _subscriptions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addSubscription(Subscription subscription) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _subscriptions.add(subscription);
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index != -1) {
      _subscriptions[index] = subscription;
    }
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _subscriptions.removeWhere((s) => s.id == id);
  }

  @override
  Future<List<Subscription>> getExpiringSoon({int withinDays = 7}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _subscriptions
        .where((s) => s.daysUntilBilling <= withinDays && s.isActive)
        .toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
  }

  @override
  Future<List<Subscription>> getByCategory(SubscriptionCategory category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _subscriptions.where((s) => s.category == category).toList();
  }

  @override
  Future<List<Subscription>> getByStatus(SubscriptionStatus status) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _subscriptions.where((s) => s.status == status).toList();
  }

  @override
  Future<List<Subscription>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final lowerQuery = query.toLowerCase();
    return _subscriptions.where((s) {
      return s.name.toLowerCase().contains(lowerQuery) ||
          s.category.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<BillingHistory>> getBillingHistory(String subscriptionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _billingHistory[subscriptionId] ?? [];
  }

  @override
  Future<void> addBillingRecord(BillingHistory record) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _billingHistory.putIfAbsent(record.subscriptionId, () => []);
    _billingHistory[record.subscriptionId]!.add(record);
  }
}

/// Mock implementation of TrialRepository for development and testing
class MockTrialRepository implements TrialRepository {
  // In-memory storage for trials
  final List<Trial> _trials = [
    Trial(
      id: 1,
      serviceName: 'Netflix Premium',
      logoUrl:
          'https://images.unsplash.com/photo-1574375927938-d5a98e8ffe85?w=200&h=200&fit=crop',
      semanticLabel: 'Netflix logo with red N on black background',
      category: SubscriptionCategory.entertainment,
      trialEndDate: DateTime.now().add(const Duration(hours: 18)),
      conversionCost: 15.99,
      cancellationDifficulty: CancellationDifficulty.easy,
      cancellationUrl: 'https://netflix.com/cancel',
    ),
    Trial(
      id: 2,
      serviceName: 'Adobe Creative Cloud',
      logoUrl:
          'https://img.rocket.new/generatedImages/rocket_gen_img_1c8eec6ea-1764647363957.png',
      semanticLabel: 'Adobe Creative Cloud logo with red gradient background',
      category: SubscriptionCategory.productivity,
      trialEndDate: DateTime.now().add(const Duration(days: 3)),
      conversionCost: 54.99,
      cancellationDifficulty: CancellationDifficulty.medium,
      cancellationUrl: 'https://adobe.com/cancel',
    ),
    Trial(
      id: 3,
      serviceName: 'Spotify Premium',
      logoUrl:
          'https://img.rocket.new/generatedImages/rocket_gen_img_1d71ebfa2-1764751041051.png',
      semanticLabel: 'Spotify logo with green circular icon on dark background',
      category: SubscriptionCategory.entertainment,
      trialEndDate: DateTime.now().add(const Duration(days: 5)),
      conversionCost: 9.99,
      cancellationDifficulty: CancellationDifficulty.easy,
      cancellationUrl: 'https://spotify.com/cancel',
    ),
    Trial(
      id: 4,
      serviceName: 'LinkedIn Premium',
      logoUrl:
          'https://img.rocket.new/generatedImages/rocket_gen_img_1e2ba7dbb-1764662219352.png',
      semanticLabel: 'LinkedIn logo with blue background and white text',
      category: SubscriptionCategory.professional,
      trialEndDate: DateTime.now().add(const Duration(days: 12)),
      conversionCost: 29.99,
      cancellationDifficulty: CancellationDifficulty.medium,
      cancellationUrl: 'https://linkedin.com/cancel',
    ),
    Trial(
      id: 5,
      serviceName: 'Headspace Meditation',
      logoUrl:
          'https://img.rocket.new/generatedImages/rocket_gen_img_12e194567-1765458368238.png',
      semanticLabel:
          'Meditation app icon with orange circular design on white background',
      category: SubscriptionCategory.health,
      trialEndDate: DateTime.now().add(const Duration(days: 20)),
      conversionCost: 12.99,
      cancellationDifficulty: CancellationDifficulty.easy,
      cancellationUrl: 'https://headspace.com/cancel',
    ),
  ];

  @override
  Future<List<Trial>> getTrials() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Sort by urgency (most urgent first)
    final sorted = List<Trial>.from(_trials)
      ..sort((a, b) => a.trialEndDate.compareTo(b.trialEndDate));
    return sorted;
  }

  @override
  Future<Trial?> getTrial(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _trials.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addTrial(Trial trial) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _trials.add(trial);
  }

  @override
  Future<void> updateTrial(Trial trial) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _trials.indexWhere((t) => t.id == trial.id);
    if (index != -1) {
      _trials[index] = trial;
    }
  }

  @override
  Future<void> deleteTrial(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _trials.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<Trial>> getByUrgency(UrgencyLevel level) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _trials.where((t) => t.urgencyLevel == level).toList();
  }

  @override
  Future<List<Trial>> getByCategory(SubscriptionCategory category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _trials.where((t) => t.category == category).toList();
  }

  @override
  Future<List<Trial>> getCriticalTrials() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _trials.where((t) => t.isCritical).toList();
  }

  @override
  Future<void> cancelTrial(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _trials.removeWhere((t) => t.id == id);
  }
}
