import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import 'settings_repository.dart';

/// Mock implementation of SettingsRepository for testing
class MockSettingsRepository implements SettingsRepository {
  UserSettings? _settings;
  final _controller = StreamController<UserSettings?>.broadcast();

  /// Simulate a specific user ID for testing
  String testUserId = 'test-user-id';

  /// Simulate network delay
  Duration simulatedDelay = Duration.zero;

  /// Simulate errors
  bool simulateError = false;

  @override
  Future<UserSettings?> getSettings() async {
    await Future.delayed(simulatedDelay);

    if (simulateError) {
      throw Exception('Simulated error');
    }

    if (_settings == null) {
      // Create default settings
      _settings = UserSettings.defaults(testUserId);
      _controller.add(_settings);
    }

    return _settings;
  }

  @override
  Future<UserSettings> saveSettings(UserSettings settings) async {
    await Future.delayed(simulatedDelay);

    if (simulateError) {
      throw Exception('Simulated error');
    }

    _settings = settings.copyWith(updatedAt: DateTime.now());
    _controller.add(_settings);
    return _settings!;
  }

  @override
  Future<UserSettings> updateThemeMode(ThemeMode mode) async {
    final current = await getSettings();
    return saveSettings(current!.copyWith(themeMode: mode));
  }

  @override
  Future<UserSettings> updateNotificationsEnabled(bool enabled) async {
    final current = await getSettings();
    return saveSettings(current!.copyWith(notificationsEnabled: enabled));
  }

  @override
  Future<UserSettings> updateCurrency(String currency) async {
    final current = await getSettings();
    return saveSettings(current!.copyWith(currency: currency));
  }

  @override
  Future<void> deleteSettings() async {
    await Future.delayed(simulatedDelay);

    if (simulateError) {
      throw Exception('Simulated error');
    }

    _settings = null;
    _controller.add(null);
  }

  @override
  Stream<UserSettings?> get settingsStream => _controller.stream;

  /// Reset mock state for testing
  void reset() {
    _settings = null;
    simulateError = false;
    simulatedDelay = Duration.zero;
    testUserId = 'test-user-id';
  }

  /// Set initial settings for testing
  void setInitialSettings(UserSettings settings) {
    _settings = settings;
    _controller.add(_settings);
  }

  /// Dispose the stream controller
  void dispose() {
    _controller.close();
  }
}
