import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/data/models/user_settings.dart';
import 'package:subtracker/data/repositories/mock_settings_repository.dart';
import 'package:subtracker/presentation/account_settings/viewmodel/account_settings_viewmodel.dart';

void main() {
  late MockSettingsRepository mockRepository;
  late AccountSettingsViewModel viewModel;

  setUp(() {
    mockRepository = MockSettingsRepository();
    viewModel = AccountSettingsViewModel(repository: mockRepository);
  });

  tearDown(() {
    viewModel.dispose();
    mockRepository.dispose();
  });

  group('Initial State', () {
    test('should have idle status initially', () {
      expect(viewModel.status, AccountSettingsStatus.idle);
    });

    test('should have null settings initially', () {
      expect(viewModel.settings, isNull);
    });

    test('should not be loading initially', () {
      expect(viewModel.isLoading, isFalse);
    });

    test('should not be saving initially', () {
      expect(viewModel.isSaving, isFalse);
    });

    test('should have no error message initially', () {
      expect(viewModel.errorMessage, isNull);
    });
  });

  group('Computed Properties with Defaults', () {
    test('currentThemeMode returns ThemeMode.system when settings null', () {
      expect(viewModel.currentThemeMode, ThemeMode.system);
    });

    test('isNotificationsEnabled returns true as default when settings null',
        () {
      expect(viewModel.isNotificationsEnabled, isTrue);
    });

    test('currentCurrency returns USD as default when settings null', () {
      expect(viewModel.currentCurrency, 'USD');
    });
  });

  group('loadSettings', () {
    test('should set status to loading during loadSettings', () async {
      // Add a delay so we can catch the loading state
      mockRepository.simulatedDelay = const Duration(milliseconds: 50);

      final loadFuture = viewModel.loadSettings();

      // Check loading state
      expect(viewModel.status, AccountSettingsStatus.loading);
      expect(viewModel.isLoading, isTrue);

      await loadFuture;
    });

    test('should set status to loaded and populate settings on success',
        () async {
      await viewModel.loadSettings();

      expect(viewModel.status, AccountSettingsStatus.loaded);
      expect(viewModel.settings, isNotNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('should create default settings if none exist for user', () async {
      await viewModel.loadSettings();

      expect(viewModel.settings, isNotNull);
      expect(viewModel.settings!.themeMode, ThemeMode.system);
      expect(viewModel.settings!.notificationsEnabled, isTrue);
      expect(viewModel.settings!.currency, 'USD');
    });

    test('should set status to error on failure with message', () async {
      mockRepository.simulateError = true;

      await viewModel.loadSettings();

      expect(viewModel.status, AccountSettingsStatus.error);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('should load existing settings from repository', () async {
      final existingSettings = UserSettings(
        id: 'existing-id',
        userId: 'test-user',
        themeMode: ThemeMode.dark,
        notificationsEnabled: false,
        currency: 'EUR',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.setInitialSettings(existingSettings);

      await viewModel.loadSettings();

      expect(viewModel.settings!.themeMode, ThemeMode.dark);
      expect(viewModel.settings!.notificationsEnabled, isFalse);
      expect(viewModel.settings!.currency, 'EUR');
    });
  });

  group('Computed Properties After Load', () {
    test('currentThemeMode returns settings.themeMode when loaded', () async {
      final existingSettings = UserSettings(
        id: 'id',
        userId: 'user',
        themeMode: ThemeMode.dark,
        notificationsEnabled: true,
        currency: 'USD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.setInitialSettings(existingSettings);

      await viewModel.loadSettings();

      expect(viewModel.currentThemeMode, ThemeMode.dark);
    });

    test('isNotificationsEnabled returns settings value when loaded', () async {
      final existingSettings = UserSettings(
        id: 'id',
        userId: 'user',
        themeMode: ThemeMode.system,
        notificationsEnabled: false,
        currency: 'USD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.setInitialSettings(existingSettings);

      await viewModel.loadSettings();

      expect(viewModel.isNotificationsEnabled, isFalse);
    });

    test('currentCurrency returns settings value when loaded', () async {
      final existingSettings = UserSettings(
        id: 'id',
        userId: 'user',
        themeMode: ThemeMode.system,
        notificationsEnabled: true,
        currency: 'GBP',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.setInitialSettings(existingSettings);

      await viewModel.loadSettings();

      expect(viewModel.currentCurrency, 'GBP');
    });
  });

  group('updateThemeMode', () {
    setUp(() async {
      await viewModel.loadSettings();
    });

    test('should set status to saving during theme update', () async {
      mockRepository.simulatedDelay = const Duration(milliseconds: 50);

      final updateFuture = viewModel.updateThemeMode(ThemeMode.dark);

      expect(viewModel.status, AccountSettingsStatus.saving);
      expect(viewModel.isSaving, isTrue);

      await updateFuture;
    });

    test('should update themeMode and persist via repository', () async {
      await viewModel.updateThemeMode(ThemeMode.dark);

      expect(viewModel.settings!.themeMode, ThemeMode.dark);
      expect(viewModel.currentThemeMode, ThemeMode.dark);
      expect(viewModel.status, AccountSettingsStatus.loaded);
    });

    test('should set error status on save failure', () async {
      mockRepository.simulateError = true;

      await viewModel.updateThemeMode(ThemeMode.dark);

      expect(viewModel.status, AccountSettingsStatus.error);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('should update to ThemeMode.light', () async {
      await viewModel.updateThemeMode(ThemeMode.light);

      expect(viewModel.currentThemeMode, ThemeMode.light);
    });

    test('should update to ThemeMode.system', () async {
      // First set to dark
      await viewModel.updateThemeMode(ThemeMode.dark);
      // Then change to system
      await viewModel.updateThemeMode(ThemeMode.system);

      expect(viewModel.currentThemeMode, ThemeMode.system);
    });
  });

  group('updateNotificationsEnabled', () {
    setUp(() async {
      await viewModel.loadSettings();
    });

    test('should set status to saving during notifications update', () async {
      mockRepository.simulatedDelay = const Duration(milliseconds: 50);

      final updateFuture = viewModel.updateNotificationsEnabled(false);

      expect(viewModel.status, AccountSettingsStatus.saving);
      expect(viewModel.isSaving, isTrue);

      await updateFuture;
    });

    test('should update notificationsEnabled and persist via repository',
        () async {
      await viewModel.updateNotificationsEnabled(false);

      expect(viewModel.settings!.notificationsEnabled, isFalse);
      expect(viewModel.isNotificationsEnabled, isFalse);
      expect(viewModel.status, AccountSettingsStatus.loaded);
    });

    test('should set error status on save failure', () async {
      mockRepository.simulateError = true;

      await viewModel.updateNotificationsEnabled(false);

      expect(viewModel.status, AccountSettingsStatus.error);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('should toggle notifications back to enabled', () async {
      await viewModel.updateNotificationsEnabled(false);
      await viewModel.updateNotificationsEnabled(true);

      expect(viewModel.isNotificationsEnabled, isTrue);
    });
  });

  group('updateCurrency', () {
    setUp(() async {
      await viewModel.loadSettings();
    });

    test('should set status to saving during currency update', () async {
      mockRepository.simulatedDelay = const Duration(milliseconds: 50);

      final updateFuture = viewModel.updateCurrency('EUR');

      expect(viewModel.status, AccountSettingsStatus.saving);
      expect(viewModel.isSaving, isTrue);

      await updateFuture;
    });

    test('should update currency and persist via repository', () async {
      await viewModel.updateCurrency('EUR');

      expect(viewModel.settings!.currency, 'EUR');
      expect(viewModel.currentCurrency, 'EUR');
      expect(viewModel.status, AccountSettingsStatus.loaded);
    });

    test('should set error status on save failure', () async {
      mockRepository.simulateError = true;

      await viewModel.updateCurrency('EUR');

      expect(viewModel.status, AccountSettingsStatus.error);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('should support all SupportedCurrencies', () async {
      for (final currency in SupportedCurrencies.all) {
        await viewModel.updateCurrency(currency);
        expect(viewModel.currentCurrency, currency);
      }
    });
  });

  group('Error Handling', () {
    test('clearError should reset error and status to loaded when settings exist',
        () async {
      await viewModel.loadSettings();
      mockRepository.simulateError = true;
      await viewModel.updateThemeMode(ThemeMode.dark);

      expect(viewModel.status, AccountSettingsStatus.error);

      mockRepository.simulateError = false;
      viewModel.clearError();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.status, AccountSettingsStatus.loaded);
    });

    test('clearError should reset to idle when no settings loaded', () {
      // Force an error state without loading settings
      mockRepository.simulateError = true;

      // This should be in an error or idle state
      viewModel.clearError();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.status, AccountSettingsStatus.idle);
    });
  });

  group('Notification Behavior', () {
    test('should notify listeners on status change', () async {
      int notificationCount = 0;
      viewModel.addListener(() => notificationCount++);

      await viewModel.loadSettings();

      // Should have notified at least once (loading -> loaded)
      expect(notificationCount, greaterThan(0));
    });

    test('should notify listeners on settings change', () async {
      await viewModel.loadSettings();

      int notificationCount = 0;
      viewModel.addListener(() => notificationCount++);

      await viewModel.updateThemeMode(ThemeMode.dark);

      expect(notificationCount, greaterThan(0));
    });

    test('should notify listeners on error', () async {
      int notificationCount = 0;
      viewModel.addListener(() => notificationCount++);

      mockRepository.simulateError = true;
      await viewModel.loadSettings();

      expect(notificationCount, greaterThan(0));
    });
  });

  group('Stream Subscription', () {
    test('should update state when settings stream emits new value', () async {
      await viewModel.loadSettings();

      // Directly update settings in repository to trigger stream
      final newSettings = UserSettings(
        id: 'new-id',
        userId: 'test-user',
        themeMode: ThemeMode.dark,
        notificationsEnabled: false,
        currency: 'JPY',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.setInitialSettings(newSettings);

      // Wait for stream to propagate
      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.currentThemeMode, ThemeMode.dark);
      expect(viewModel.isNotificationsEnabled, isFalse);
      expect(viewModel.currentCurrency, 'JPY');
    });
  });

  group('Edge Cases', () {
    test('should handle rapid consecutive updates', () async {
      await viewModel.loadSettings();

      // Rapid updates
      await viewModel.updateThemeMode(ThemeMode.light);
      await viewModel.updateThemeMode(ThemeMode.dark);
      await viewModel.updateCurrency('EUR');
      await viewModel.updateNotificationsEnabled(false);

      expect(viewModel.currentThemeMode, ThemeMode.dark);
      expect(viewModel.currentCurrency, 'EUR');
      expect(viewModel.isNotificationsEnabled, isFalse);
      expect(viewModel.status, AccountSettingsStatus.loaded);
    });

    test('should handle updateThemeMode when settings not loaded', () async {
      // Don't load settings first
      await viewModel.updateThemeMode(ThemeMode.dark);

      // Should handle gracefully (either error or load first)
      expect(
        viewModel.status,
        anyOf(AccountSettingsStatus.error, AccountSettingsStatus.loaded),
      );
    });
  });
}
