import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'subscription_repository.dart';

/// Supabase implementation of TrialRepository
/// Stores user trials in the cloud with real-time sync
class SupabaseTrialRepository implements TrialRepository {
  final SupabaseClient _client;
  static const String _table = 'trials';

  SupabaseTrialRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<List<Trial>> getTrials() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('trial_end_date');

      return (response as List)
          .map((json) => Trial.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('TrialRepository: Error getting trials: $e');
      return [];
    }
  }

  @override
  Future<Trial?> getTrial(String id) async {
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
      return Trial.fromJson(response);
    } catch (e) {
      debugPrint('TrialRepository: Error getting trial: $e');
      return null;
    }
  }

  @override
  Future<void> addTrial(Trial trial) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final json = trial.toJson();
      json['user_id'] = userId;

      await _client.from(_table).insert(json);
    } catch (e) {
      debugPrint('TrialRepository: Error adding trial: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTrial(Trial trial) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final json = trial.toJson();
      json['user_id'] = userId;

      await _client
          .from(_table)
          .update(json)
          .eq('id', trial.id)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('TrialRepository: Error updating trial: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTrial(String id) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('TrialRepository: Error deleting trial: $e');
      rethrow;
    }
  }

  @override
  Future<List<Trial>> getByUrgency(UrgencyLevel level) async {
    // Get all trials and filter by urgency level
    // (urgency is computed, not stored)
    final trials = await getTrials();
    return trials.where((t) => t.urgencyLevel == level).toList();
  }

  @override
  Future<List<Trial>> getByCategory(SubscriptionCategory category) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('category', category.name)
          .order('trial_end_date');

      return (response as List)
          .map((json) => Trial.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('TrialRepository: Error getting by category: $e');
      return [];
    }
  }

  @override
  Future<List<Trial>> getCriticalTrials() async {
    // Get all trials and filter by critical status
    // (critical is computed based on hours remaining)
    final trials = await getTrials();
    return trials.where((t) => t.isCritical).toList();
  }

  @override
  Future<void> cancelTrial(String id) async {
    // Cancelling a trial removes it from tracking
    await deleteTrial(id);
  }

  @override
  Stream<List<Trial>> get trialsStream {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('trial_end_date')
        .map((list) => list.map((json) => Trial.fromJson(json)).toList());
  }
}
