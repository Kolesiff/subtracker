import '../models/models.dart';

/// Abstract interface for subscription data operations
/// Allows for easy swapping between mock, local, and remote implementations
abstract class SubscriptionRepository {
  /// Get all subscriptions
  Future<List<Subscription>> getSubscriptions();

  /// Get a single subscription by ID
  Future<Subscription?> getSubscription(String id);

  /// Add a new subscription
  Future<void> addSubscription(Subscription subscription);

  /// Update an existing subscription
  Future<void> updateSubscription(Subscription subscription);

  /// Delete a subscription by ID
  Future<void> deleteSubscription(String id);

  /// Get subscriptions expiring within the given days
  Future<List<Subscription>> getExpiringSoon({int withinDays = 7});

  /// Get subscriptions by category
  Future<List<Subscription>> getByCategory(SubscriptionCategory category);

  /// Get subscriptions by status
  Future<List<Subscription>> getByStatus(SubscriptionStatus status);

  /// Search subscriptions by name or category
  Future<List<Subscription>> search(String query);

  /// Get billing history for a subscription
  Future<List<BillingHistory>> getBillingHistory(String subscriptionId);

  /// Add billing record
  Future<void> addBillingRecord(BillingHistory record);

  /// Stream of subscriptions for real-time updates
  Stream<List<Subscription>> get subscriptionsStream;
}

/// Abstract interface for trial data operations
abstract class TrialRepository {
  /// Get all active trials
  Future<List<Trial>> getTrials();

  /// Get a single trial by ID
  Future<Trial?> getTrial(String id);

  /// Add a new trial
  Future<void> addTrial(Trial trial);

  /// Update an existing trial
  Future<void> updateTrial(Trial trial);

  /// Delete a trial by ID
  Future<void> deleteTrial(String id);

  /// Get trials by urgency level
  Future<List<Trial>> getByUrgency(UrgencyLevel level);

  /// Get trials by category
  Future<List<Trial>> getByCategory(SubscriptionCategory category);

  /// Get critical trials (expiring within 24 hours)
  Future<List<Trial>> getCriticalTrials();

  /// Mark trial as cancelled
  Future<void> cancelTrial(String id);

  /// Stream of trials for real-time updates
  Stream<List<Trial>> get trialsStream;
}

/// Abstract interface for billing history operations
abstract class BillingHistoryRepository {
  /// Get all billing history for a subscription
  Future<List<BillingHistory>> getBillingHistory(String subscriptionId);

  /// Get all billing history for the current user
  Future<List<BillingHistory>> getAllBillingHistory();

  /// Add a billing record
  Future<void> addBillingRecord(BillingHistory record);

  /// Update a billing record
  Future<void> updateBillingRecord(BillingHistory record);

  /// Delete a billing record
  Future<void> deleteBillingRecord(String id);

  /// Stream of billing history for a subscription
  Stream<List<BillingHistory>> billingHistoryStream(String subscriptionId);
}
