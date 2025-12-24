import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'subscription_repository.dart';

/// Supabase implementation of SubscriptionRepository
/// Stores user subscriptions in the cloud with real-time sync
class SupabaseSubscriptionRepository implements SubscriptionRepository {
  final SupabaseClient _client;
  static const String _table = 'subscriptions';

  SupabaseSubscriptionRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<List<Subscription>> getSubscriptions() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('next_billing_date');

      return (response as List)
          .map((json) => Subscription.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('SubscriptionRepository: Error getting subscriptions: $e');
      return [];
    }
  }

  @override
  Future<Subscription?> getSubscription(String id) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Subscription.fromJson(response);
    } catch (e) {
      debugPrint('SubscriptionRepository: Error getting subscription: $e');
      return null;
    }
  }

  @override
  Future<void> addSubscription(Subscription subscription) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final json = subscription.toJson();
      json['user_id'] = userId;

      await _client.from(_table).insert(json);
    } catch (e) {
      debugPrint('SubscriptionRepository: Error adding subscription: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final json = subscription.toJson();
      json['user_id'] = userId;

      await _client
          .from(_table)
          .update(json)
          .eq('id', subscription.id)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('SubscriptionRepository: Error updating subscription: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteSubscription(String id) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('SubscriptionRepository: Error deleting subscription: $e');
      rethrow;
    }
  }

  @override
  Future<List<Subscription>> getExpiringSoon({int withinDays = 7}) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final thresholdDate = DateTime.now().add(Duration(days: withinDays));

      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .inFilter('status', ['active', 'trial'])
          .lte('next_billing_date', thresholdDate.toIso8601String())
          .order('next_billing_date');

      return (response as List)
          .map((json) => Subscription.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('SubscriptionRepository: Error getting expiring soon: $e');
      return [];
    }
  }

  @override
  Future<List<Subscription>> getByCategory(SubscriptionCategory category) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('category', category.name)
          .order('name');

      return (response as List)
          .map((json) => Subscription.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('SubscriptionRepository: Error getting by category: $e');
      return [];
    }
  }

  @override
  Future<List<Subscription>> getByStatus(SubscriptionStatus status) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('status', status.name)
          .order('next_billing_date');

      return (response as List)
          .map((json) => Subscription.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('SubscriptionRepository: Error getting by status: $e');
      return [];
    }
  }

  @override
  Future<List<Subscription>> search(String query) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .ilike('name', '%$query%')
          .order('name');

      return (response as List)
          .map((json) => Subscription.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('SubscriptionRepository: Error searching: $e');
      return [];
    }
  }

  @override
  Future<List<BillingHistory>> getBillingHistory(String subscriptionId) async {
    // Billing history would need a separate table - return empty for now
    // This can be implemented when billing_history table is added
    return [];
  }

  @override
  Future<void> addBillingRecord(BillingHistory record) async {
    // Billing history would need a separate table - no-op for now
  }

  @override
  Stream<List<Subscription>> get subscriptionsStream {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('next_billing_date')
        .map((list) => list.map((json) => Subscription.fromJson(json)).toList());
  }
}
