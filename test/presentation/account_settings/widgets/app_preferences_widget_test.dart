import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:subtracker/data/models/user_settings.dart';
import 'package:subtracker/data/repositories/settings_repository.dart';
import 'package:subtracker/presentation/account_settings/viewmodel/account_settings_viewmodel.dart';
import 'package:subtracker/presentation/account_settings/widgets/app_preferences_widget.dart';
import 'package:subtracker/theme/app_theme.dart';

/// A minimal mock repository for widget testing
class SimpleTestSettingsRepository implements SettingsRepository {
  UserSettings? _settings;

  SimpleTestSettingsRepository({UserSettings? initialSettings})
      : _settings = initialSettings;

  @override
  Future<UserSettings?> getSettings() async {
    _settings ??= UserSettings.defaults('test-user');
    return _settings;
  }

  @override
  Future<UserSettings> saveSettings(UserSettings settings) async {
    _settings = settings;
    return _settings!;
  }

  @override
  Future<UserSettings> updateThemeMode(ThemeMode mode) async {
    _settings = _settings!.copyWith(themeMode: mode);
    return _settings!;
  }

  @override
  Future<UserSettings> updateNotificationsEnabled(bool enabled) async {
    _settings = _settings!.copyWith(notificationsEnabled: enabled);
    return _settings!;
  }

  @override
  Future<UserSettings> updateCurrency(String currency) async {
    _settings = _settings!.copyWith(currency: currency);
    return _settings!;
  }

  @override
  Future<void> deleteSettings() async {
    _settings = null;
  }

  @override
  Stream<UserSettings?> get settingsStream => const Stream.empty();
}

void main() {
  group('AppPreferencesWidget', () {
    testWidgets('displays theme selection tile', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: SingleChildScrollView(child: AppPreferencesWidget())),
          ),
        ),
      );

      expect(find.text('Theme'), findsOneWidget);
      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('displays currency selection tile', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: SingleChildScrollView(child: AppPreferencesWidget())),
          ),
        ),
      );

      expect(find.text('Currency'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('shows current theme mode', (tester) async {
      final settings = UserSettings(
        id: 'id',
        userId: 'test-user',
        themeMode: ThemeMode.dark,
        notificationsEnabled: true,
        currency: 'USD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final repository = SimpleTestSettingsRepository(initialSettings: settings);
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: SingleChildScrollView(child: AppPreferencesWidget())),
          ),
        ),
      );

      expect(find.text('Dark'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('shows current currency', (tester) async {
      final settings = UserSettings(
        id: 'id',
        userId: 'test-user',
        themeMode: ThemeMode.system,
        notificationsEnabled: true,
        currency: 'EUR',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final repository = SimpleTestSettingsRepository(initialSettings: settings);
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: SingleChildScrollView(child: AppPreferencesWidget())),
          ),
        ),
      );

      expect(find.text('EUR'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('tapping theme opens bottom sheet', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: SingleChildScrollView(child: AppPreferencesWidget())),
          ),
        ),
      );

      // Tap on theme tile
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      // Bottom sheet should show options
      expect(find.text('Select Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsWidgets);

      viewModel.dispose();
    });

    testWidgets('selecting theme updates viewModel', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: SingleChildScrollView(child: AppPreferencesWidget())),
          ),
        ),
      );

      // Tap on theme tile
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      // Select Dark theme
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(viewModel.currentThemeMode, ThemeMode.dark);

      viewModel.dispose();
    });

    testWidgets('tapping currency opens bottom sheet', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: SingleChildScrollView(child: AppPreferencesWidget())),
          ),
        ),
      );

      // Tap on currency tile
      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();

      // Bottom sheet should show options
      expect(find.text('Select Currency'), findsOneWidget);
      expect(find.text('USD - US Dollar'), findsOneWidget);
      expect(find.text('EUR - Euro'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('selecting currency updates viewModel', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: SingleChildScrollView(child: AppPreferencesWidget())),
          ),
        ),
      );

      // Tap on currency tile
      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();

      // Select EUR
      await tester.tap(find.text('EUR - Euro'));
      await tester.pumpAndSettle();

      expect(viewModel.currentCurrency, 'EUR');

      viewModel.dispose();
    });

    testWidgets('shows section title App Preferences', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: SingleChildScrollView(child: AppPreferencesWidget())),
          ),
        ),
      );

      expect(find.text('App Preferences'), findsOneWidget);

      viewModel.dispose();
    });
  });
}
