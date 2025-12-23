import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_settings.dart';
import 'settings_repository.dart';

/// Supabase implementation of SettingsRepository
/// Syncs user settings to the cloud
class SupabaseSettingsRepository implements SettingsRepository {
  final SupabaseClient _client;
  static const String _table = 'user_settings';

  SupabaseSettingsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<UserSettings?> getSettings() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Create default settings for new user
        return _createDefaultSettings(userId);
      }

      return UserSettings.fromJson(response);
    } catch (e) {
      debugPrint('SettingsRepository: Error getting settings: $e');
      return null;
    }
  }

  Future<UserSettings> _createDefaultSettings(String userId) async {
    final defaults = UserSettings.defaults(userId);

    try {
      final response = await _client
          .from(_table)
          .insert(defaults.toJson())
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      debugPrint('SettingsRepository: Error creating default settings: $e');
      // Return defaults even if insert fails (RLS or network issue)
      return defaults;
    }
  }

  @override
  Future<UserSettings> saveSettings(UserSettings settings) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _client
          .from(_table)
          .upsert(settings.toJson())
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      debugPrint('SettingsRepository: Error saving settings: $e');
      rethrow;
    }
  }

  @override
  Future<UserSettings> updateThemeMode(ThemeMode mode) async {
    final current = await getSettings();
    if (current == null) {
      throw Exception('Settings not found');
    }

    return saveSettings(current.copyWith(themeMode: mode));
  }

  @override
  Future<UserSettings> updateNotificationsEnabled(bool enabled) async {
    final current = await getSettings();
    if (current == null) {
      throw Exception('Settings not found');
    }

    return saveSettings(current.copyWith(notificationsEnabled: enabled));
  }

  @override
  Future<UserSettings> updateCurrency(String currency) async {
    final current = await getSettings();
    if (current == null) {
      throw Exception('Settings not found');
    }

    return saveSettings(current.copyWith(currency: currency));
  }

  @override
  Future<void> deleteSettings() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _client.from(_table).delete().eq('user_id', userId);
    } catch (e) {
      debugPrint('SettingsRepository: Error deleting settings: $e');
    }
  }

  @override
  Stream<UserSettings?> get settingsStream {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value(null);
    }

    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((list) {
          if (list.isEmpty) return null;
          return UserSettings.fromJson(list.first);
        });
  }
}
