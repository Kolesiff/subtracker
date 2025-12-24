import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/billing_history.dart';
import 'subscription_repository.dart';

/// Supabase implementation of BillingHistoryRepository
/// Stores billing history per user with Row Level Security
class SupabaseBillingHistoryRepository implements BillingHistoryRepository {
  final SupabaseClient _client;
  static const String _table = 'billing_history';

  SupabaseBillingHistoryRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<List<BillingHistory>> getBillingHistory(String subscriptionId) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('subscription_id', subscriptionId)
          .order('billing_date', ascending: false);

      return (response as List)
          .map((json) => BillingHistory.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('BillingHistoryRepository: Error getting history: $e');
      return [];
    }
  }

  @override
  Future<List<BillingHistory>> getAllBillingHistory() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('billing_date', ascending: false);

      return (response as List)
          .map((json) => BillingHistory.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('BillingHistoryRepository: Error getting all history: $e');
      return [];
    }
  }

  @override
  Future<void> addBillingRecord(BillingHistory record) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final json = record.toJson();
      json['user_id'] = userId;

      await _client.from(_table).insert(json);
    } catch (e) {
      debugPrint('BillingHistoryRepository: Error adding record: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateBillingRecord(BillingHistory record) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final json = record.toJson();

      await _client
          .from(_table)
          .update(json)
          .eq('id', record.id)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('BillingHistoryRepository: Error updating record: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBillingRecord(String id) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _client.from(_table).delete().eq('id', id).eq('user_id', userId);
    } catch (e) {
      debugPrint('BillingHistoryRepository: Error deleting record: $e');
      rethrow;
    }
  }

  @override
  Stream<List<BillingHistory>> billingHistoryStream(String subscriptionId) {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('billing_date', ascending: false)
        .map((list) {
          // Filter by subscription_id client-side since Supabase stream
          // doesn't support multiple eq() filters
          return list
              .where((json) => json['subscription_id'] == subscriptionId)
              .map((json) => BillingHistory.fromJson(json))
              .toList();
        });
  }
}
