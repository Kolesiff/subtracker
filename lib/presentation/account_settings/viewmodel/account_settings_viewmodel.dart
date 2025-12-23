import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/models/user_settings.dart';
import '../../../data/repositories/settings_repository.dart';

/// Account settings status states
enum AccountSettingsStatus {
  /// Initial state, no action taken
  idle,

  /// Settings being loaded
  loading,

  /// Settings loaded successfully
  loaded,

  /// Settings being saved
  saving,

  /// An error occurred
  error,
}

/// ViewModel for Account Settings screen
/// Manages user settings state and provides persistence operations
class AccountSettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  StreamSubscription<UserSettings?>? _settingsSubscription;

  AccountSettingsStatus _status = AccountSettingsStatus.idle;
  UserSettings? _settings;
  String? _errorMessage;

  AccountSettingsViewModel({required SettingsRepository repository})
      : _repository = repository {
    // Subscribe to settings stream for real-time updates
    _settingsSubscription = _repository.settingsStream.listen(
      _onSettingsChanged,
      onError: _onStreamError,
    );
  }

  /// Handle settings changes from the repository stream
  void _onSettingsChanged(UserSettings? settings) {
    if (settings != null) {
      _settings = settings;
      if (_status != AccountSettingsStatus.saving) {
        _status = AccountSettingsStatus.loaded;
      }
      notifyListeners();
    }
  }

  /// Handle stream errors
  void _onStreamError(Object error) {
    _errorMessage = error.toString();
    _status = AccountSettingsStatus.error;
    notifyListeners();
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }

  // Getters
  AccountSettingsStatus get status => _status;
  UserSettings? get settings => _settings;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AccountSettingsStatus.loading;
  bool get isSaving => _status == AccountSettingsStatus.saving;

  // Computed properties with safe defaults
  ThemeMode get currentThemeMode => _settings?.themeMode ?? ThemeMode.system;
  bool get isNotificationsEnabled => _settings?.notificationsEnabled ?? true;
  String get currentCurrency => _settings?.currency ?? 'USD';

  /// Load settings from repository
  Future<void> loadSettings() async {
    _status = AccountSettingsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _repository.getSettings();
      _status = AccountSettingsStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AccountSettingsStatus.error;
    }
    notifyListeners();
  }

  /// Update theme mode setting
  Future<void> updateThemeMode(ThemeMode mode) async {
    // If settings haven't been loaded yet, load them first
    if (_settings == null) {
      await loadSettings();
      if (_status == AccountSettingsStatus.error) {
        return;
      }
    }

    _status = AccountSettingsStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _repository.updateThemeMode(mode);
      _status = AccountSettingsStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AccountSettingsStatus.error;
    }
    notifyListeners();
  }

  /// Update notifications enabled setting
  Future<void> updateNotificationsEnabled(bool enabled) async {
    // If settings haven't been loaded yet, load them first
    if (_settings == null) {
      await loadSettings();
      if (_status == AccountSettingsStatus.error) {
        return;
      }
    }

    _status = AccountSettingsStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _repository.updateNotificationsEnabled(enabled);
      _status = AccountSettingsStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AccountSettingsStatus.error;
    }
    notifyListeners();
  }

  /// Update currency setting
  Future<void> updateCurrency(String currency) async {
    // If settings haven't been loaded yet, load them first
    if (_settings == null) {
      await loadSettings();
      if (_status == AccountSettingsStatus.error) {
        return;
      }
    }

    _status = AccountSettingsStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _repository.updateCurrency(currency);
      _status = AccountSettingsStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AccountSettingsStatus.error;
    }
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    _status = _settings != null
        ? AccountSettingsStatus.loaded
        : AccountSettingsStatus.idle;
    notifyListeners();
  }
}
