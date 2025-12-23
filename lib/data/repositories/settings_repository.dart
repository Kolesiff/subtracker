import 'package:flutter/material.dart';

import '../models/user_settings.dart';

/// Abstract interface for user settings operations
/// Implementations: SupabaseSettingsRepository, MockSettingsRepository
abstract class SettingsRepository {
  /// Get settings for the current user
  /// Returns null if no settings exist yet
  Future<UserSettings?> getSettings();

  /// Create or update settings for the current user
  Future<UserSettings> saveSettings(UserSettings settings);

  /// Update theme mode
  Future<UserSettings> updateThemeMode(ThemeMode mode);

  /// Update notifications enabled
  Future<UserSettings> updateNotificationsEnabled(bool enabled);

  /// Update currency
  Future<UserSettings> updateCurrency(String currency);

  /// Delete settings (usually called on sign out)
  Future<void> deleteSettings();

  /// Stream of settings changes
  Stream<UserSettings?> get settingsStream;
}
